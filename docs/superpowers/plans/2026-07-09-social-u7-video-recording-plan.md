# SOCIAL-U7: Short Clip Capture — Technical Planning Document

> **Status:** PLANNING ONLY — nenhuma implementação deve começar sem aprovação explícita desta fase.
> **Decisão aprovada nesta etapa:** iniciar futuramente pela **Abordagem A (gravação curta/manual simples)**. Abordagem B (timer configurável + preview no Apex Studio) fica registrada como fast-follow, não aprovada para execução agora.
> **Pré-requisito já concluído:** SOCIAL-U2B (captura de tela estática) — implementado, validado e commitado. Este documento parte do estado real desse código, não de uma reconstrução hipotética.

**Goal:** Definir o que muda tecnicamente para permitir gravação de vídeo curto no APEX BOOSTER+ a partir do pipeline de `MediaProjection` já existente, mantendo as regras de honestidade, consentimento e escopo do `CLAUDE.md` e do `docs/claude/social.md`.

**Escopo desta etapa:** diagnóstico e planejamento. Zero linhas de código produtivo.

---

## Decisão atual (2026-07-09)

- **Gravação de vídeo não será implementada neste ciclo.** Este documento permanece como planejamento aprovado; nenhuma linha de código (`.kt`, `.dart`, `AndroidManifest.xml`) deve ser escrita a partir dele sem uma nova aprovação explícita.
- **Captura de tela (SOCIAL-U2B) permanece como feature ativa**, implementada, validada e commitada — esta decisão não afeta o fluxo de screenshot existente.
- **Vídeo exige uma nova fase própria** (ex.: `SOCIAL-U7` de execução, distinta desta fase de planejamento), com escopo, arquivos e testes declarados antes de qualquer implementação.
- **Qualquer implementação futura de gravação de vídeo precisa de aprovação humana explícita**, mesmo que este plano já exista e já tenha sido lido.
- **Requisitos mínimos já fixados para quando essa fase for aprovada** (detalhados nas seções 3–4 abaixo, repetidos aqui como checklist de bloqueio):
  - limite de duração curto e fixo (10–15s, sem configuração pelo usuário nesta primeira fase);
  - sem áudio (`RECORD_AUDIO` proibido);
  - consentimento explícito e específico para vídeo (copy própria, não reaproveitada do screenshot);
  - notificação persistente durante toda a gravação;
  - botão/caminho de parada explícito que não dependa só da bolha flutuante;
  - limpeza segura do arquivo em caso de kill do processo (nunca entregar `.mp4` corrompido como válido);
  - `.mp4` salvo localmente, sem permissão de storage adicional;
  - integração no Apex Studio só depois de o clipe estar salvo com sucesso (nunca como placeholder "em andamento").

**Motivo da decisão:**

| Risco | Razão |
|---|---|
| Bateria/aquecimento | Gravação contínua de vídeo consome bateria e gera calor de forma muito mais agressiva que uma captura de frame único (ver R-05, seção 5). |
| Arquivo grande | `.mp4` mesmo curto é ordens de grandeza maior que um PNG de screenshot, com impacto direto em armazenamento do usuário. |
| Serviço persistente | Vídeo exige foreground service ativo durante toda a janela de gravação (não mais ~1-2s), aumentando a superfície de falha e o risco de encerramento agressivo pelo sistema/fabricante (ver R-04, seção 5). |
| Play Store/privacidade | Captura de tela contínua tende a acionar revisão mais detalhada e exige Política de Privacidade publicada citando vídeo explicitamente antes da submissão (ver R-07/R-08, seção 6). |
| Complexidade maior que a captura de tela | Vídeo exige pipeline de encoder (`MediaRecorder`/`MediaCodec`+`MediaMuxer`), gestão de ciclo de vida de sessão contínua e finalização segura de arquivo — muito além de "ler um frame e desarmar" (ver seção 2 completa). |

---

## Global Constraints

- Package: `com.allappsengineer.apex_booster_plus` — não alterar.
- Esta é uma fase de planejamento; nenhuma implementação deve começar sem aprovação explícita separada.
- Sem áudio nesta fase (`RECORD_AUDIO` não deve ser adicionado).
- Sem gravação automática — toda gravação exige ação explícita do usuário.
- Sem upload, sem servidor, sem tracking, sem analytics.
- Toda copy nova deve existir em PT-BR, EN e ES via `AppStrings`/`strings.xml`, seguindo o vocabulário aprovado do `CLAUDE.md` (nunca "FPS", "turbo real", "boost real").
- `flutter analyze` e `flutter test` devem passar antes de qualquer commit futuro.
- Commit só após aprovação humana explícita.

---

## 1. Estado atual da captura de tela

O fluxo SOCIAL-U2B (screenshot) está implementado, validado em aparelho e commitado. Resumo da arquitetura real (auditada por leitura completa do código nesta etapa):

| Componente | Responsabilidade | Estado |
|---|---|---|
| `ScreenCaptureService.kt` | Foreground service (`foregroundServiceType="mediaProjection"`). Ao ser armado, cria `MediaProjection` + `HandlerThread` + `ImageReader` (RGBA_8888) + `VirtualDisplay` apontando para o `ImageReader`, e fica **idle/armado**. `captureNow()` lê o frame mais recente, converte para `Bitmap`, salva PNG em `Pictures/apex_captures/`, atualiza `index.json` e **encerra a sessão automaticamente** (`endSessionAfterCapture()` → `stopSession()`: libera `MediaProjection`, `VirtualDisplay`, remove a notificação e esconde o botão A+). | Implementado |
| `FloatingOverlayManager.kt` | Singleton `WindowManager` nativo (sem plugin Flutter). Botão "A+" com drag-to-move e mini-menu nativo com 3 itens: **"Capturar tela"** (funcional), **"Gravar vídeo (em breve)"** (desabilitado, sem `onClick` — placeholder puro de UI), **"Fechar"**. | Implementado (item de vídeo é só placeholder visual) |
| `MainActivity.kt` | Canal `apex/capture` (`armSession`/`disarmSession`/`isSessionArmed`) trata o diálogo de consentimento do `MediaProjectionManager` via `ActivityResultContracts.StartActivityForResult` e sobe o `ScreenCaptureService`. | Implementado |
| `AndroidManifest.xml` | `SYSTEM_ALERT_WINDOW`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PROJECTION` declaradas. **Sem** `RECORD_AUDIO`, sem tipo de foreground service combinado para microfone/câmera. | Implementado |
| `ScreenCaptureGalleryService` (Dart) | Lê `Pictures/apex_captures/index.json` (escrito só pelo nativo) e lista os PNGs existentes, checando se o arquivo ainda existe em disco. | Implementado |
| `ApexStudioScreen` (`Apex Studio`) | Permite escolher uma captura já salva e montar um card social exportável via share sheet. `_canExport` **bloqueia explicitamente** exportação quando `_mediaIsVideo == true` — hoje vídeo só existe como importação da galeria do celular para preview (`video_player`), nunca como saída própria do app. | Implementado |

**Confirmação de auditoria:** zero ocorrências de `MediaRecorder`/`MediaCodec`/`MediaMuxer`/`VideoEncoder` em todo o projeto (Kotlin ou Dart). A única menção a `MediaRecorder` é em uma spec de design antiga (`docs/superpowers/specs/2026-06-11-social-u2a-floating-button-design.md`), como item de escopo futuro, nunca implementado.

**Ponto-chave para o planejamento de vídeo:** a sessão de captura atual é **one-shot** — uma captura de tela sempre encerra a `MediaProjection`, a notificação e o botão A+. Esse comportamento foi desenhado para minimizar o tempo em que o indicador de captura do sistema fica visível, e é o ponto de maior atrito arquitetural para vídeo (ver seção 2).

---

## 2. Por que vídeo exige pipeline diferente

Gravação de vídeo não é uma extensão trivial do screenshot. As diferenças estruturais:

| Critério | Screenshot (atual) | Gravação de vídeo |
|---|---|---|
| Fonte de frames | `ImageReader` (frame único, RGBA_8888) | Encoder de vídeo (`MediaRecorder` ou `MediaCodec` + `MediaMuxer`) recebendo um `Surface` contínuo |
| `VirtualDisplay` | Aponta para a `Surface` do `ImageReader` | Precisa apontar para a `Surface` de entrada do encoder — **não pode ser a mesma instância usada para screenshot ao mesmo tempo**; ou se recria o `VirtualDisplay` conforme a ação escolhida, ou se mantêm displays distintos a partir da mesma `MediaProjection` |
| Duração do foreground service | ~1-2s (um frame, depois encerra) | Contínua durante toda a gravação — a notificação persistente deixa de ser um detalhe cosmético e passa a ser parte central da UX |
| Ciclo de vida da sessão | **1 captura = fim da sessão** (`stopSession()` automático) | Incompatível com o padrão atual: a sessão precisa continuar armada durante a gravação e só encerrar quando o usuário parar ou o limite de tempo for atingido |
| Encerramento seguro | Basta liberar `ImageReader`/`VirtualDisplay`/`MediaProjection` | É preciso finalizar o `MediaMuxer` (`stop()`/`release()`) para gravar o *moov atom* do `.mp4` — se o processo morrer no meio, o arquivo fica corrompido/ilegível sem esse passo |
| Controle de parada | Não se aplica (ação instantânea) | Precisa de um mecanismo explícito de "parar" que não dependa só da bolha flutuante (que pode ficar coberta pelo próprio jogo) |
| Armazenamento e canal de retorno | `index.json` simples, sem round-trip de MethodChannel | Provavelmente precisa avisar o Flutter quando o arquivo estiver pronto (hoje não existe nenhum canal de retorno de path) |
| Apex Studio | `_canExport` já suporta imagem | `_canExport` **bloqueia vídeo hoje por design** — decisão pendente entre exportar o clipe cru (compartilhamento direto) ou compor no card social (pipeline de overlay em vídeo, bem mais caro) |

Em resumo: o pipeline de imagem é "capturar um frame e desarmar"; o pipeline de vídeo exige "manter a sessão armada por uma janela de tempo, com controle de início/fim explícito e finalização seura do arquivo", o que toca o ciclo de vida central do `ScreenCaptureService` e não apenas adiciona uma opção no menu.

---

## 3. Abordagem A aprovada para fase futura

**Gravação curta/manual simples**, conforme diagnóstico da Etapa 3 aprovado pelo usuário:

1. Usuário toca "Gravar vídeo" no mini-menu nativo (item hoje desabilitado, a ser habilitado nesta fase futura).
2. Gravação inicia com **limite fixo curto** (ex.: 10–15s), sem controle de duração configurável pelo usuário nesta primeira fase.
3. Ao atingir o limite (ou ser parada manualmente), o serviço finaliza o `MediaMuxer`, salva o `.mp4` localmente e mostra um toast de conclusão — mesmo padrão de feedback usado hoje para screenshot.
4. O clipe aparece na grade do Apex Studio (com miniatura/ícone de play) **somente depois de salvo**, para **compartilhamento cru** via share sheet nativo — sem compor no card social nesta fase (o pipeline de overlay em vídeo fica fora de escopo).
5. Reaproveita o ciclo "armar → agir → encerrar" já validado para screenshot, com a sessão permanecendo ativa durante a janela de gravação em vez de encerrar após um único frame.

Abordagem B (timer visível, botão de parar dedicado, preview antes de compartilhar) fica registrada como evolução natural depois de A validada em aparelho — não aprovada para execução nesta etapa.

---

## 4. Limites obrigatórios

| Limite | Regra |
|---|---|
| Duração | Curta e **fixa** na primeira fase (ex.: 10–15s hard cap, sem configuração pelo usuário). Cap automático via `Handler.postDelayed` chamando o encerramento da gravação. |
| Áudio | **Nenhum.** Sem `RECORD_AUDIO`, sem `FOREGROUND_SERVICE_TYPE_MICROPHONE`, sem narração. |
| Gravação automática | **Proibida.** Toda gravação exige toque explícito do usuário no item "Gravar vídeo" — nunca disparada por overlay, evento de jogo ou timer de fundo. |
| Consentimento | Explícito e específico para vídeo — o `CaptureConsentSheet`/copy de opt-in atual fala de "captura de tela"; copy nova deve declarar gravação de vídeo, não reaproveitar o texto do screenshot, em PT-BR/EN/ES. |
| Notificação persistente | Obrigatória durante toda a gravação, com texto que deixe claro que há uma gravação em andamento (ex.: variação de "Modo Captura da Sessão ativo" para estado de gravação), preferencialmente com indicação de tempo decorrido. |
| Parar/limpar com segurança | Deve existir um caminho de parada que não dependa só da bolha (ex.: ação na própria notificação). Em caso de kill do processo, `onTaskRemoved`/exceções devem tentar finalizar o `MediaMuxer` corretamente ou descartar o clipe — nunca entregar um arquivo corrompido como se fosse válido. |
| Salvar MP4 local | Arquivo `.mp4` salvo em diretório de app própria (equivalente a `getExternalFilesDir`, análogo ao usado hoje para PNG), sem exigir permissão de storage adicional. |
| Aparecer no Apex Studio só depois | O clipe só deve aparecer na grade de seleção do Apex Studio **após** a gravação estar finalizada e o arquivo salvo com sucesso — nunca como um placeholder "em andamento". |

---

## 5. Riscos Android 14/15/16

| # | Risco | Contexto |
|---|---|---|
| R-01 | Consentimento de `MediaProjection` não é reutilizável entre sessões (comportamento reforçado desde Android 14). | Já tratado corretamente hoje (`armSession()` sempre gera novo diálogo); para vídeo, é preciso decidir se a gravação reaproveita uma sessão já armada (sem re-pedir consentimento) ou sempre inicia do zero — impacta diretamente a UX de "print + depois vídeo" na mesma sessão de bolha ativa. |
| R-02 | `foregroundServiceType="mediaProjection"` já declarado e correto; não deve ser combinado com `microphone`/`camera` nesta fase (áudio fora de escopo). | Adicionar tipo de serviço para áudio exigiria `RECORD_AUDIO` — explicitamente proibido no limite da seção 4. |
| R-03 | Disponibilidade e limites de hardware do `MediaCodec` variam por SoC/fabricante — resolução e bitrate do encoder precisam respeitar `MediaCodecInfo.VideoCapabilities`. | Resolução nativa de tela pode não ser diretamente suportada pelo encoder (alinhamentos, múltiplos de 16); pode ser necessário reduzir para uma resolução segura (ex.: 720p) em vez da resolução nativa do dispositivo. |
| R-04 | Encerramento agressivo de foreground services de longa duração por gerenciamento de bateria do fabricante (relevante em One UI/Samsung, que é o baseline de validação do projeto). | Se o processo for morto no meio da gravação, o `MediaMuxer` precisa ser finalizado corretamente (`stop()`/`release()`) ou o `.mp4` fica corrompido; é preciso tratamento de `onTaskRemoved`/exceções com descarte seguro do clipe. |
| R-05 | Sem limite rígido de duração, o recurso contraria a proposta de preparação leve do produto (uso de bateria, geração de arquivos grandes, aquecimento). | Mitigado pelo cap fixo curto definido na Abordagem A (seção 3/4). |
| R-06 | Indicador de captura do sistema (ícone na barra de status, obrigatório desde Android 12) fica visível durante toda a janela de gravação, não apenas por ~1-2s como no screenshot. | Reforça a necessidade de notificação clara sobre o que está sendo capturado (seção 4). |

---

## 6. Riscos Play Store/privacidade

| # | Risco | Contexto |
|---|---|---|
| R-07 | `MediaProjection` não é uma "permissão especial" adicional no Console (diferente de `SYSTEM_ALERT_WINDOW`, já declarado) — mas o uso de captura de tela contínua pode acionar revisão manual mais detalhada. | Justificativa de uso deve ficar clara: "gravação curta iniciada explicitamente pelo usuário para compartilhamento social", nunca "melhoria de desempenho". |
| R-08 | Política de Privacidade (ainda não publicada — pendência crítica já registrada no roadmap do `CLAUDE.md`) precisa citar explicitamente gravação de vídeo assim que esta fase for implementada. | Não pode ser adiada para depois do release; é pré-requisito de submissão. |
| R-09 | Consentimento em app precisa ser específico para vídeo — reaproveitar a copy do print violaria a regra de consentimento explícito do `docs/claude/social.md`. | Nova copy validada em PT-BR/EN/ES antes de qualquer implementação. |
| R-10 | Regra soberana do `docs/claude/social.md`: nunca capturar, gravar ou publicar sem ação explícita e consentimento claro. | O item "Gravar vídeo" no menu nativo já está corretamente desabilitado hoje; deve permanecer assim até esta fase futura ser aprovada e implementada com os limites da seção 4. |
| R-11 | Watermark/compartilhamento não pode sugerir boost real ou vantagem competitiva (vocabulário proibido do `CLAUDE.md`: "turbo real", "FPS", "boost real"). | Aplica-se a qualquer copy nova de gravação/compartilhamento de clipe. |

---

## 7. Critérios de aceite no S24 Ultra

Dispositivo de validação do projeto: S24 Ultra + One UI 8.5 + Android 16 (API 36).

- [ ] Gravação inicia apenas após toque explícito no item "Gravar vídeo" — nunca automaticamente.
- [ ] Diálogo de consentimento específico de vídeo aparece antes de qualquer gravação (não reaproveita copy de screenshot).
- [ ] Notificação persistente e visível durante toda a gravação, com texto claro de que há gravação em andamento.
- [ ] Gravação encerra automaticamente ao atingir o limite fixo definido (10–15s), sem exceder o tempo configurado.
- [ ] Existe um caminho de parada manual funcional que não depende exclusivamente da bolha flutuante (ex.: ação na notificação).
- [ ] Ao forçar o encerramento do app/serviço durante a gravação (kill manual, remoção de tarefa), o app não trava nem deixa um `.mp4` corrompido acessível como se fosse válido — o clipe é descartado com segurança.
- [ ] Arquivo `.mp4` resultante abre corretamente em um player de vídeo padrão do Android.
- [ ] Nenhuma permissão de áudio ou storage adicional é solicitada.
- [ ] O clipe só aparece na grade do Apex Studio depois de a gravação e o salvamento terminarem com sucesso.
- [ ] `flutter analyze` e `flutter test` passam sem regressão no fluxo de screenshot existente (SOCIAL-U2B não pode quebrar).
- [ ] Bolha A+ e mini-menu continuam funcionando normalmente para o fluxo de screenshot já existente após a mudança.

---

## 8. Lista explícita do que NÃO implementar agora

- Não implementar `MediaRecorder`/`MediaCodec`/`MediaMuxer` nesta etapa — este documento é planejamento, não código.
- Não habilitar o item "Gravar vídeo" no mini-menu nativo nesta etapa.
- Não adicionar `RECORD_AUDIO` nem qualquer captura de áudio.
- Não implementar duração configurável pelo usuário (Abordagem B) — fica registrada como fast-follow, não aprovada agora.
- Não implementar timer visível/HUD de gravação nem controle de "parar" na bolha flutuante — isso é escopo da Abordagem B, não da A.
- Não implementar preview de vídeo próprio antes de compartilhar (reaproveitamento do `_VideoPreviewDialog` para clipes gravados pelo app) — fica para fase futura.
- Não implementar composição do clipe gravado no card social do Apex Studio (pipeline de overlay em vídeo) — nesta fase o clipe é compartilhado cru, sem passar pelo compositor de card.
- Não alterar `_canExport` no Apex Studio nesta etapa.
- Não adicionar dependências novas de encoding/ffmpeg — a decisão de pipeline (MediaRecorder vs MediaCodec+MediaMuxer) só deve ser tomada e implementada em fase própria aprovada.
- Não atualizar Política de Privacidade nesta etapa (é pré-requisito de uma fase de implementação futura, não desta fase de planejamento).
- Não escrever/alterar nenhum arquivo de código do app (`.kt`, `.dart`, `AndroidManifest.xml`) nesta etapa.
- Não commitar automaticamente.

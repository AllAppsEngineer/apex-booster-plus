# Data Safety — Respostas Preliminares

**Versão:** v4 — remove o Billing interno do app (MONETIZATION-PAID-U1): Apex Booster+ passa a ser aplicativo pago para download, sem compra in-app
**Data:** 30/07/2026
**Revisão obrigatória antes de submissão à Play Store:** sim — ver seção "Itens pendentes de confirmação" ao final.

> Este documento é preliminar/interno. As respostas finais devem ser
> preenchidas diretamente no formulário Data Safety da Play Console.

---

## Critério de "coleta" usado nesta matriz (corrigido)

O Google Play define **coleta** como dado do usuário **transmitido para fora
do dispositivo** — para os servidores do desenvolvedor ou de terceiros. Dado
processado, lido ou armazenado **somente no aparelho**, sem nunca sair dele,
**não deve ser marcado como coletado** no formulário Data Safety, mesmo que o
app o leia ativamente (ex.: abrir um arquivo de vídeo para compor um card).

Isso corrige a versão anterior deste documento (v2), que classificava
capturas de tela, áudio interno, vídeos importados e clipes como "Coletado:
Sim" apenas por serem acessados pelo app — critério incorreto. A partir
desta versão:

- **Coletado: Não** — processamento e armazenamento exclusivamente locais, sem qualquer transmissão para fora do dispositivo. Aplica-se a: capturas de tela, áudio interno do jogo, vídeos importados da galeria, clipes armazenados, `index.json`, `SharedPreferences`, histórico de sessões.
- **Coletado: Sim** — reservado para os casos em que existe transmissão real para fora do dispositivo (ver Apex Ping abaixo) ou quando isso não pode ser descartado sem confirmação adicional.

Esses recursos continuam descritos em detalhe na Política de Privacidade
(`privacy/index.html` e equivalentes EN/ES, seções 5–8), que tem um padrão de
transparência mais amplo do que a definição estrita do formulário Data
Safety — a política **não muda** nesta revisão, apenas a classificação
interna para o formulário.

---

## Matriz auditável de dados

| Dado | Origem | Finalidade | Armazenamento | Transmissão | Retenção | Exclusão | Data Safety (preliminar) |
|---|---|---|---|---|---|---|---|
| Biblioteca de jogos (nome, `packageName`, ícone referenciado) | Seleção manual do usuário entre apps instalados | Exibir/gerenciar biblioteca | `SharedPreferences`, local | Nenhuma | Até remoção manual ou desinstalação | Remover jogo na Biblioteca; desinstalar o app | **Coletado: Não** (processamento local) |
| Perfil GFX por jogo | Escolha manual do usuário | Salvar preferência visual local | `SharedPreferences`, local | Nenhuma | Até remoção/desinstalação | Editar/remover jogo; desinstalar | **Coletado: Não** (processamento local) |
| Histórico de sessões (jogo, data, métricas locais) | Uso do app | Exibir sessões e métricas passadas | `SharedPreferences`, local | Nenhuma | Até "Limpar histórico" ou desinstalação | "Limpar histórico" em Configurações; desinstalar | **Coletado: Não** (processamento local) |
| Idioma, onboarding, Modo Baixa Distração, estado do Botão Flutuante | Preferências do usuário | Personalização local | `SharedPreferences`, local | Nenhuma | Até desinstalação | Desinstalar o app | **Coletado: Não** (processamento local) |
| RAM disponível/total, estado de memória | Leitura nativa via `MethodChannel` | Exibir snapshot da sessão | Em memória, exibição apenas | Nenhuma | Não persiste além da tela atual | N/A (efêmero) | **Coletado: Não** (processamento local) |
| Apps instalados (para listagem na Biblioteca) | `PackageManager`, filtro `MAIN`/`LAUNCHER` (sem `QUERY_ALL_PACKAGES`) | Permitir seleção manual de jogos | Em memória durante a tela; escolhas persistem como "Biblioteca" acima | Nenhuma | N/A (lista efêmera) | N/A | **Coletado: Não** (processamento local) |
| Mídia selecionada no Apex Studio (imagem/vídeo da galeria) | Seleção voluntária do usuário via `image_picker`/`video_player` | Pré-visualizar e compor card social | Em memória durante a sessão; não persiste em `SharedPreferences` | Nenhuma | Descartada ao fechar a tela do Studio | Fechar a tela; desinstalar | **Coletado: Não** (processamento local, nunca transmitido) |
| Capturas de tela (screenshots) via Botão Flutuante | `MediaProjection`, iniciado pelo usuário | Registrar momento da sessão para uso no Apex Studio | Arquivo PNG em armazenamento específico do app (`Pictures/apex_captures/`) + `index.json` local | Nenhuma | Até exclusão manual ou desinstalação | Excluir individualmente no Apex Studio; desinstalar o app | **Coletado: Não** (processamento e armazenamento locais) |
| Clipes de vídeo (10–60s) via Botão Flutuante | `MediaProjection` + `MediaRecorder`, iniciado pelo usuário | Registrar clipe da sessão para uso no Apex Studio | Arquivo MP4 em armazenamento específico do app (`Movies/apex_clips/`) + `index.json` local | Nenhuma | Até exclusão manual ou desinstalação | Excluir individualmente no Apex Studio; desinstalar o app | **Coletado: Não** (processamento e armazenamento locais) |
| Áudio interno do jogo (em clipes de vídeo, quando disponível) | `AudioPlaybackCaptureConfiguration` (API 29+); **nunca o microfone físico** | Adicionar trilha de áudio ao clipe de vídeo | Arquivo AAC intermediário local, apagado após mux (mantido só em builds debug para diagnóstico) | Nenhuma | Intermediário: até o fim do mux (segundos); final: embutido no MP4 até exclusão | Excluir o clipe no Apex Studio; desinstalar | **Coletado: Não** (processamento e armazenamento locais) |
| Card/vídeo exportado (Apex Studio, `Media3 Transformer`) | Composição local a partir dos itens acima | Gerar arquivo pronto para compartilhamento manual | Arquivo local; acesso temporário via `FileProvider` ao app de destino escolhido pelo usuário | Nenhuma pelo código do app — se o usuário optar por compartilhar, a transmissão final é feita pelo app de destino que ele mesmo escolhe na folha nativa do Android, fora da visibilidade e do controle do Apex Booster+ | Até o usuário excluir ou desinstalar | Excluir manualmente; desinstalar | **Coletado: Não** (processamento local); compartilhamento, quando ocorre, é ação do próprio usuário via mecanismo do sistema operacional, não uma transmissão iniciada pelo app |
| Estado do Modo Foco / Não Perturbe (DND) | `ACCESS_NOTIFICATION_POLICY`, opt-in | Ativar Modo Foco Gamer | Estado do sistema, não persistido pelo app além de refletir a UI | Nenhuma | N/A | Revogar permissão nas configurações do Android | **Coletado: Não** (processamento local) |
| **Apex Ping (latência de rede)** | Ver seção dedicada abaixo | Ver seção dedicada abaixo | Ver seção dedicada abaixo | **Sim — real** | Ver seção dedicada abaixo | N/A | **PENDENTE DE CONFIRMAÇÃO** — ver seção dedicada |
| **Histórico de compras** | N/A — sem Billing interno | N/A | N/A | Nenhuma (código do app) | N/A | N/A | **Não aplicável** — app pago para download, sem compra in-app (MONETIZATION-PAID-U1; ver seção dedicada) |

---

## Apex Ping — detalhamento completo — PENDENTE DE CONFIRMAÇÃO

Não é correto afirmar "nenhuma transmissão externa" para o app: o Apex Ping
realiza uma requisição de rede real, para fora do dispositivo, mesmo sem
carregar dados pessoais no payload.

| Campo | Valor |
|---|---|
| **Transmissão externa** | **Sim.** |
| **Endpoint primário** | `https://clients3.google.com/generate_204` |
| **Endpoint de fallback** | `https://connectivitycheck.gstatic.com/generate_204` (usado somente se o primário retornar erro genérico — não em caso de timeout) |
| **Finalidade** | Verificação pontual de conectividade — medir o tempo de round-trip de uma requisição HTTP simples, para calcular uma métrica local de latência ("Latência Apex") exibida ao usuário. Não é o ping real de nenhum servidor de jogo. |
| **Método HTTP observado no código** | `HEAD` (sem corpo de requisição) |
| **Dados enviados no payload** | Nenhum. O código (`DeviceMetricsDatasource._probeEndpoint`) não adiciona nenhum identificador de app, usuário ou dispositivo à requisição. Nenhum vídeo, áudio, captura de tela, clipe, preferência, dado da biblioteca de jogos ou conteúdo inserido pelo usuário é deliberadamente enviado nessa requisição. |
| **Cabeçalhos relevantes** | Apenas os cabeçalhos HTTP padrão gerados automaticamente pelo `HttpClient` do Dart/Android para uma requisição `HEAD` (tipicamente `Host`, `Connection`, `Accept-Encoding`, `User-Agent` do sistema). **Não verificado por captura de tráfego real (proxy/MITM) nesta sessão** — a afirmação acima é inferida da leitura do código-fonte, que não define nenhum cabeçalho customizado, não de uma inspeção do tráfego de rede efetivo. |
| **IP e metadados de conexão** | Qualquer requisição de rede expõe ao destinatário, por natureza do protocolo TCP/IP, o endereço IP público do dispositivo e metadados padrão da conexão — isso não é adicionado pelo código do app, é inerente a qualquer conexão de rede. Esses dados **podem ser observados pela infraestrutura** do Google que recebe a requisição. A classificação exata no formulário Data Safety (se conta como "identificador de dispositivo") **não foi confirmada nesta sessão** contra a orientação oficial do Google. |
| **Uso do resultado pelo app** | O Apex usa o resultado (um número em milissegundos) apenas em memória, para exibir a verificação de conectividade na tela, e não o persiste localmente — não é salvo em `SharedPreferences` nem em arquivo. Isso é um fato sobre o app, não sobre o terceiro: **não comprova** como o Google processa ou retém o IP e os metadados da conexão recebidos por ele. |
| **Retenção e processamento pelo terceiro (Google)** | **NÃO CONFIRMADOS.** O Apex não controla nem tem visibilidade sobre os logs de servidor do endpoint público `generate_204`. Não deve ser afirmado que o Google "não retém" nada, nem que o processamento do lado do Google é efêmero — nenhuma das duas hipóteses foi verificada. Retenção pelo terceiro e possível processamento efêmero pelo terceiro permanecem **NÃO CONFIRMADOS**. |
| **Classificação final no Data Safety** | **PENDENTE DE CONFIRMAÇÃO.** Há transmissão externa real (endpoint de terceiro, fora do dispositivo), mesmo sem payload de dado pessoal identificável enviado pelo app. Antes de preencher o formulário oficial, é preciso confirmar contra a orientação oficial do Google Play se essa transmissão (IP + metadados padrão de conexão, sem payload de app) exige marcação de alguma categoria (ex.: "identificadores de dispositivo" ou "outras informações") ou se basta declarar o uso da permissão `INTERNET`. Não classificar como "Coletado: Não" nem como "Coletado: Sim" por suposição — ambas seriam prematuras sem essa confirmação. |

---

## Histórico de compras — RESOLVIDO (MONETIZATION-PAID-U1, 30/07/2026)

> **Histórico:** esta seção documentava um item **PENDENTE DE CONFIRMAÇÃO**
> sobre `com.android.billingclient:billing:7.1.1` (via `in_app_purchase`),
> com quatro perguntas em aberto sobre o que `PurchaseService` lia do objeto
> `PurchaseDetails` e como o Google Play Console classificaria "Purchase
> history" para o produto `apex_full_unlock`. Essas perguntas ficam
> preservadas abaixo como registro — todas se tornaram **inaplicáveis**, não
> respondidas, porque o Billing interno foi removido do código nesta fase.

**Situação atual:** o Apex Booster+ não integra mais `in_app_purchase` nem
`com.android.billingclient:billing` — confirmado por ausência total em
`pubspec.lock`, `.flutter-plugins-dependencies`, `gradlew :app:dependencies`
e no manifest mesclado (debug/release, sem `com.android.vending.BILLING`).
Os arquivos `lib/core/billing/`, `lib/presentation/screens/unlock/` e o
cache `ApexUnlockCacheService`/`apex_unlock_purchased` foram deletados. O
app é pago para download: a compra é processada inteiramente pela Google
Play na instalação, sem qualquer código de Billing, histórico de transação
ou entitlement local no app.

**Classificação Data Safety:** **Não aplicável / Não coletado** — não há
mais "Purchase history" a classificar, pois não existe Billing interno.

<details>
<summary>Perguntas originais (registro histórico, não mais aplicáveis)</summary>

1. Quais dados de compra o Apex recebia do `PurchaseDetails` (campos lidos vs. campos apenas presentes em memória).
2. Se esses dados ficavam somente no dispositivo.
3. Se algum token, histórico ou identificador de compra era enviado pelo app para fora do aparelho.
4. Qual orientação oficial do Google Play se aplicava à versão 7.1.1 da Billing Library para fins de "Purchase history".

Nenhuma dessas perguntas precisa mais de resposta: o código e a dependência que as motivavam não existem mais no app.
</details>

---

## Perguntas principais do formulário Data Safety

| Pergunta Play Console | Resposta preliminar | Justificativa |
|---|---|---|
| O app coleta dados dos usuários? | **Não, para os itens processados localmente** (biblioteca, histórico, capturas, clipes, áudio interno, mídia importada). **Pendente de confirmação** apenas para o Apex Ping (transmissão externa real, sem payload de dado pessoal) — ver seção dedicada acima. Não há mais item de Billing/compra a confirmar (removido, MONETIZATION-PAID-U1). | Nenhum dos itens locais é transmitido para fora do dispositivo; só o Apex Ping depende de confirmação adicional antes de responder com segurança. |
| O app compartilha dados com terceiros? | **Não** | Sem backend próprio, sem SDK de ads/analytics/atribuição. |
| O app usa criptografia em trânsito? | **Sim** | TLS/HTTPS padrão do sistema para a única comunicação de rede que existe (Apex Ping). |
| O app permite exclusão de dados pelo usuário? | **Sim** | "Limpar histórico" e exclusão individual de capturas/clipes no Apex Studio; desinstalação remove tudo o que é local. Não há status de compra interna a restaurar ou excluir. |

---

## Itens pendentes de confirmação antes da submissão final

1. **Republicação do site:** os três arquivos `privacy/index.html`, `privacy/en/index.html` e `privacy/es/index.html` precisam ser enviados (`git push`) para o GitHub Pages.
2. **Preenchimento real no Play Console:** esta matriz é preliminar/interna — o formulário oficial precisa ser preenchido manualmente com base nela.
3. ~~Histórico de compra (Billing)~~ — **RESOLVIDO (MONETIZATION-PAID-U1):** Billing interno removido do código; item não é mais aplicável (ver seção dedicada acima).
4. **Cabeçalhos HTTP do Apex Ping:** descritos por inferência do código-fonte, não por captura de tráfego real — recomenda-se validar com uma ferramenta de proxy (ex. mitmproxy) antes da submissão final, se for exigido maior rigor.
5. **Classificação de IP address no Apex Ping:** não confirmado contra a orientação oficial do Google se a exposição inerente do IP a um endpoint de terceiro exige menção como "identificador de dispositivo" no formulário.
6. **Divulgação pré-permissão dentro do app (MediaProjection/RECORD_AUDIO):** a folha de consentimento atual (`CaptureConsentSheet`) explica o Botão Flutuante, mas não antecipa os diálogos nativos subsequentes de gravação de tela e microfone. **Mantido como bloqueador documentado para uma microfase de UI separada — não alterado aqui.**

---

*Documento interno — AllAppsEngineer. Não publicar como formulário oficial sem preenchimento manual na Play Console e sem resolver os itens pendentes acima.*

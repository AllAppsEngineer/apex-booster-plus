# Política de Privacidade — Apex Booster+

**Última atualização:** 28 de julho de 2026 (v2 — inclui captura de tela, áudio interno do jogo, Apex Studio e desbloqueio único)

> Este documento é a fonte interna da política publicada em `privacy/index.html`
> (PT-BR), `privacy/en/index.html` (EN) e `privacy/es/index.html` (ES). As três
> páginas devem ser mantidas equivalentes em conteúdo — ver changelog na
> seção 17.

---

## 1. Identificação do Responsável

**Nome do app:** Apex Booster+
**Desenvolvedor / Responsável:** AllAppsEngineer
**Contato oficial:** alessandro.lopes.adm@gmail.com

---

## 2. Dados Armazenados Localmente no Dispositivo

O Apex Booster+ **não possui servidor próprio**. Os dados abaixo ficam armazenados exclusivamente no dispositivo do usuário, via `SharedPreferences` do Android, e **nunca são enviados para fora dele**:

| Dado | Finalidade |
|---|---|
| Biblioteca de jogos adicionados | Exibir e gerenciar a lista de jogos do usuário |
| `packageName` dos jogos | Identificar e abrir o app correspondente |
| Perfil GFX local por jogo | Salvar preferência visual escolhida pelo usuário |
| Histórico de sessões | Exibir sessões anteriores e métricas locais |
| Idioma selecionado | Manter a preferência de idioma entre sessões |
| Flag de onboarding concluído | Evitar exibir o tutorial na reabertura do app |
| Preferência de Modo Baixa Distração | Reduzir animações, brilho e haptics quando ativado |
| Estado do Botão Flutuante Apex (ativado/desativado) | Lembrar se o usuário optou por manter o atalho de captura ativo |
| Estado local do desbloqueio único | Cache do status de compra — ver seção 8 |

Esses dados **não são sincronizados, vendidos ou compartilhados** com terceiros.

---

## 3. Leituras Locais do Dispositivo

O app realiza as seguintes leituras **locais** para fins informativos:

- **RAM disponível e total:** leitura da memória do dispositivo para exibir snapshot da sessão. Nunca sai do aparelho.
- **Latência básica de rede (Apex Ping):** o app envia uma requisição de rede simples (HTTP HEAD) a um endereço público de checagem de conectividade do Google (`clients3.google.com/generate_204`, com `connectivitycheck.gstatic.com/generate_204` como alternativa) apenas para medir o tempo de resposta. Nenhum dado pessoal é enviado além dos cabeçalhos HTTP padrão do sistema, e o resultado é usado só para exibição em tela. **Não representa nem promete o ping real de servidores de jogos externos.** Nenhum vídeo, áudio, captura de tela, clipe, preferência, dado da biblioteca de jogos ou conteúdo inserido pelo usuário é enviado nessa requisição. Como em qualquer conexão de rede, o endereço IP e metadados padrão da conexão podem ser observados pela infraestrutura de destino; a retenção desses dados pelo terceiro (Google) não é controlada nem confirmada pelo Apex Booster+.
- **Estado do Modo Foco / Não Perturbe (DND):** verificado apenas quando o usuário concede a permissão `ACCESS_NOTIFICATION_POLICY`. Não ativado automaticamente.

Essas leituras **não geram dado pessoal enviado a servidor** — a única comunicação de rede do app é a checagem de latência acima.

---

## 4. Uso de Internet

O app utiliza a permissão `INTERNET` para o teste básico de latência/conectividade (seção 3) e, indiretamente, para o processamento de compra via Google Play Billing (seção 8). Nenhuma outra comunicação de rede é realizada pelo código do app.

---

## 5. Apps Instalados

Para permitir que o usuário selecione jogos da sua biblioteca de apps instalados, o Apex Booster+ pode listar apps iniciáveis disponíveis no dispositivo (via `intent` `MAIN`/`LAUNCHER`).

- **Sem `QUERY_ALL_PACKAGES`:** o app não solicita acesso irrestrito à lista de apps.
- **Sem envio externo:** a lista de apps instalados **nunca é enviada para servidores**.
- **Controle do usuário:** o usuário decide quais apps adicionar à biblioteca. O app não faz varredura automática nem exporta dados.

---

## 6. Apex Studio — Captura de Tela, Clipes de Vídeo e Mídia da Galeria

O **Apex Studio** é o recurso de criação de conteúdo social do app. Ele oferece três formas de obter mídia, todas iniciadas explicitamente pelo usuário.

### 6.1 Importação da galeria

O usuário pode selecionar voluntariamente uma imagem ou vídeo já existente no dispositivo, através do seletor de mídia nativo do Android (`image_picker`). O arquivo é lido apenas em memória, durante a sessão, para pré-visualização e composição do card — nunca é enviado a servidores e não é salvo nas preferências do app.

### 6.2 Captura de tela e clipes de vídeo (Botão Flutuante Apex)

Com o Botão Flutuante Apex ativado (opcional — ver seção 8), o usuário pode capturar um print da tela ou gravar um clipe de vídeo curto (10 a 60 segundos) da própria sessão de jogo. Esse recurso usa a API MediaProjection do Android, que exige confirmação explícita do usuário em uma tela de consentimento do próprio sistema operacional antes de qualquer captura começar, e mantém uma notificação persistente enquanto a captura está ativa.

| Item | Esclarecimento |
|---|---|
| Áudio interno do jogo (opcional, só em vídeos) | Quando disponível, o app captura o áudio reproduzido pelo próprio jogo/app durante a gravação (`AudioPlaybackCaptureConfiguration`, Android 10+). **Não é o microfone do aparelho** — nenhuma voz ou som ambiente é captado. A permissão `RECORD_AUDIO` é exigida pela API do Android para esse recurso por uma particularidade da plataforma; o microfone físico nunca é lido nessa configuração. |
| Quando o áudio não está disponível | Alguns jogos bloqueiam a captura de áudio interno por política própria. O vídeo é salvo normalmente sem áudio, e o app exibe um aviso orientando o usuário a gravar externamente (gravador de tela do próprio aparelho) e importar o vídeo pela galeria (seção 6.1). |
| Armazenamento | Pasta específica do Apex Booster+ dentro do armazenamento do próprio app (não uma galeria pública compartilhada), com índice local (`index.json`) usado apenas para listar arquivos dentro do Apex Studio. |
| Transmissão | Nenhuma. Nenhum print, clipe ou áudio é enviado a servidores em nenhuma circunstância. |

### 6.3 Exportação e compartilhamento

O Apex Studio permite compor um card visual (imagem ou vídeo com moldura Apex) a partir da mídia selecionada ou capturada. Toda a composição — incluindo a exportação de vídeo — acontece **localmente no dispositivo**, sem etapa de processamento em servidor.

- **Compartilhamento sempre manual:** a publicação só ocorre quando o usuário toca em "Compartilhar" e escolhe o destino na folha de compartilhamento nativa do Android. O app **nunca publica ou posta automaticamente** em nenhuma rede social.
- **Acesso temporário e restrito:** o arquivo exportado é disponibilizado ao app de destino escolhido pelo usuário através de um `FileProvider` com permissão temporária — nenhum outro app tem acesso a ele.

---

## 7. Dados NÃO Coletados

O Apex Booster+ **não coleta** nenhum dos seguintes dados:

- Nome, e-mail ou qualquer identificador pessoal.
- Localização precisa ou aproximada.
- Contatos, mensagens, chamadas ou dados de comunicação.
- Áudio do microfone físico ou de conversas.
- Número de cartão, dados bancários ou de pagamento.
- Dados biométricos ou identificadores de publicidade.
- Dados de uso detalhado de apps (sem `PACKAGE_USAGE_STATS`).

Fotos, vídeos e áudio interno de jogo **só são acessados quando o próprio usuário aciona, de forma explícita, a importação da galeria ou a captura descrita na seção 6** — nunca automaticamente, e nunca enviados para fora do dispositivo.

---

## 8. Botão Flutuante Apex (SYSTEM_ALERT_WINDOW)

O Botão Flutuante Apex é um atalho visual opcional exibido sobre outros apps durante a sessão de jogo, usado exclusivamente para abrir rapidamente a captura de tela/vídeo descrita na seção 6.

- **Opt-in explícito:** desligado por padrão. Só é solicitado quando o usuário ativa o recurso em Configurações, com uma explicação prévia dentro do app antes de abrir a tela de permissão do sistema.
- **Reversível a qualquer momento:** o usuário pode desativar o botão em Configurações, o que remove o atalho da tela imediatamente.
- **Sem coleta de dados:** o botão não lê, registra ou transmite nada por si só — ele apenas abre o fluxo de captura descrito acima.

---

## 9. Desbloqueio Único (Google Play Billing)

O Apex Booster+ usa o modelo **free install + desbloqueio único** (sem assinatura, sem anúncios). A compra é processada inteiramente pela biblioteca oficial **Google Play Billing**, que comunica diretamente com os servidores do Google Play — o app **nunca vê nem armazena** número de cartão, dados bancários ou informações de pagamento.

- **O que o app recebe:** apenas uma confirmação do Google Play informando se a compra foi concluída ou restaurada. Essa confirmação é espelhada localmente em um valor booleano (comprado/não comprado) no `SharedPreferences` do dispositivo.
- **Sem histórico de transação no app:** o Apex Booster+ não mantém registro de valores, datas de cobrança ou método de pagamento — esse histórico fica exclusivamente na conta Google Play do usuário.

---

## 10. Compartilhamento de Dados com Terceiros

O Apex Booster+ **não vende, não aluga e não compartilha dados pessoais** com anunciantes, parceiros ou terceiros.

Não há:
- SDK de anúncios.
- SDK de analytics de terceiros (ex.: Firebase Analytics, Mixpanel, Amplitude).
- Rastreamento de comportamento para fins publicitários.
- Postagem ou publicação automática em redes sociais.

A biblioteca oficial Google Play Billing (usada apenas para o desbloqueio único, seção 9) inclui, como parte de seu próprio funcionamento interno, componentes padrão do Google Play Services para diagnóstico da própria biblioteca (confirmado via `gradlew :app:dependencies`: `com.android.billingclient:billing:7.1.1` traz transitivamente `com.google.android.datatransport:*` e `com.google.android.gms:play-services-location/places-placereport`). Esses componentes não são configurados nem usados pelo código do Apex Booster+ para qualquer finalidade de analytics, publicidade ou rastreamento — em particular, a app **não solicita nem declara nenhuma permissão de localização**, o que torna as classes de Play Services Location presentes no bytecode inertes (sem acesso real a dados de localização).

---

## 11. Permissões Utilizadas

| Permissão | Finalidade |
|---|---|
| `INTERNET` | Teste básico de latência (Apex Ping) e processamento de compra via Google Play Billing |
| `ACCESS_NOTIFICATION_POLICY` | Modo Foco Gamer (Não Perturbe) — somente quando o usuário concede |
| `SYSTEM_ALERT_WINDOW` | Botão Flutuante Apex — somente após ativação explícita nas Configurações (seção 8) |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PROJECTION` | Mantêm a captura de tela/vídeo visível ao usuário via notificação persistente enquanto ativa |
| `FOREGROUND_SERVICE_MICROPHONE` | Declarada apenas durante uma gravação de vídeo com áudio interno do jogo (seção 6.2) — nunca para captar o microfone físico |
| `RECORD_AUDIO` | Exigida pela API Android para captura de áudio interno do jogo (seção 6.2); o microfone físico nunca é lido |
| `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `com.android.vending.BILLING` | Trazidas pela biblioteca oficial Google Play Billing (seção 9) para o funcionamento da compra — não usadas diretamente pelo código do app |

**Acesso à galeria / mídia:** o Apex Studio utiliza o seletor de mídia nativo do Android (`image_picker`). Esse seletor não requer declaração de permissão de armazenamento adicional. O app **não solicita acesso permanente à galeria**.

Nenhuma outra permissão sensível é solicitada nesta versão.

---

## 12. Retenção e Exclusão de Dados

- **Biblioteca, histórico e preferências:** "Limpar histórico" em Configurações remove as sessões salvas; desinstalar o app apaga todos os dados locais do `SharedPreferences`.
- **Capturas de tela e clipes de vídeo:** excluíveis individualmente pelo usuário dentro do Apex Studio; desinstalar o app remove toda a pasta associada.
- **Mídia importada da galeria:** descartada da memória do app assim que a tela do Studio é fechada.
- **Status de desbloqueio:** removido ao desinstalar o app; restaurável a qualquer momento pelo botão "Restaurar compra", que consulta novamente o Google Play.

Como o Apex Booster+ não possui servidor próprio, não há retenção de dados fora do dispositivo do usuário.

---

## 13. Limites e Avisos Importantes

- O Apex Booster+ **não altera jogos de terceiros automaticamente**.
- O app **não promete melhoria real de FPS, GPU, resolução, ping ou desempenho** de jogos externos.
- As métricas exibidas (RAM, latência Apex) são **locais e informativas** — não representam alteração automática do dispositivo ou dos jogos.
- O Modo Foco Gamer ativa o Não Perturbe do Android somente quando o usuário concede a permissão explicitamente.
- A captura de tela, o áudio interno e o botão flutuante são recursos de expressão gamer e organização pessoal — não vantagem competitiva em jogo.

---

## 14. Segurança dos Dados

Os dados de preferências e histórico ficam protegidos pelo sandbox de app do Android e pela criptografia do sistema de arquivos do dispositivo. Capturas de tela e clipes ficam em pasta específica do app, não acessível a outros apps sem permissão explícita do usuário. As duas únicas comunicações de rede do app — teste de latência (seção 3) e processamento de compra via Google Play Billing (seção 9) — usam conexão criptografada padrão (HTTPS/TLS) do sistema operacional.

---

## 15. Crianças

O Apex Booster+ **não é direcionado a crianças menores de 13 anos** e não coleta conscientemente dados de menores.

---

## 16. Contato

Para dúvidas, solicitações de exclusão de dados (aplicável a dados locais no dispositivo) ou qualquer questão relacionada à privacidade:

**E-mail de contato:** alessandro.lopes.adm@gmail.com

---

## 17. Alterações nesta Política

| Versão | Data | Alteração |
|---|---|---|
| v1 | 04/06/2026 | Publicação inicial (nunca sincronizada 1:1 com o HTML publicado — ver nota abaixo) |
| v2 | 28/07/2026 | Reescrita completa para sincronizar com o app real: adicionadas seções sobre captura de tela, áudio interno do jogo, botão flutuante, exportação de vídeo e desbloqueio único; corrigidas referências que descreviam esses recursos como "futuros" quando já estavam implementados e validados em aparelho físico; corrigido e-mail de contato divergente do site publicado; tabela de permissões completada com base no manifest mesclado (`AndroidManifest.xml` debug/release) e na árvore de dependências Gradle. |

**Nota de auditoria (PRIVACY-SYNC-U1):** a versão v1 deste arquivo divergia do HTML publicado em `privacy/index.html` (e-mail de contato diferente, texto ligeiramente diferente) e ambos estavam desatualizados frente ao app real. Esta v2 sincroniza os três arquivos HTML publicados (`privacy/index.html`, `privacy/en/index.html`, `privacy/es/index.html`) e este documento-fonte para que descrevam exatamente o mesmo conteúdo, e para que esse conteúdo reflita o app tal como ele existe hoje.

Esta política pode ser atualizada antes ou após a publicação na Play Store. A data de "Última atualização" no topo do documento refletirá a versão vigente.

---

*Esta política foi elaborada para o Apex Booster+ — desenvolvido por AllAppsEngineer.*

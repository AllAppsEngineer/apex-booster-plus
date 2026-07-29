# Notas para Play Console — Apex Booster+

Este documento é um guia interno para preenchimento da **Política de Privacidade** e da **seção de segurança de dados (Data Safety)** na Play Store Console antes da publicação.

**Última sincronização:** 28/07/2026 (PRIVACY-SYNC-U1) — ver matriz completa em
`store_assets/copy/data_safety_preliminar.md`.

---

## URL da Política de Privacidade

**Status:** publicada e já linkada no app (tela Sobre, Configurações).

| Idioma | URL |
|---|---|
| PT-BR | https://allappsengineer.github.io/apex-booster-plus/privacy/ |
| EN-US | https://allappsengineer.github.io/apex-booster-plus/privacy/en/ |
| ES | https://allappsengineer.github.io/apex-booster-plus/privacy/es/ |

**Pendente:** o conteúdo foi reescrito nesta sessão (PRIVACY-SYNC-U1) para
refletir captura de tela, áudio interno, botão flutuante, exportação de vídeo
e desbloqueio único. As três páginas ainda precisam ser **republicadas no
GitHub Pages** (push do commit) e **retestadas no app** (link abre a URL
correta no idioma correspondente) antes de considerar este item fechado.

---

## Resumo para Seção "Segurança de Dados" (Data Safety) na Play Console

**Critério aplicado (correção pós-revisão):** o Google Play define "coleta"
como dado **transmitido para fora do dispositivo** — não o simples fato de o
app ler/processar um arquivo localmente. Dados que nunca saem do aparelho
(capturas de tela, áudio interno, vídeos importados, clipes, `index.json`,
`SharedPreferences`, histórico de sessões) devem ser marcados **"Coletado:
Não"** no formulário Data Safety, mesmo continuando descritos em detalhe na
Política de Privacidade — que tem um padrão de transparência mais amplo do
que a definição estrita do formulário.

Ver a matriz auditável completa (dado × origem × finalidade × armazenamento ×
transmissão × retenção × exclusão × declaração preliminar) em
`store_assets/copy/data_safety_preliminar.md`. Resumo executivo:

| Categoria Play Console | Coletado? | Compartilhado? | Observação |
|---|---|---|---|
| Dados pessoais (nome, e-mail) | Não | Não | — |
| Localização | Não | Não | Nenhuma permissão de localização declarada; classes de Play Services Location trazidas transitivamente pelo Play Billing ficam inertes. |
| Contatos | Não | Não | — |
| Fotos e vídeos (Apex Studio: galeria, capturas de tela, clipes) | **Não** — processamento e armazenamento somente no dispositivo, nunca transmitidos | Não | Descrito em detalhe na seção 6 da política; ver matriz para o raciocínio completo. |
| Arquivos de áudio (áudio interno do jogo em clipes de vídeo) | **Não** — processamento e armazenamento somente no dispositivo | Não | Nunca é o microfone físico; nunca transmitido. |
| Atividade do app (biblioteca, histórico, GFX, idioma) | Não | Não | Local via `SharedPreferences`, nunca transmitido. |
| Informações do dispositivo (RAM) | Não | Não | Lido e exibido localmente, nunca transmitido. |
| Apex Ping (latência de rede) | **PENDENTE DE CONFIRMAÇÃO** | Não | **Há transmissão externa real** — requisição HTTP `HEAD` para `clients3.google.com/generate_204` (fallback `connectivitycheck.gstatic.com/generate_204`), finalidade de verificação pontual de conectividade. Nenhum vídeo, áudio, captura, preferência, biblioteca ou conteúdo do usuário é deliberadamente enviado, mas IP e metadados padrão da conexão podem ser observados pela infraestrutura do Google, e a retenção pelo terceiro não é controlada nem confirmada pelo Apex. Não marcar "Coletado: Não" nem "Sim" sem confirmar a orientação oficial do Google — ver detalhamento dedicado na matriz. |
| Histórico de compras (desbloqueio único) | **PENDENTE DE CONFIRMAÇÃO** | Pendente | Não marcar automaticamente "Sim" só pela presença da Google Play Billing Library — ver seção "Itens pendentes" abaixo e a matriz para as perguntas exatas em aberto. O app **não recebe número de cartão nem dados bancários** em nenhuma hipótese — isso é garantido pela arquitetura do Play Billing, independente da classificação final. |
| Identificadores de dispositivo | Não | Não | — |
| Diagnósticos | Não | Não | Sem Crashlytics nesta versão. |

### Práticas de segurança

- Os dados são criptografados em trânsito? **Sim** — as duas comunicações de rede que o app efetivamente realiza (Apex Ping e o fluxo do Google Play Billing) usam HTTPS/TLS padrão do sistema.
- O usuário pode solicitar exclusão dos dados? **Sim** — "Limpar histórico" remove sessões; exclusão individual de capturas/clipes no Apex Studio; desinstalar o app remove todo o restante local. Dados eventualmente associados à compra ficam sob controle da conta Google Play do usuário, fora do app.

---

## Permissões para declarar na Play Console

| Permissão | Declarar? | Justificativa |
|---|---|---|
| `INTERNET` | Sim | Apex Ping + comunicação do Google Play Billing |
| `ACCESS_NOTIFICATION_POLICY` | Sim | Modo Foco Gamer (DND) — somente com permissão explícita do usuário |
| `SYSTEM_ALERT_WINDOW` | Sim | Botão Flutuante Apex — opt-in, ativado nas Configurações |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PROJECTION` | Sim | Captura de tela/vídeo em primeiro plano com notificação persistente |
| `FOREGROUND_SERVICE_MICROPHONE` | Sim | Somente durante gravação de vídeo com áudio interno do jogo |
| `RECORD_AUDIO` | Sim | Exigida pela API de captura de áudio interno (`AudioPlaybackCaptureConfiguration`); nunca lê o microfone físico — a Play Console pode pedir uma explicação textual para isso na seção de permissões sensíveis |
| `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `com.android.vending.BILLING` | Sim | Trazidas pela biblioteca Google Play Billing; não usadas diretamente pelo app |

---

## Checklist antes da publicação

- [x] Definir e-mail de contato oficial de privacidade (alessandro.lopes.adm@gmail.com — corrigido nesta sessão; havia divergência com o doc-fonte antigo).
- [x] Hospedar a política de privacidade em URL pública permanente.
- [ ] Republicar (`git push`) as páginas atualizadas de `privacy/` no GitHub Pages.
- [ ] Inserir/confirmar a URL na Play Console (campo "Política de Privacidade").
- [ ] Preencher a seção "Segurança de Dados" (Data Safety) com base em `store_assets/copy/data_safety_preliminar.md`.
- [x] Atualizar a data "Última atualização" no arquivo `PRIVACY_POLICY_APEX_BOOSTER_PT_BR.md` e nas três páginas HTML.
- [x] Revisar permissões novas desde a última versão da política (captura de tela, áudio interno, botão flutuante, billing).
- [x] Confirmar que nenhum SDK de anúncios ou analytics próprio foi adicionado (Play Billing traz componentes internos do Google para diagnóstico da própria biblioteca — não é analytics do app; ver seção 10 da política).
- [x] Confirmar que o Apex Studio usa apenas o seletor nativo do Android para importação de galeria (sem `READ_MEDIA_IMAGES` declarada).
- [ ] Testar o link da política de privacidade dentro do app (Sobre → idioma correto) após a republicação.
- [ ] Revisar se a divulgação pré-permissão dentro do app (antes das telas de consentimento MediaProjection/RECORD_AUDIO) precisa de reforço — **ver observação abaixo, tratado como item separado, sem alteração de UI nesta fase.**

---

## Itens pendentes de confirmação (não resolvidos nesta sessão)

### Histórico de compras (Google Play Billing)

Registrado como **PENDENTE DE CONFIRMAÇÃO** no formulário Data Safety até que
se comprove, especificamente para `com.android.billingclient:billing:7.1.1`
(versão confirmada via `gradlew :app:dependencies`):

1. Quais dados de compra o Apex efetivamente recebe do `PurchaseDetails` (o código em `PurchaseService` só lê `productID` e `status`, mas o objeto entregue pela biblioteca também contém `purchaseID`, `transactionDate` e `verificationData` — não usados pelo app, mas presentes em memória).
2. Se esses dados ficam somente no dispositivo ou se em algum momento passam por um servidor que não seja o do próprio Google Play (não há indício de backend próprio no código — mas isso deve ser confirmado, não presumido).
3. Se o app transmite, por conta própria, algum token, histórico ou identificador de compra para fora do aparelho (resposta atual, baseada em leitura do código: **não** — `PurchaseService` não faz nenhuma chamada de rede própria; toda comunicação de billing é feita pela biblioteca do Google, não pelo código do Apex).
4. Qual é a orientação oficial do Google Play Console para declaração de "Purchase history" quando o app usa exclusivamente a biblioteca oficial sem backend próprio — isto não foi verificado na documentação oficial do Google nesta sessão e não deve ser presumido.

**O que já pode ser afirmado com segurança, independentemente da classificação final:** o Apex Booster+ **não recebe nem armazena** número de cartão, dados bancários ou credenciais de pagamento em nenhuma circunstância — isso é garantido pela arquitetura do Google Play Billing (o app nunca tem acesso a esses dados, apenas a um resultado de compra).

### Apex Ping — transmissão de rede — PENDENTE DE CONFIRMAÇÃO

Não é correto afirmar "nenhuma transmissão externa" para o app como um todo:
o Apex Ping realiza uma requisição de rede real, para fora do dispositivo.

- **Transmissão externa:** Sim.
- **Finalidade:** verificação pontual de conectividade (cálculo local de latência exibido ao usuário).
- **Endpoints identificados:** `clients3.google.com/generate_204` (primário) e `connectivitycheck.gstatic.com/generate_204` (fallback).
- **Método observado no código:** `HEAD`.
- Nenhum vídeo, áudio, captura, preferência, biblioteca ou conteúdo inserido pelo usuário é deliberadamente enviado nessa requisição.
- IP e metadados padrão da conexão podem ser observados pela infraestrutura de destino, por natureza de qualquer conexão de rede.
- O Apex usa o resultado (número em milissegundos) apenas em memória para verificar conectividade e não o persiste localmente — isso é um fato sobre o app, não comprova como o Google processa ou retém o IP e os metadados da conexão recebidos por ele.
- Retenção e possível processamento efêmero pelo terceiro (Google): **NÃO CONFIRMADOS**.
- **Classificação final no Data Safety: PENDENTE DE CONFIRMAÇÃO** — não marcar "Coletado: Não" nem "Sim" por suposição.

Ver detalhamento completo (endpoint, finalidade, dados enviados, cabeçalhos,
transmissão, retenção e classificação) em
`store_assets/copy/data_safety_preliminar.md`.

---

## Observação aberta — divulgação pré-permissão dentro do app

O app já exibe uma folha de consentimento (`CaptureConsentSheet`) antes de
solicitar a permissão de sobreposição (`SYSTEM_ALERT_WINDOW`) para o Botão
Flutuante Apex, explicando a finalidade do recurso. Essa mesma folha **não**
menciona explicitamente que, ao gravar um clipe de vídeo, o sistema também
solicitará (a) o diálogo de consentimento de gravação de tela do próprio
Android (MediaProjection) e (b) a permissão de microfone (`RECORD_AUDIO`,
usada apenas para o áudio interno do jogo). Hoje o usuário só é informado
sobre isso pelos próprios diálogos nativos do Android quando eles aparecem,
não por uma explicação prévia do app.

Isso **não bloqueia a política de privacidade nem o Data Safety** (ambos já
descrevem o comportamento real com precisão), mas é um bloqueador de UX/UI
para uma fase futura — não alterado aqui por estar fora do escopo desta
microfase (PRIVACY-SYNC-U1 é documentação, não UI).

---

## Observações estratégicas

- O modelo Free + one-time unlock (sem assinatura, sem anúncios) simplifica a seção de privacidade — não há dados de pagamento recorrente nem tracking para monetização.
- Firebase **não está configurado** nesta versão. Se for adicionado no futuro, a política precisa ser atualizada para cobrir Crashlytics/Analytics.
- Billing via `in_app_purchase`/Google Play Billing (desbloqueio único) não expõe dados financeiros ao app — apenas confirmação de status de compra. Já mencionado na política (seção 9) e na matriz de Data Safety.

---

*Documento interno — AllAppsEngineer. Não publicar como política oficial sem revisão.*

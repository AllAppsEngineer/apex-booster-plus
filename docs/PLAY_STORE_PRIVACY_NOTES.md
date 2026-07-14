# Notas para Play Console — Apex Booster+

Este documento é um guia interno para preenchimento da **Política de Privacidade** e da **seção de segurança de dados** na Play Store Console antes da publicação.

---

## URL da Política de Privacidade

**Status:** pendente — a URL pública precisa ser definida antes de submeter o app.

**Opções comuns (escolher uma antes de publicar):**
- GitHub Pages com o arquivo `PRIVACY_POLICY_APEX_BOOSTER_PT_BR.md` convertido em HTML.
- Página própria no site de AllAppsEngineer.
- Serviço como `sites.google.com` com o conteúdo da política.

> Sem URL pública, o app **não pode ser publicado** na Play Store.

---

## Resumo para Seção "Segurança de Dados" (Data Safety) na Play Console

### Dados coletados e compartilhados

| Tipo de dado | Coletado? | Compartilhado? | Observação |
|---|---|---|---|
| Dados pessoais (nome, e-mail) | Não | Não | — |
| Localização | Não | Não | — |
| Contatos | Não | Não | — |
| Fotos e vídeos (Apex Studio) | Sim — voluntário pelo usuário | Não | Seleção via picker nativo; processado localmente; não enviado |
| Arquivos e documentos | Não | Não | — |
| Atividade do app | Não enviado externamente | Não | Sessões salvas localmente |
| Informações do dispositivo | Não enviado externamente | Não | RAM/latência lidas localmente |
| Identificadores | Não | Não | — |
| Diagnósticos | Não | Não | Sem Crashlytics nesta versão |

### Práticas de segurança

- [ ] Os dados são criptografados em trânsito? **Não aplicável** — o app não transmite dados pessoais.
- [ ] O usuário pode solicitar exclusão dos dados? **Sim** — dados locais podem ser apagados via "Limpar histórico" no app ou desinstalando o app.

---

## Permissões para declarar na Play Console

| Permissão | Declarar? | Justificativa |
|---|---|---|
| `INTERNET` | Sim | Teste básico de conectividade (Apex Ping) — não coleta dados pessoais |
| `ACCESS_NOTIFICATION_POLICY` | Sim | Modo Foco Gamer (DND) — somente com permissão explícita do usuário |

---

## Checklist antes da publicação

- [ ] Definir e-mail de contato oficial de privacidade.
- [ ] Hospedar a política de privacidade em URL pública permanente.
- [ ] Inserir a URL na Play Console (campo "Política de Privacidade").
- [ ] Preencher a seção "Segurança de Dados" (Data Safety) com base neste documento.
- [ ] Atualizar a data "Última atualização" no arquivo `PRIVACY_POLICY_APEX_BOOSTER_PT_BR.md`.
- [ ] Revisar se alguma permissão nova foi adicionada desde a última versão da política.
- [ ] Confirmar que nenhum SDK de anúncios ou analytics foi adicionado.
- [ ] Confirmar que o Apex Studio usa apenas o seletor nativo do Android (sem permissão `READ_MEDIA_IMAGES` declarada explicitamente para esta fase).
- [ ] Confirmar que exportação de vídeo ainda não está disponível (declarar como recurso futuro na política).
- [ ] Testar o link da política de privacidade na Play Store antes de publicar.

---

## Observações estratégicas

- O modelo Free + one-time unlock (sem assinatura, sem anúncios) **simplifica significativamente** a seção de privacidade — não há dados de pagamento recorrente nem tracking para monetização.
- Firebase **não está configurado** nesta versão. Se for adicionado no futuro, a política precisa ser atualizada para cobrir Crashlytics e Analytics.
- Billing via `in_app_purchase` (desbloqueio único) não coleta dados pessoais além do que o Google Play gerencia diretamente — isso não requer seção adicional na política, mas deve ser mencionado se Billing for ativado.

---

*Documento interno — AllAppsEngineer. Não publicar como política oficial sem revisão.*

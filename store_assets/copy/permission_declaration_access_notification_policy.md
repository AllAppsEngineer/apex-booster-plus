# Declaração de Permissão — ACCESS_NOTIFICATION_POLICY

**Permissão:** `android.permission.ACCESS_NOTIFICATION_POLICY`
**Funcionalidade associada:** Modo Foco Gamer

---

## Texto para a Play Console (campo: Permission declaration / Justificativa)

### Português Brasil

O Modo Foco Gamer utiliza a permissão ACCESS_NOTIFICATION_POLICY para permitir que o
usuário ative ou desative o modo Não Perturbe do Android diretamente pelo app, como
parte voluntária da preparação da sessão gamer. A funcionalidade é opt-in, reversível
nas configurações e não afeta outras notificações além do período escolhido pelo usuário.

---

### English (usar nos formulários da Play Console)

The Gamer Focus Mode feature uses ACCESS_NOTIFICATION_POLICY to allow the user to
voluntarily enable or disable Android's Do Not Disturb mode directly within the app,
as part of their game session preparation. This feature is fully opt-in, reversible
at any time in Settings, and does not affect notifications beyond the user's chosen
session period. The app never modifies DND settings without explicit user action.

---

## Pontos críticos de compliance

- A funcionalidade é **opt-in**: o usuário precisa ativar manualmente.
- A funcionalidade é **reversível**: pode ser desativada nas Configurações.
- O app **nunca** ativa o modo Não Perturbe sem ação explícita do usuário.
- Se o fluxo atual ativar DND automaticamente sem confirmação, corrigir antes de submeter.

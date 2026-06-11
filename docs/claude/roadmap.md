# Roadmap Oficial — APEX BOOSTER+

> Arquivo auxiliar de `CLAUDE.md`. Não revoga nem substitui regras do arquivo principal.

Cada fase exige declaração prévia de arquivos prováveis, riscos, testes e evidências visuais quando houver UI. Não declarar fase como concluída sem evidência.

---

## Roadmap base (pendências críticas e alta prioridade)

| Ordem | Fase | Objetivo | Prioridade |
|---:|---|---|---|
| 1 | STORE-U1.2B | Publicar política de privacidade em URL real e ativar link no Sobre. | Crítica |
| 2 | LANG-U1.6 | Validar PT-BR/EN/ES em fluxo completo. | Alta |
| 3 | AUDIT-U1 | Rodar checklist e registrar evidências do estado atual. | Alta |
| 4 | UX-P1 | Implementar Motion/Placebo Visual controlado. | Alta |
| 5 | BOOST-U1 | Estruturar Boost Engine de 8 etapas honestas. | Alta |
| 6 | RESULT-U1 | Criar Prep Result e card compartilhável, se aprovado. | Média |
| 7 | DATA-U1 | Decidir Hive vs `shared_preferences` para MVP. | Alta |
| 8 | OBS-U1 | Decidir Crashlytics/Remote Config. | Alta |
| 9 | BILL-U1 | Implementar one-time unlock, restore e startup check. | Crítica para monetização |
| 10 | RELEASE-U1 | Build release, checklist Play Store, screenshots e submissão. | Crítica |

---

## Roadmap premium (camada memorável)

| Fase | Nome | Objetivo | Dependência | Evidência mínima |
|---|---|---|---|---|
| PREMIUM-U1 | Apex Visual System | Criar tokens/componentes Apex Core, Ring, Pulse, Grid e Status Chips | Design atual | Screenshots Home/Preparar/Resultado e teste de overflow. |
| PREMIUM-U2 | Apex Ritual Cinematográfico | Refinar Boost Apex em fluxo curto com etapas reais/simbólicas | PREMIUM-U1 | Vídeo ou sequência de screenshots + validação de copy. |
| PREMIUM-U3 | Apex Result Card | Criar card pós-preparo com jogo, perfil, tempo, status e CTA | PREMIUM-U2 | Screenshot de card e teste de abertura do jogo. |
| TRUST-U1 | Honest Booster Mode | Criar explicação clara sobre FPS, ping, RAM, unlock e limites técnicos | Strings/i18n | PT-BR/EN/ES validados. |
| PROFILE-U1 | Session Profiles | Expandir GFX para perfis Balanced, Focus, Visual, Battery Mindful e Custom | Persistência local | Teste de salvar/carregar por jogo. |
| RETENTION-U1 | Badges locais | Criar badges de uso, recorrência e variedade | Histórico | Teste de persistência local. |
| RETENTION-U2 | Resumo Semanal Local | Criar card "Sua semana gamer" | RETENTION-U1 | Dados locais coerentes e copy segura. |
| CONVENIENCE-U1 | Quick Actions | Atalhos do ícone do app | Navegação estável | Teste em aparelho/emulador Android. |
| CONVENIENCE-U2 | Widget Premium | Widget de favorito/última sessão | Favoritos estáveis | Screenshot do widget e teste de atualização. |
| SHARE-U1 | Share Card Seguro | Compartilhamento opcional do Result Card | PREMIUM-U3 | Arquivo/imagem gerado sem dados sensíveis. |
| THEME-U1 | Temas Contextuais | Tema visual por jogo/perfil | PREMIUM-U1 | Screenshots comparativos e validação de contraste. |
| ACCESS-U1 | Modo Baixa Distração | Reduzir animações, brilho, haptics e duração | Motion System | Toggle funcional e validação visual. |

---

## Roadmap social (Apex Social Capture & Share Layer)

A ordem abaixo deve ser respeitada, salvo aprovação humana explícita. Cada fase requer evidência visual antes de avançar.

| Fase | Nome | Objetivo | Evidência mínima |
|---|---|---|---|
| SOCIAL-U1 | Apex Share Studio | Criar editor de card com tema, legenda, badge e exportação local | Screenshots dos layouts 9:16 e 1:1. |
| SOCIAL-U2 | Apex Evolution Card | Criar cards com sessões, jogos favoritos, badges e streaks locais | Dados locais coerentes e copy validada. |
| SOCIAL-U3 | Importação da galeria | Permitir selecionar screenshot/clipe escolhido pelo usuário | Teste de seleção, cancelamento e exportação. |
| SOCIAL-U4 | Social Export Presets | Gerar 9:16, 1:1 e 16:9 | Verificação de cortes, margens e legibilidade. |
| SOCIAL-U5 | Privacy Guard | Criar telas de consentimento e revisão | Textos PT-BR, EN e ES. |
| SOCIAL-U6 | Apex Floating Capture Button | Implementar botão flutuante opt-in, móvel e desativável | Teste em Android e prova de não interferência. |
| SOCIAL-U7 | Short Clip Capture | Implementar captura curta assistida, se viável | Teste de permissão, cancelamento, arquivo e exportação. |

---

## Pendências oficiais consolidadas

| Bloco | Pendência | Prioridade |
|---|---|---:|
| Pré-store | Publicar Política de Privacidade em URL real e ativar link no Sobre | Crítica |
| Idioma | Validar PT-BR/EN/ES em fluxo completo | Alta |
| Auditoria | Rodar checklist no repositório/app e salvar logs | Alta |
| UX premium | Implementar Motion/Placebo Visual controlado | Alta |
| Boost | Estruturar Boost Engine de 8 etapas honestas | Alta |
| Resultado | Criar Prep Result e card compartilhável, se aprovado | Média |
| Persistência | Decidir Hive vs `shared_preferences` para MVP | Alta |
| Firebase | Decidir Crashlytics/Remote Config sem Analytics | Alta |
| Billing | Implementar one-time unlock, restore e startup check | Crítica para monetização |
| Release | AAB release, obfuscation, checklist Play Store, screenshots e testes | Crítica |
| Premium | Apex Visual System com Core, Ring, Pulse, Grid e Chips | Alta |
| Premium | Apex Ritual Cinematográfico como refinamento do Boost Apex | Alta |
| Premium | Apex Result Card e Share Card Seguro | Alta/Média |
| Confiança | Honest Booster Mode em PT-BR, EN e ES | Alta |
| Perfis | Session Profiles por jogo integrados ao GFX local | Alta |
| Conveniência | Quick Actions do ícone do app | Média |
| Conveniência | Widget Premium de jogo favorito/última sessão | Média/Alta |
| Retenção | Badges locais, streaks e resumo semanal | Média |
| Visual | Temas contextuais por jogo/perfil | Média |
| Acessibilidade | Modo Baixa Distração e redução de motion | Alta |
| Social | Share Studio, Evolution Card, Privacy Guard e Export Presets | Média/Alta |
| Social | Floating Capture Button (opt-in) e Short Clip Capture | Média |

---

## Ordem recomendada para maximizar percepção premium

| Ordem | Entrega | Resultado esperado |
|---:|---|---|
| 1 | Apex Visual System | Identidade visual consistente. |
| 2 | Apex Ritual Cinematográfico | Momento assinatura do produto. |
| 3 | Apex Result Card | Fechamento da jornada. |
| 4 | Honest Booster Mode | Confiança e diferencial de loja. |
| 5 | Session Profiles | Personalização por jogo. |
| 6 | Badges e resumo semanal | Retenção local. |
| 7 | Widget e Quick Actions | Conveniência premium. |
| 8 | Share Studio e Evolution Card | Divulgação orgânica. |
| 9 | Temas contextuais | Valor premium adicional. |
| 10 | Store polish, release e billing | Conversão e monetização. |

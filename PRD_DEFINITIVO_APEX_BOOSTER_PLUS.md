# PRD Definitivo — APEX BOOSTER+

**Autor:** Manus AI  
**Data:** 04/06/2026  
**Status:** versão definitiva consolidada para orientar refinamento, implementação restante, auditoria e preparação de publicação.  
**Base documental:** escopos oficiais do projeto, guia Claude Code, interações analisadas, parecer de auditoria, `CLAUDE.md` anexado e versão consolidada `CLAUDE_MELHORADO.md`.

---

## 1. Visão executiva do produto

O **APEX BOOSTER+** é um aplicativo Android desenvolvido em Flutter para **preparação gamer, diagnóstico visual, organização de jogos, perfis GFX locais e abertura assistida de jogos**. O produto deve entregar uma experiência visual premium, jovem, gamer e tecnológica, com sensação de energia, movimento e controle, sem prometer efeitos técnicos falsos sobre jogos de terceiros.

O produto não deve ser posicionado como um “otimizador real de FPS” ou como ferramenta que altera CPU, GPU, RAM, resolução interna, ping ou arquivos de jogos. Sua proposta correta é ser uma camada de **preparação, ritual, leitura, organização, foco e experiência visual** antes da sessão de jogo.

> **Definição central:** o APEX BOOSTER+ prepara a sessão, analisa sinais locais disponíveis, salva preferências por jogo, melhora a experiência de entrada e cria sensação visual gamer. Ele não altera jogos de terceiros automaticamente.

| Campo | Definição definitiva |
|---|---|
| Nome do produto | **APEX BOOSTER+** |
| Nome técnico Flutter | `apex_booster_plus` |
| Package Android | `com.allappsengineer.apex_booster_plus` |
| Nome no launcher | `Apex Booster +` |
| Plataforma inicial | Android |
| Framework | Flutter 3.x / Dart 3.x |
| Posicionamento | Gaming Prep, Scan & Launcher |
| Modelo comercial alvo | **free install + one-time unlock** |
| Preço alvo | R$ 2,99 Brasil / US$ 2,99 internacional |
| Idiomas | Português Brasil, English, Español |

---

## 2. Objetivo do PRD

Este PRD une o que já está **OK, implementado e rodando** com o que ainda precisa ser **implementado, decidido, auditado ou melhorado**. A finalidade é eliminar ambiguidade entre o escopo original, o app já produzido e a continuidade do refinamento.

O documento também incorpora uma diretriz específica para **efeitos placebo visuais e semânticos**, pois esse tipo de recurso é comum no nicho de game boosters e pode aumentar a percepção de vida, beleza e valor do produto. No entanto, esses efeitos devem ser usados com controle, honestidade e separação clara entre estética e métrica real.

| Objetivo | Resultado esperado |
|---|---|
| Consolidar o estado atual | Identificar o que já existe e pode ser preservado. |
| Definir pendências | Separar obrigatório, recomendado e futuro. |
| Regular placebo visual | Permitir sensação gamer sem falsa promessa técnica. |
| Guiar desenvolvimento | Priorizar fases restantes com critérios de aceite. |
| Preparar publicação | Mapear privacidade, billing, loja, release e auditoria. |

---

## 3. Princípios de produto

O APEX BOOSTER+ deve ser desenvolvido como um produto premium desde o início. A estética pode ser intensa, tecnológica e emocional, mas a comunicação precisa permanecer honesta. O usuário pode sentir que está iniciando uma sequência de preparação gamer, mas não pode ser induzido a acreditar que o app alterou tecnicamente o jogo sem base real.

| Princípio | Aplicação prática |
|---|---|
| Honestidade técnica | Não afirmar aumento real de FPS, redução garantida de ping ou alteração de GPU/CPU/jogo. |
| Experiência premium | Usar animações, microinterações, neon controlado, transições e feedback háptico. |
| Preparação ritualizada | Transformar abrir o jogo em uma sequência gamer envolvente. |
| Controle local | Salvar biblioteca, idioma, histórico, perfis e preferências no dispositivo. |
| Privacidade | Evitar tracking, ads, SDKs de atribuição e coleta desnecessária. |
| Clareza comercial | One-time unlock, sem assinatura, sem anúncios e sem plano Pro/Elite. |

---

## 4. Persona e proposta de valor

O público-alvo é formado por jogadores mobile que gostam de organizar seus jogos, iniciar sessões com sensação de controle e usar apps com estética gamer. Esse usuário valoriza telas bonitas, feedback visual, indicadores, perfis, animações e uma sensação de preparação antes de jogar.

A proposta de valor do app deve ser expressa como: **“Prepare sua sessão, veja o estado do dispositivo, escolha seu perfil, ative o ritual Apex e entre no jogo com estilo.”** Essa frase mantém o apelo emocional sem ultrapassar a fronteira da promessa técnica falsa.

| Persona | Necessidade | Resposta do produto |
|---|---|---|
| Jogador casual competitivo | Quer abrir jogos com praticidade e sensação de foco | Biblioteca, Preparar, Modo Foco e launcher. |
| Usuário gamer visual | Quer app bonito, moderno e com energia | Motion system, efeitos placebo visuais e UI premium. |
| Usuário cuidadoso | Quer saber se está tudo pronto antes de jogar | Apex Scan local, métricas reais v1 e disclaimers. |
| Comprador de baixo ticket | Aceita pagar valor baixo por produto com acabamento | One-time unlock sem anúncios e sem assinatura. |

---

## 5. O que já está OK, implementado e rodando

Com base no `CLAUDE.md` consolidado e no parecer anterior, o app já possui uma base funcional relevante. Essa base deve ser preservada e refinada, não recomeçada. O foco agora deve ser completar lacunas, fortalecer evidências e preparar o produto para loja.

| Área | Estado atual consolidado | Decisão de produto |
|---|---|---|
| Fundação Flutter | Projeto Flutter/Dart com identidade Apex | Preservar. |
| Splash e onboarding | Splash, Welcome, HowItWorks e Permissions implementadas | Preservar e validar em três idiomas. |
| Onboarding condicional | Flag `apex_onboarding_done` via `shared_preferences` | Preservar. |
| Home | Bottom navigation com cinco abas | Preservar. |
| Biblioteca | Lista real, adicionar app instalado, favoritos, remoção, ícones reais e badges | Congelada visualmente; alterar só sob solicitação. |
| Preparar | Seletor de jogo, Apex Scan local, snapshot, GFX e CTA | Refinar, sem promessas falsas. |
| Game Detail | Dados do jogo, edição, GFX, Apex Scan, Métricas Reais, ABRIR JOGO | Preservar e melhorar evidências. |
| GFX Profile | Tela dedicada com Equilibrado, Desempenho, Qualidade, Economia e Nenhum | Preservar como preferência local. |
| Histórico | Sessões locais, status, RAM/latência quando disponíveis e chip GFX | Preservar e refinar filtros futuramente. |
| Configurações | Modo Foco Gamer, Limpar histórico, Idioma, Sobre e política em preparação | Completar link real de política. |
| Idioma | Infraestrutura PT-BR/EN/ES via `AppStrings` | Validar cobertura final. |
| Política de privacidade | Base documental criada | Publicar URL pública e linkar no app. |
| Métricas reais v1 | RAM disponível/total, estado de memória e Latência Apex própria | Preservar como snapshot, não como promessa de boost. |
| Modo Foco Gamer | Opt-in e integração controlada com abertura do jogo | Preservar sem forçar configurações sensíveis. |

---

## 6. O que ainda falta implementar, decidir ou melhorar

As pendências devem ser separadas em quatro grupos. O primeiro grupo é de **pré-store obrigatório**, pois bloqueia publicação séria. O segundo é de **monetização**, pois transforma o app em produto comercial. O terceiro é de **arquitetura/observabilidade**, que exige decisão técnica. O quarto é de **experiência premium**, incluindo Motion System, Boost Engine e efeitos placebo.

| Categoria | Pendência | Prioridade | Observação |
|---|---|---:|---|
| Pré-store | Publicar Política de Privacidade em URL real e ativar link no Sobre | Crítica | Próximo passo recomendado. |
| Pré-store | Validação final PT-BR/EN/ES em fluxo completo | Alta | Fase `LANG-U1.6`. |
| Pré-store | Auditoria repositório/app com logs e evidências | Alta | Rodar checklist e salvar outputs. |
| Monetização | Implementar one-time unlock via Google Play Billing | Crítica | Exige Play Console, product ID, restore e startup check. |
| Monetização | Tela/fluxo de desbloqueio | Alta | Deve ser honesto, sem plano Pro/Elite. |
| Arquitetura | Decidir se Hive será obrigatório antes da loja | Alta | Escopo original exige Hive; app atual usa `shared_preferences`. |
| Observabilidade | Decidir Crashlytics/Remote Config antes da loja | Alta | Sem Analytics no MVP. |
| Experiência | Boost Engine estruturado com 8 etapas | Alta | Pode incluir placebo visual, sem falsa otimização. |
| Experiência | Motion System global | Média/Alta | Padronizar animações, timings e intensidade. |
| Experiência | Prep Result / card compartilhável | Média | Recurso premium e viral. |
| Release | Build release, obfuscation e checklist Play Store | Crítica | Antes de submissão. |

---

## 7. Diretriz definitiva para efeitos placebo visuais e semânticos

Os **efeitos placebo** são permitidos como recursos de **experiência visual, ritual de preparação, feedback emocional e diferenciação premium**, desde que não sejam apresentados como métricas reais ou otimizações técnicas efetivas. O produto pode usar energia visual, barras, partículas, pulsos, anéis, status simbólicos e linguagem de preparação. O produto não pode declarar que tais efeitos aumentaram FPS, reduziram ping, limparam RAM, resfriaram o aparelho ou alteraram o jogo.

> **Regra de ouro do placebo:** pode parecer poderoso, pode ser bonito, pode criar expectativa e sensação gamer, mas deve ser comunicacionalmente honesto. O usuário deve entender que a sequência prepara a sessão e exibe sinais locais, não que hackeia performance do jogo.

| Efeito placebo permitido | Como usar | Limite obrigatório |
|---|---|---|
| Anel de energia 0–100% | Indicar progresso da preparação Apex | Não chamar de aumento real de performance. |
| Barras de “sincronização” | Mostrar etapas visuais de prontidão | Não afirmar que altera CPU/GPU. |
| Partículas neon | Dar vida ao fundo e às transições | Não poluir a hierarquia. |
| Pulso de rede visual | Representar checagem/latência Apex própria | Não prometer redução de ping. |
| Núcleo Apex / Core animado | Elemento de marca para energia do app | Não associar a boost real do sistema. |
| “Sequência armada” | Linguagem de ritual antes de abrir jogo | Não sugerir modificação do jogo. |
| Haptic feedback leve | Reforçar cliques e conclusão | Não usar de forma invasiva. |
| Flash de conclusão | Fechar sequência antes do launcher | Deve ter opção curta e não atrasar demais. |
| Chips simbólicos | “Pronto”, “Foco”, “Perfil carregado” | Separar de métricas reais. |
| Contagem cinematográfica | Dar emoção ao botão Jogar | Não bloquear abertura do jogo se falhar. |

### 7.1 Copy permitida para efeitos placebo

A copy deve priorizar verbos como **preparar**, **analisar**, **carregar**, **sincronizar**, **verificar**, **organizar**, **pronto** e **iniciar**. Esses verbos dão vida ao produto sem afirmar otimização técnica falsa.

| Copy permitida | Copy proibida |
|---|---|
| Preparando sessão Apex. | Aumentando FPS. |
| Perfil GFX carregado. | GPU otimizada. |
| Pulso de rede analisado. | Ping reduzido. |
| Foco de sessão pronto. | Lag eliminado. |
| Sequência de jogo armada. | Jogo acelerado. |
| Snapshot do dispositivo concluído. | RAM limpa automaticamente. |
| Preferências locais aplicadas. | Configurações internas do jogo alteradas. |
| Abrindo jogo com perfil selecionado. | Boost aplicado ao jogo. |

### 7.2 Separação entre métricas reais e placebo

A interface deve separar claramente a seção **MÉTRICAS REAIS** das animações placebo. Métricas reais só podem exibir o que o app realmente mede: RAM disponível/total, estado de memória calculado e Latência Apex própria. Já os efeitos placebo ficam nas sequências de preparação, chips visuais, progresso e animações.

| Tipo | Pode exibir | Não pode exibir |
|---|---|---|
| Métrica real | Valor real lido/calculado pelo app | Valor inventado sem fonte. |
| Indicador visual | Progresso, energia, prontidão simbólica | Rótulo de métrica técnica real falsa. |
| GFX Profile | Preferência local do usuário | Alteração real do jogo. |
| Boost Mode | Preparação visual e semântica | Otimização real do Android/jogo. |

---

## 8. Requisitos funcionais definitivos

Os requisitos funcionais abaixo organizam o app em módulos. Cada módulo deve ter critérios de aceite claros e evidências verificáveis no repositório, nos testes e no aparelho.

| ID | Módulo | Requisito | Estado |
|---|---|---|---|
| RF-01 | Onboarding | Exibir Splash, Welcome, HowItWorks e Permissions na primeira abertura | Implementado; validar final. |
| RF-02 | Onboarding | Pular onboarding após conclusão usando flag local | Implementado. |
| RF-03 | Home | Exibir cinco abas principais | Implementado. |
| RF-04 | Biblioteca | Adicionar app instalado, favoritar, remover e persistir | Implementado. |
| RF-05 | Biblioteca | Manter visual aprovado sem redesign pesado | Implementado; congelado. |
| RF-06 | Preparar | Selecionar jogo, carregar perfil e exibir preparação local | Implementado parcial. |
| RF-07 | Game Detail | Exibir dados do jogo, perfil, scan, métricas e CTA abrir jogo | Implementado. |
| RF-08 | GFX | Permitir perfil local por jogo | Implementado. |
| RF-09 | Histórico | Registrar e exibir sessões | Implementado. |
| RF-10 | Configurações | Idioma, foco, limpar histórico, sobre e política | Implementado parcial; política falta URL. |
| RF-11 | Idioma | PT-BR, EN e ES sem restart | Implementado; validação final pendente. |
| RF-12 | Métricas Reais | RAM e Latência Apex com loading/erro/timeout | Implementado v1. |
| RF-13 | Boost Engine | Sequência estruturada de 8 etapas | Pendente. |
| RF-14 | Efeitos placebo | Motion, partículas, anéis, chips simbólicos e sequência cinematográfica | Pendente/refinamento. |
| RF-15 | Billing | One-time unlock, restore e startup check | Pendente. |
| RF-16 | Privacidade | Política pública e link funcional no app | Pendente. |
| RF-17 | Release | Build release, obfuscation, checklist Play Store | Pendente. |

---

## 9. Requisitos não funcionais

O app precisa parecer premium, mas também deve ser rápido, estável e leve. As animações placebo não podem prejudicar performance, atrasar excessivamente a abertura do jogo ou causar overflow. O Motion System deve ser controlável, com durações curtas e possibilidade de reduzir intensidade em telas sensíveis.

| Categoria | Requisito definitivo |
|---|---|
| Performance | Startup e navegação devem permanecer fluidos; animações não podem travar aparelhos intermediários. |
| Estabilidade | `flutter analyze` e `flutter test` devem passar antes de commits relevantes. |
| Visual | Sem overflow, sem cards sem hierarquia, sem fundo preto chapado e sem glow exagerado. |
| Privacidade | Sem ads, sem analytics, sem atribuição e sem coleta desnecessária. |
| Acessibilidade | Textos legíveis, contraste adequado e CTAs claros. |
| Internacionalização | Todas as strings visíveis novas devem entrar em `AppStrings`. |
| Auditabilidade | Toda fase deve registrar arquivos alterados, testes, evidências e pendências. |

---

## 10. Arquitetura e decisões técnicas

A arquitetura alvo continua sendo limpa e modular, mas o app atual não deve ser refatorado agressivamente sem necessidade. O princípio é **evoluir sem quebrar**. Se Hive, Firebase, Billing, DI ou BLoC forem adicionados, isso deve ocorrer em fases isoladas, com escopo claro e testes.

| Decisão | Diretriz definitiva |
|---|---|
| `shared_preferences` | Aceito para estado atual já implementado; reavaliar para dados estruturados antes da loja. |
| Hive | Continua como candidato/possível requisito de persistência estruturada; exige fase própria. |
| Firebase Crashlytics | Decisão pré-release; se entrar, sem Analytics. |
| Remote Config | Opcional/recomendado para copy/timings, mas não essencial ao MVP local. |
| Billing | Obrigatório para monetização real; não implementar sem Play Console pronto. |
| Motion System | Deve ser implementado como camada visual controlada. |
| Placebo visual | Permitido como UI/UX, não como métrica falsa. |

---

## 11. Roadmap definitivo de continuidade

O roadmap deve evitar misturar refinamento visual, loja, monetização e arquitetura na mesma fase. A sequência abaixo é recomendada para reduzir risco.

| Ordem | Fase | Objetivo | Entregável |
|---:|---|---|---|
| 1 | STORE-U1.2B | Publicar Política de Privacidade e linkar no app | URL pública + link funcional no Sobre. |
| 2 | LANG-U1.6 | Validar PT-BR/EN/ES em fluxo completo | Relatório visual sem overflow. |
| 3 | AUDIT-U1 | Rodar auditoria no app/repo | Pasta de logs + classificação Passa/Parcial/Falha. |
| 4 | UX-P1 | Implementar Motion/Placebo Visual controlado | Anéis, partículas leves, chips e sequência visual honesta. |
| 5 | BOOST-U1 | Estruturar Boost Engine de 8 etapas | Engine visual/semântica com etapas honestas. |
| 6 | RESULT-U1 | Criar Prep Result e card compartilhável | Tela de resultado + share opcional. |
| 7 | DATA-U1 | Decidir Hive vs manter SharedPreferences | Decisão documentada ou migração controlada. |
| 8 | OBS-U1 | Decidir Crashlytics/Remote Config | Implementação ou justificativa de adiamento. |
| 9 | BILL-U1 | Implementar one-time unlock | Product ID, restore, startup check e testes. |
| 10 | RELEASE-U1 | Preparar release Play Store | AAB release, checklist, screenshots, política, testes. |

---

## 12. Critérios de aceite finais

O app só deve ser considerado pronto para submissão quando cumprir os critérios abaixo. Caso a equipe decida publicar uma versão interna antes da monetização, os itens de Billing podem ser marcados como “adiados conscientemente”, mas não como concluídos.

| Critério | Condição de aceite |
|---|---|
| Jornada local | Onboarding, Home, Biblioteca, Preparar, Detalhe, GFX, Histórico e Configurações funcionam sem crash. |
| Idiomas | PT-BR, EN e ES validados visualmente em fluxo principal. |
| Política | URL pública real acessível e link funcional dentro do app. |
| Placebo visual | Efeitos bonitos, leves e honestos, sem promessa falsa. |
| Métricas reais | Valores reais separados de indicadores simbólicos. |
| Billing | One-time unlock e restore funcionando, se a versão for comercial. |
| Privacidade | Sem ads, sem analytics e sem SDKs proibidos. |
| Testes | `flutter analyze`, `flutter test` e checker de strings sem bloqueadores. |
| Release | Build release assinado/obfuscado e checklist Play Store concluído. |
| Evidência | Logs, prints, hash do commit e validação em aparelho registrados. |

---

## 13. Fora de escopo da versão atual

Alguns recursos podem parecer atraentes, mas devem permanecer fora da versão atual para evitar risco técnico, rejeição de loja ou falsa promessa.

| Fora de escopo | Motivo |
|---|---|
| Aumentar FPS real de jogos | Não há controle legítimo sobre jogos terceiros. |
| Alterar GPU/CPU/resolução interna | Risco técnico e promessa falsa. |
| Limpar RAM automaticamente fechando apps | Risco de permissões, política da loja e comportamento invasivo. |
| Reduzir ping garantidamente | O app não controla rede externa nem servidor do jogo. |
| AccessibilityService para automação | Alto risco de rejeição e abuso. |
| Overlay invasivo sobre jogos | Alto risco de permissão sensível e política. |
| Ads/interstitials | Contrário ao modelo premium. |
| Plano Pro/Elite/assinatura | Contrário ao modelo **free install + one-time unlock**. |

---

## 14. Conclusão

O APEX BOOSTER+ já possui uma base local importante e visualmente orientada para produto. A próxima etapa não é recomeçar, mas consolidar, auditar e completar as peças que transformam o app em produto final: política pública, validação de idiomas, efeitos placebo visuais honestos, Boost Engine estruturado, eventual card de resultado, decisão de persistência, decisão de observabilidade, Billing e preparação de release.

A diretriz definitiva é clara: **o app pode e deve parecer poderoso, vivo e premium, mas nunca deve mentir tecnicamente**. Essa combinação — estética gamer forte com honestidade de produto — é o caminho para um aplicativo vendável, defensável e sustentável na Play Store.

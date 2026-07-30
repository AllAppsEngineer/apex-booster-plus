# CLAUDE.md — APEX BOOSTER+ Definitivo

**Status:** contrato operacional definitivo para continuidade do desenvolvimento do **APEX BOOSTER+**.  
**Data:** 04/06/2026.  
**Prioridade:** este arquivo vence conversas soltas, instruções antigas, sugestões parciais e interpretações ambíguas quando houver conflito.  
**Documento complementar obrigatório:** `PRD_DEFINITIVO_APEX_BOOSTER_PLUS.md`.  
**Documentação auxiliar:** [`docs/claude/security.md`](docs/claude/security.md) · [`docs/claude/premium.md`](docs/claude/premium.md) · [`docs/claude/social.md`](docs/claude/social.md) · [`docs/claude/roadmap.md`](docs/claude/roadmap.md)

---

## 1. Regra soberana

Leia este arquivo inteiro antes de qualquer ação no projeto. Nenhuma implementação deve começar sem declarar a fase pretendida, os arquivos prováveis, os riscos e os testes que serão executados. Não faça commit automático. Não altere identidade, package, fluxo validado, dependências, Billing, Firebase, permissões ou arquitetura sem aprovação explícita.

> **Regra máxima do produto:** o APEX BOOSTER+ pode entregar uma experiência gamer forte, visualmente poderosa e com efeitos placebo honestos, mas não pode mentir tecnicamente. Efeito visual não é métrica real. Preparação não é otimização real de jogos terceiros.

---

## 2. Identidade oficial do produto

O **APEX BOOSTER+** é um app Android em Flutter para **preparação gamer, diagnóstico visual, biblioteca de jogos, perfis GFX locais, histórico de sessões, Apex Scan e abertura assistida de jogos**.

| Item | Valor oficial |
|---|---|
| Nome de marca | **APEX BOOSTER+** |
| Nome técnico Flutter | `apex_booster_plus` |
| Package Android | `com.allappsengineer.apex_booster_plus` |
| Nome no launcher | `Apex Booster +` |
| Plataforma | Android |
| Stack | Flutter 3.x / Dart 3.x |
| Posicionamento | Gaming Prep, Scan & Launcher |
| Tagline PT-BR | Prepare. Analise. Jogue. |
| Tagline EN-US | Prepare. Scan. Play. |
| Tagline ES | Prepara. Analiza. Juega. |

Não alterar package, nome Android, launcher icon, splash nativa, identidade visual principal ou fluxo central sem aprovação explícita. O app já tem áreas validadas em aparelho físico e deve evoluir por refinamento controlado, não por recomeço.

---

## 3. Verdade de produto e modelo comercial

> **Atualização de modelo comercial (MONETIZATION-PAID-U0-DOCS, 30/07/2026):** o modelo comercial oficial deixou de ser "free install + one-time unlock". O **APEX BOOSTER+ é um aplicativo pago para download na Google Play**, com **compra única do aplicativo** e **todos os recursos disponíveis desde a primeira instalação**. Não há anúncios, assinatura, compras internas, paywall ou desbloqueio posterior. Política de atualizações: **atualizações da edição atual incluídas, sem cobrança recorrente** — sem promessa de atualizações vitalícias ou de futuras edições/versões maiores. Esta decisão substitui qualquer menção anterior a "free install + one-time unlock", `BILL-U1`, `apex_full_unlock` ou gating premium neste documento e nos documentos auxiliares — mantidas abaixo apenas como registro histórico quando identificadas como tal.

O produto deve ser vendido como experiência premium de preparação e organização gamer. O modelo comercial oficial é **app pago para download (compra única na Google Play)**, sem anúncios, sem assinatura, sem compras internas, sem plano Pro, sem plano Elite e sem SDK de ads/atribuição/analytics no MVP.

| Permitido afirmar | Proibido afirmar |
|---|---|
| Prepara a sessão. | Aumenta FPS real. |
| Organiza seus jogos. | Reduz ping garantidamente. |
| Salva preferências por jogo. | Altera CPU, GPU, RAM ou resolução interna. |
| Exibe snapshot local do dispositivo. | Fecha apps terceiros automaticamente. |
| Carrega perfil visual/GFX local. | Otimiza jogos de terceiros. |
| Cria ritual gamer antes de jogar. | Desbloqueia performance oculta do Android. |
| Abre o jogo selecionado. | Aplica boost real no jogo. |

**Billing interno (Google Play Billing / `in_app_purchase`) foi descontinuado.** O código de Billing implementado nas fases históricas `BILL-U1A`/`BILL-U1B` (produto `apex_full_unlock`) será removido do repositório na fase aprovada **MONETIZATION-PAID-U1** (auditoria já aprovada em 30/07/2026, execução ainda pendente). Nenhum código de compra interna, desbloqueio posterior ou gating de recurso deve ser reintroduzido sem nova decisão comercial explícita.

---

## 4. Stack e dependências

O projeto usa Flutter/Dart e deve preservar a arquitetura modular existente. A regra é **evoluir sem quebrar**. Não adicionar dependência por conveniência sem justificar necessidade, alternativa, impacto no build, impacto de privacidade e forma de teste.

| Área | Decisão atual |
|---|---|
| Navegação | `go_router`. |
| Persistência atual | `shared_preferences` para biblioteca, sessões, idioma e onboarding já implementados. |
| Persistência futura | Hive pode ser avaliado para dados estruturados, mas exige fase própria. |
| Idioma atual | `AppStrings`, `AppLanguage`, `LanguageService`, `languageNotifier`. |
| Estado/DI | Controllers/serviços atuais; `flutter_bloc`, `get_it` e `injectable` só com fase aprovada. |
| Billing | `in_app_purchase` presente como código legado das fases históricas `BILL-U1A`/`BILL-U1B`; remoção aprovada e agendada em `MONETIZATION-PAID-U1`. Não reintroduzir Billing sem nova decisão comercial explícita — o modelo atual é app pago para download. |
| Firebase | Crashlytics/Remote Config apenas com estratégia, secrets e CI definidos. |
| Placebo visual | Implementar preferencialmente com recursos leves, CustomPainter, animações Flutter e `flutter_animate` já aceito. |

Dependências já aceitas: `go_router`, `flutter_animate` e `shared_preferences`. Dependências não liberadas automaticamente: Hive, BLoC, DI, Firebase, Billing, plugins de device info, battery, connectivity, share, package info, áudio, lottie, rive e qualquer SDK nativo adicional.

---

## 5. Regras invioláveis

Estas regras são bloqueantes. Se uma tarefa exigir violação, pare e peça aprovação humana.

| Nº | Regra |
|---:|---|
| 1 | Nunca afirmar que o app aumenta FPS real de jogos. |
| 2 | Nunca afirmar que altera CPU, GPU, RAM, resolução ou qualidade interna de jogos terceiros. |
| 3 | Nunca prometer redução garantida de lag, ping, travamento ou aquecimento. |
| 4 | GFX Profile é preferência local; não é alteração real do jogo. |
| 5 | Apex Scan é diagnóstico/snapshot e orientação; não é milagre técnico. |
| 6 | Boost Apex/Apex Boost Mode é preparação visual e semântica; não é otimização técnica real. |
| 7 | Efeitos placebo são permitidos apenas como estética, ritual e feedback visual. |
| 8 | Métricas reais devem ficar separadas de indicadores simbólicos/placebo. |
| 9 | Sem anúncios, assinatura, plano Pro/Elite, compras internas, paywall, desbloqueio posterior, tracking ou atribuição. App é pago para download, com todos os recursos incluídos desde a instalação. |
| 10 | Sem Firebase, Billing interno, Hive, permissões novas ou dependências sem fase aprovada. Remoção do Billing legado é a única mudança de Billing aprovada, via `MONETIZATION-PAID-U1`. |
| 11 | Sem alteração de package, nome Android, launcher icon ou telas congeladas sem aprovação. |
| 12 | Não commitar automaticamente. Commit só após aprovação explícita. |
| 13 | `flutter analyze` e `flutter test` passando não significam aprovação visual. |

---

## 6. Estado atual OK e rodando

A base atual do aplicativo já contém a jornada principal local. Não reimplementar do zero. Preservar funcionalidades existentes, corrigir lacunas e adicionar refinamentos em fases pequenas.

| Área | Estado consolidado |
|---|---|
| Splash/onboarding | Splash, Welcome, HowItWorks e Permissions implementadas; onboarding condicional via `apex_onboarding_done`. |
| Home | Bottom navigation com Início, Biblioteca, Preparar, Histórico e Configurações. |
| Início | Refresh on tab focus, contagem real, última sessão e chips de métricas/GFX quando existentes. |
| Biblioteca | Lista real, adicionar app instalado, autocomplete, validação contra apps instalados, favoritos, remoção, persistência local, ícones reais e badges. |
| Preparar | Seletor de jogo, pré-seleção por histórico, Apex Scan local, snapshot, GFX contextual, sugestões e CTA. |
| Detalhe do Jogo | Dados, edição, ícone, GFX Profile, Apex Scan, Métricas Reais, ABRIR JOGO e Apex Boost Mode visual. |
| GFX Profile | Tela dedicada com Equilibrado, Desempenho, Qualidade, Economia e Nenhum. |
| Histórico | Sessões reais locais, status, RAM/latência quando disponíveis e chip GFX quando aplicável. |
| Configurações | Modo Foco Gamer, Limpar histórico, Idioma, Sobre e base de Política de Privacidade. |
| Idioma | Estrutura própria para PT-BR, EN e ES em grande parte da UI. |
| Métricas reais v1 | RAM disponível, RAM total, estado de memória e Latência Apex própria com loading/erro/timeout. |

A **BibliotecaTab está congelada visualmente** após reprovação e reversão de redesign pesado. Qualquer alteração nela deve ser pontual e aprovada.

---

## 7. Pendências oficiais

As pendências abaixo devem orientar a continuidade. Ver lista completa em [`docs/claude/roadmap.md`](docs/claude/roadmap.md).

| Bloco | Pendência | Prioridade |
|---|---|---:|
| Pré-store | Publicar Política de Privacidade em URL real e ativar link no Sobre | Crítica |
| Idioma | Validar PT-BR/EN/ES em fluxo completo | Alta |
| Auditoria | Rodar checklist no repositório/app e salvar logs | Alta |
| UX premium | Implementar Motion/Placebo Visual controlado | Alta |
| Boost | Estruturar Boost Engine de 8 etapas honestas | Alta |
| Resultado | Criar Prep Result e card compartilhável, se aprovado | Média |
| Monetização | Publicar o app como pago para download na Google Play, preço único, todos os recursos incluídos desde a instalação | Crítica |
| Billing | Remover Billing interno legado (`in_app_purchase`, `apex_full_unlock`) — `MONETIZATION-PAID-U1` | Crítica (auditoria aprovada, execução pendente) |
| Release | AAB release, obfuscation, checklist Play Store, listing pago, screenshots e testes | Crítica |

---

## 8. Design visual oficial

O visual deve ser **dark premium, gamer moderno, jovem, limpo, profundo, tecnológico, com neon controlado, microinterações, sensação de energia e acabamento real de produto**. O app não pode parecer fundo preto chapado, protótipo, tela genérica, app corporativo, infantil, carnavalesco ou poluído.

| Token visual | Valor/diretriz |
|---|---|
| Background profundo | `#050505` / `#080808` |
| Verde Apex | `#22C55E` |
| Azul Cyber | `#3B82F6` |
| Laranja energia/alerta | `#F97316` |
| Texto principal | `#FFFFFF` |
| Texto secundário | `#A1A1AA` |
| Cards | Grafite escuro com contraste real, nunca preto puro |
| Motion | Curto, fluido, controlado e funcional |
| Glow | Moderado; nunca esconder layout fraco |

Uma tela só é aprovada se tiver hierarquia clara, contraste, CTA forte, microinteração, ausência de overflow, responsividade e validação visual em aparelho físico quando houver UI.

---

## 9. Diretriz obrigatória para efeitos placebo

Efeitos placebo são permitidos porque aumentam a vida e a beleza do produto no nicho de game boosters. Eles devem funcionar como **camada estética, ritual de preparação, feedback emocional e percepção de energia**, nunca como afirmação técnica falsa.

> **Definição operacional:** efeito placebo no APEX BOOSTER+ é qualquer animação, indicador simbólico, pulso, partícula, anel, flash, contagem ou copy de prontidão que aumenta a sensação de preparação sem afirmar alteração real de performance.

| Permitido | Como implementar | Proibido |
|---|---|---|
| Anel de energia 0–100% | Progresso visual da sequência Apex | Dizer que subiu FPS. |
| Núcleo Apex animado | Elemento de marca e energia | Dizer que ativou GPU. |
| Partículas neon leves | Fundo vivo e premium | Poluir tela ou travar app. |
| Pulso de rede visual | Representar análise/latência própria | Dizer que reduziu ping. |
| Sincronização GFX | Carregar preferência local | Dizer que alterou gráficos do jogo. |
| Chips de prontidão | "Perfil carregado", "Foco pronto" | "CPU otimizada", "RAM limpa". |
| Flash de conclusão | Fechar ritual antes do launcher | Simular limpeza técnica falsa. |
| Haptic feedback | Reforçar conclusão e CTA | Usar vibração invasiva. |
| Contagem cinematográfica | Criar expectativa antes de abrir jogo | Atrasar demais ou bloquear abertura. |

### 9.1 Vocabulário aprovado

Use verbos e expressões que comuniquem preparação: **preparando**, **analisando**, **carregando**, **sincronizando**, **verificando**, **pronto**, **perfil carregado**, **sessão preparada**, **sequência armada**, **jogo no alvo**, **abrindo com estilo**.

| Copy aprovada | Copy reprovada |
|---|---|
| Preparando sessão Apex. | Aumentando FPS. |
| Perfil GFX carregado. | GPU otimizada. |
| Pulso de rede analisado. | Ping reduzido. |
| Foco de sessão pronto. | Lag eliminado. |
| Sequência de jogo armada. | Jogo acelerado. |
| Snapshot concluído. | RAM limpa automaticamente. |
| Preferências locais aplicadas. | Configurações internas alteradas. |

### 9.2 Separação visual obrigatória

Toda tela que misturar métricas e placebo deve ter separação visual clara.

| Seção | Conteúdo permitido |
|---|---|
| MÉTRICAS REAIS | RAM disponível/total, estado de memória, Latência Apex própria, loading, erro e timeout. |
| PREPARAÇÃO APEX | Anel de energia, partículas, chips de prontidão, etapas simbólicas e feedback háptico. |
| GFX PROFILE | Preferência local por jogo e disclaimer. |
| BOOST MODE | Sequência visual/semântica de preparação antes de abrir o jogo. |

---

## 10. GFX Profile

GFX Profile é preferência local salva por jogo. Não altera o jogo. A tela dedicada já substituiu o bottom sheet legado.

| Perfil | Semântica |
|---|---|
| Equilibrado | Preferência local neutra/balanceada. |
| Desempenho | Preferência local para foco em fluidez percebida na preparação. |
| Qualidade | Preferência local para experiência visual. |
| Economia | Preferência local para uso mais contido. |
| Nenhum | Ausência de perfil; não gerar chip falso. |

Toda tela GFX deve ter disclaimer honesto. Não usar rótulos que sugiram resolução real, "2K", FPS real, qualidade aplicada no jogo ou alteração de engine do jogo.

---

## 11. Apex Scan e Métricas Reais

Apex Scan deve ser diagnóstico honesto. A implementação atual possui motor local, resultado, serviço, UI no Detalhe e card na PrepararTab.

| Item | Estado |
|---|---|
| RAM disponível/total | Implementada como snapshot real. |
| Estado de memória | Calculado a partir dos valores disponíveis. |
| Latência Apex | Teste próprio; não representa ping do jogo externo. |
| FPS real | Não implementado. |
| GPU real | Não implementado. |
| Limpeza de RAM | Não implementada. |
| Otimização real | Não implementada. |

Indicadores visuais de energia, boost, score simbólico e prontidão podem existir como placebo visual, mas não podem ser apresentados como métrica real se não houver medição correspondente.

---

## 12. Boost Apex / Apex Boost Mode

Boost Apex deve ser uma sequência de preparação honesta. Pode ser intensa, bonita e cinematográfica, mas cada etapa deve ser informativa, simbólica ou visualmente declarada como preparação.

| Etapa sugerida | Natureza |
|---|---|
| Núcleo Apex online | Placebo visual de marca. |
| Jogo travado no alvo | Seleção real do jogo. |
| Pulso de rede analisado | Pode usar Latência Apex própria ou visual simbólico. |
| Energia sincronizada | Placebo visual / estado de bateria se implementado. |
| Temperatura verificada | Apenas se houver dado real ou fallback honesto. |
| Foco de sessão pronto | Estado real do Modo Foco se disponível. |
| Perfil GFX carregado | Preferência local real. |
| Sequência de jogo armada | Conclusão visual antes de abrir o jogo. |

O botão **ABRIR JOGO** pode exibir Apex Boost Mode antes de abrir via `packageName`. O fluxo não deve bloquear abertura se uma etapa visual falhar.

---

## 13. Idioma e strings

O app usa `AppStrings`, `AppLanguage`, `LanguageService` e `languageNotifier`. Não espalhar strings hardcoded. Toda copy nova, inclusive placebo visual e social, deve existir em PT-BR, EN e ES.

Após qualquer alteração textual, rodar o checker de strings se existir:

```bash
dart run tool/check_hardcoded_strings.dart
```

---

## 14. Privacidade, permissões e loja

O app deve coletar o mínimo necessário. Ver detalhes em [`docs/claude/security.md`](docs/claude/security.md).

| Recurso | Regra |
|---|---|
| Apps instalados | Usar escopo justificado e fallback. |
| Modo Foco / DND | Opt-in, reversível e não bloqueante. |
| Internet | Apenas com função real e política correspondente. |
| Firebase | Sem Analytics; só Crashlytics/Remote Config se aprovado. |
| Ads/Analytics/Atribuição | Proibidos no MVP. |
| Billing interno | Não aplicável — app pago para download, sem compras internas. Código legado de Billing será removido em `MONETIZATION-PAID-U1`. |

Antes da loja: publicar Política de Privacidade em URL pública real e ativar link funcional no app.

---

## 15. Fluxo obrigatório de trabalho

Siga este fluxo em toda sessão de desenvolvimento.

| Etapa | Obrigação |
|---:|---|
| 1 | Ler este `CLAUDE.md` inteiro. |
| 2 | Ler o `PRD_DEFINITIVO_APEX_BOOSTER_PLUS.md` quando a tarefa tocar escopo, produto ou roadmap. |
| 3 | Confirmar produto, regras, estado atual e fase pretendida. |
| 4 | Apresentar plano curto com arquivos previstos e riscos. |
| 5 | Aguardar aprovação explícita. |
| 6 | Executar apenas o escopo aprovado. |
| 7 | Rodar `flutter analyze`. |
| 8 | Rodar `flutter test`. |
| 9 | Rodar checker de strings quando houver copy. |
| 10 | Validar visualmente no aparelho físico quando houver UI. |
| 11 | Relatar arquivos alterados, evidências, pendências e próximos passos. |
| 12 | Só commitar após aprovação humana explícita. |

Commits devem ser pequenos e atômicos. Não misturar visual, nativo, billing, Firebase, refatoração e feature na mesma mudança.

---

## 16. Testes mínimos e auditoria

Após cada bloco funcional, executar:

```bash
flutter analyze
flutter test
dart run tool/check_hardcoded_strings.dart # se existir e houver textos alterados
git status --short
```

Quando houver UI, também validar em aparelho físico.

---

## 17. Critério de rejeição automática

Rejeitar qualquer implementação que pareça fundo preto com texto verde, use glow exagerado para esconder layout fraco, gere overflow, quebre navegação, adicione dependência sem aprovação, prometa melhoria técnica falsa, misture placebo com métrica real, mexa em Firebase/Billing antes da hora, introduza tracking/ads, altere identidade Android sem autorização ou faça commit sem aprovação.

Também rejeitar qualquer fase que declare "testes passaram", "aprovado no celular" ou "commit realizado" sem evidência reproduzível. Logs, diffs, hash, screenshots e execução no app devem ser anexados quando necessário.

---

## 18. Roadmap resumido

Ver roadmap completo em [`docs/claude/roadmap.md`](docs/claude/roadmap.md).

| Ordem | Fase | Objetivo |
|---:|---|---|
| 1 | STORE-U1.2B | Publicar política de privacidade em URL real. |
| 2 | LANG-U1.6 | Validar PT-BR/EN/ES em fluxo completo. |
| 3 | AUDIT-U1 | Rodar checklist e registrar evidências. |
| 4 | PREMIUM-U1 | Apex Visual System. |
| 5 | PREMIUM-U2 | Apex Ritual Cinematográfico. |
| 6 | PREMIUM-U3 | Apex Result Card. |
| 7 | MONETIZATION-PAID-U0-DOCS | Formalizar o modelo de app pago nos documentos de governança (concluída em 30/07/2026). |
| 8 | MONETIZATION-PAID-U1 | Remover Billing interno legado e confirmar app 100% liberado desde a instalação. |
| 9 | AUDIT-U-FINAL | Auditoria final pré-listing. |
| 10 | RELEASE-U1 | Build release, listing pago, manual/assets e submissão Play Store. |

---

## 19. Regra final

Qualidade acima de velocidade. O objetivo não é apenas fazer telas funcionarem; é construir um produto Android gamer premium, honesto, vendável, tecnicamente limpo e visualmente forte. Se uma implementação passa nos testes, mas parece ruim no celular, ela está reprovada. Se parece bonita, mas promete algo tecnicamente falso, ela também está reprovada. Se usa placebo visual com honestidade, estética e clareza, ela é bem-vinda.

---

## 20. Segurança (OWASP LLM Top 10) — resumo

Ver detalhamento completo em [`docs/claude/security.md`](docs/claude/security.md).

**Regras essenciais:**
- Tratar todas as entradas como não confiáveis; validar tipo, tamanho e formato.
- Nunca commitar secrets, keystore, `key.properties` ou `google-services.json`.
- Sanitizar saídas antes de renderizar, persistir ou logar.
- Não expor dados sensíveis em telas, logs, commits ou relatórios.
- HMAC, rate limiting e server-side validation obrigatórios caso Billing/compra interna seja reintroduzido no futuro (não é o caso hoje — app pago para download, sem Billing interno).
- Autoauditoria obrigatória antes de entregar código que toque APIs, Billing legado (em remoção) ou dados sensíveis.

---

## 21–30. Camada Premium Memorável — resumo

Ver detalhamento completo em [`docs/claude/premium.md`](docs/claude/premium.md).

**Componentes obrigatórios:** Apex Visual System (Core, Ring, Pulse, Grid, Chips), Apex Ritual Cinematográfico, Apex Result Card, Honest Booster Mode, Session Profiles, Widget e Quick Actions, Badges e Resumo Semanal, Temas Contextuais.

**Proibições absolutas:** não usar componentes premium para sugerir FPS/ping/CPU/GPU reais. Não bloquear abertura do jogo. Não prometer boost real.

**Fases:** PREMIUM-U1 → PREMIUM-U3, TRUST-U1, PROFILE-U1, RETENTION-U1/U2, CONVENIENCE-U1/U2, SHARE-U1, THEME-U1, ACCESS-U1.

**Modelo:** app pago para download; todos os componentes premium listados acima, incluindo Honest Booster Mode, ficam disponíveis desde a primeira instalação — não há paywall interno nem desbloqueio posterior. *(Histórico: modelo anterior a 30/07/2026 era "free demonstra valor; one-time unlock libera experiência completa" — substituído por `MONETIZATION-PAID-U0-DOCS`.)*

---

## 31–39. Apex Social Capture & Share Layer — resumo

Ver detalhamento completo em [`docs/claude/social.md`](docs/claude/social.md).

> **Regra soberana:** nunca capturar, gravar, publicar ou inferir dados sem ação explícita e consentimento claro do usuário.

**Posicionamento:** ferramenta de expressão gamer, evolução pessoal e compartilhamento social. Não é boost de performance.

**Componentes:** Share Studio, Evolution Card, Social Export Presets, Privacy Guard, Floating Capture Button (opt-in), Short Clip Capture.

**Ordem obrigatória:** SOCIAL-U1 → SOCIAL-U2 → SOCIAL-U3 → SOCIAL-U4 → SOCIAL-U5 → SOCIAL-U6 → SOCIAL-U7.

**Floating Capture Button:** permitido somente com opt-in explícito, reposicionável, compatível com Modo Baixa Distração. Copy: "Capturar momento" / "Marcar clipe". Nunca: "turbo real", "FPS", "boost".

**Proibições absolutas:** captura automática, postagem automática, FPS/ping em cards sociais, coleta de notificações/conversas/identificadores de dispositivo.

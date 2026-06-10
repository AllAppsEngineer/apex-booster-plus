# CLAUDE.md — APEX BOOSTER+ Definitivo

**Status:** contrato operacional definitivo para continuidade do desenvolvimento do **APEX BOOSTER+**.  
**Data:** 04/06/2026.  
**Prioridade:** este arquivo vence conversas soltas, instruções antigas, sugestões parciais e interpretações ambíguas quando houver conflito.  
**Documento complementar obrigatório:** `PRD_DEFINITIVO_APEX_BOOSTER_PLUS.md`.

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

O produto deve ser vendido como experiência premium de preparação e organização gamer. O modelo comercial oficial é **free install + one-time unlock**, sem anúncios, sem assinatura, sem plano Pro, sem plano Elite e sem SDK de ads/atribuição/analytics no MVP.

| Permitido afirmar | Proibido afirmar |
|---|---|
| Prepara a sessão. | Aumenta FPS real. |
| Organiza seus jogos. | Reduz ping garantidamente. |
| Salva preferências por jogo. | Altera CPU, GPU, RAM ou resolução interna. |
| Exibe snapshot local do dispositivo. | Fecha apps terceiros automaticamente. |
| Carrega perfil visual/GFX local. | Otimiza jogos de terceiros. |
| Cria ritual gamer antes de jogar. | Desbloqueia performance oculta do Android. |
| Abre o jogo selecionado. | Aplica boost real no jogo. |

Billing ainda não deve ser implementado sem fase aprovada. Quando a fase de monetização for autorizada, ela deve incluir Play Console configurado, `productId`, license testers, fluxo de compra, restore purchase, verificação no startup, fallback local de desenvolvimento e testes em aparelho.

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
| Billing | `in_app_purchase` apenas em fase aprovada. |
| Firebase | Crashlytics/Remote Config apenas com estratégia, secrets e CI definidos. |
| Placebo visual | Implementar preferencialmente com recursos leves, CustomPainter, animações Flutter e `flutter_animate` já aceito. |

Dependências já aceitas na base atual incluem `go_router`, `flutter_animate` e `shared_preferences`. Dependências planejadas ou possíveis, mas não liberadas automaticamente, incluem Hive, BLoC, DI, Firebase, Billing, plugins de device info, battery, connectivity, share, package info, áudio, lottie, rive e qualquer SDK nativo adicional.

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
| 9 | Sem anúncios, assinatura, plano Pro/Elite, tracking ou atribuição no MVP. |
| 10 | Sem Firebase, Billing, Hive, permissões novas ou dependências sem fase aprovada. |
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

As pendências abaixo devem orientar a continuidade. Não declarar uma fase como concluída sem evidência.

| Bloco | Pendência | Prioridade |
|---|---|---:|
| Pré-store | Publicar Política de Privacidade em URL real e ativar link no Sobre | Crítica |
| Idioma | Validar PT-BR/EN/ES em fluxo completo | Alta |
| Auditoria | Rodar checklist no repositório/app e salvar logs | Alta |
| UX premium | Implementar Motion/Placebo Visual controlado | Alta |
| Boost | Estruturar Boost Engine de 8 etapas honestas | Alta |
| Resultado | Criar Prep Result e card compartilhável, se aprovado | Média |
| Persistência | Decidir Hive vs manter `shared_preferences` para MVP | Alta |
| Firebase | Decidir Crashlytics/Remote Config sem Analytics | Alta |
| Billing | Implementar one-time unlock, restore e startup check | Crítica para monetização |
| Release | AAB release, obfuscation, checklist Play Store, screenshots e testes | Crítica |

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
| Chips de prontidão | “Perfil carregado”, “Foco pronto” | “CPU otimizada”, “RAM limpa”. |
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

Toda tela que misturar métricas e placebo deve ter separação visual clara. A seção **MÉTRICAS REAIS** só pode conter dados realmente obtidos ou calculados pelo app. A seção de preparação pode conter indicadores simbólicos, desde que não se passem por medições reais.

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

Toda tela GFX deve ter disclaimer honesto. Não usar rótulos que sugiram resolução real, “2K”, FPS real, qualidade aplicada no jogo ou alteração de engine do jogo.

---

## 11. Apex Scan e Métricas Reais

Apex Scan deve ser diagnóstico honesto. A implementação atual possui motor local, resultado, serviço, UI no Detalhe e card na PrepararTab. A seção de Métricas Reais exibe RAM e Latência Apex própria.

| Item | Estado |
|---|---|
| RAM disponível/total | Implementada como snapshot real. |
| Estado de memória | Calculado a partir dos valores disponíveis. |
| Latência Apex | Teste próprio; não representa ping do jogo externo. |
| FPS real | Não implementado. |
| GPU real | Não implementado. |
| Limpeza de RAM | Não implementada. |
| Otimização real | Não implementada. |
| Fórmula completa Network/Power/Thermal/Focus | Planejada, ainda não final. |

Indicadores visuais como energia, boost, score simbólico e prontidão podem existir como placebo visual, mas não podem ser apresentados como métrica real se não houver medição correspondente.

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

O botão **ABRIR JOGO** pode exibir Apex Boost Mode antes de abrir via `packageName`. O fluxo não deve bloquear abertura se uma etapa visual falhar. O usuário deve poder abrir o jogo com rapidez.

---

## 13. Idioma e strings

O app usa `AppStrings`, `AppLanguage`, `LanguageService` e `languageNotifier`. Não espalhar strings hardcoded. Toda copy nova, inclusive placebo visual, deve existir em PT-BR, EN e ES.

Após qualquer alteração textual, rodar o checker de strings se existir:

```bash
dart run tool/check_hardcoded_strings.dart
```

A fase de validação final de idioma deve verificar fluxo completo nos três idiomas, incluindo onboarding, biblioteca, preparar, detalhe, GFX, histórico, configurações, política, Boost Mode e mensagens placebo.

---

## 14. Privacidade, permissões e loja

O app deve coletar o mínimo necessário. A política de privacidade deve refletir exatamente o que o app usa: biblioteca de jogos, packageName, perfil GFX local, histórico local, idioma, onboarding, RAM, Latência Apex, Modo Foco e ausência de venda/compartilhamento de dados.

| Recurso | Regra |
|---|---|
| Apps instalados | Usar escopo justificado e fallback. |
| Modo Foco / DND | Opt-in, reversível e não bloqueante. |
| Internet | Apenas com função real e política correspondente. |
| Firebase | Sem Analytics; só Crashlytics/Remote Config se aprovado. |
| Ads/Analytics/Atribuição | Proibidos no MVP. |
| Billing | Apenas com fase aprovada e Play Console pronto. |

Antes da loja, publicar Política de Privacidade em URL pública real e ativar link funcional no app.

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

Quando houver UI, também validar em aparelho físico. Quando houver fase de release ou auditoria, rodar checklist do projeto para verificar dependências, permissões, Firebase, Billing, strings hardcoded, logs, TODOs, placeholders, arquivos sensíveis, privacidade, Apex Scan, Boost Mode e efeitos placebo.

---

## 17. Critério de rejeição automática

Rejeitar qualquer implementação que pareça fundo preto com texto verde, use glow exagerado para esconder layout fraco, gere overflow, quebre navegação, adicione dependência sem aprovação, prometa melhoria técnica falsa, misture placebo com métrica real, mexa em Firebase/Billing antes da hora, introduza tracking/ads, altere identidade Android sem autorização ou faça commit sem aprovação.

Também rejeitar qualquer fase que declare “testes passaram”, “aprovado no celular” ou “commit realizado” sem evidência reproduzível. Histórico textual do agente não é prova suficiente; logs, diffs, hash, screenshots e execução no app devem ser anexados quando necessário.

---

## 18. Roadmap recomendado

| Ordem | Fase | Objetivo |
|---:|---|---|
| 1 | STORE-U1.2B | Publicar política de privacidade em URL real e ativar link no Sobre. |
| 2 | LANG-U1.6 | Validar PT-BR/EN/ES em fluxo completo. |
| 3 | AUDIT-U1 | Rodar checklist e registrar evidências do estado atual. |
| 4 | UX-P1 | Implementar Motion/Placebo Visual controlado. |
| 5 | BOOST-U1 | Estruturar Boost Engine de 8 etapas honestas. |
| 6 | RESULT-U1 | Criar Prep Result e card compartilhável, se aprovado. |
| 7 | DATA-U1 | Decidir Hive vs `shared_preferences` para MVP. |
| 8 | OBS-U1 | Decidir Crashlytics/Remote Config. |
| 9 | BILL-U1 | Implementar one-time unlock, restore e startup check. |
| 10 | RELEASE-U1 | Build release, checklist Play Store, screenshots e submissão. |

---

## 19. Regra final

Qualidade acima de velocidade. O objetivo não é apenas fazer telas funcionarem; é construir um produto Android gamer premium, honesto, vendável, tecnicamente limpo e visualmente forte. Se uma implementação passa nos testes, mas parece ruim no celular, ela está reprovada. Se parece bonita, mas promete algo tecnicamente falso, ela também está reprovada. Se usa placebo visual com honestidade, estética e clareza, ela é bem-vinda.
---

## 20. Diretrizes de Segurança: Apex Booster+ (OWASP LLM Top 10)

Você deve agir como um Engenheiro de Segurança de Software Sênior. Toda API interna, serviço, integração futura, fluxo de Billing, restore purchase, unlock, métricas, score, sessão, telemetria local, validação de progresso, backend futuro ou qualquer lógica sensível gerada ou modificada para o Apex Booster+ deve ser projetada contra manipulação, abuso, injeção e vazamento de dados, seguindo controles inspirados no OWASP LLM Top 10 e boas práticas modernas de segurança.

Estas diretrizes devem ser aplicadas com recursos gratuitos e práticas de engenharia disponíveis no próprio projeto: validação de entrada, normalização, sanitização, limites de tamanho, whitelists, logs seguros, testes automatizados, revisão de diffs, separação entre dados e instruções, proteção contra replay quando houver backend e checklist manual de segurança antes de entrega. Não adicionar ferramenta paga, serviço externo ou dependência nova apenas para cumprir esta seção sem aprovação explícita.

### 20.1 Prevenção contra LLM01: Prompt Injection e Injeção de Dados

- Trate todas as entradas de usuário como dados não confiáveis.
- Separe dados textuais, nomes de jogos, `packageName`, histórico, métricas, logs e preferências de qualquer instrução de execução.
- Valide tipo, tamanho e formato de entradas sensíveis usando regras explícitas.
- Nunca confie em lógica crítica executada apenas no lado do cliente quando houver backend, Billing, unlock, restore purchase, score, progressão ou validação remota.
- Nenhum texto vindo do usuário, app instalado, nome de jogo, resposta externa ou campo persistido pode alterar regras internas do produto.
- Nomes de jogos, labels, mensagens de erro e dados persistidos devem ser tratados como conteúdo, não como comando.
- Quando houver integração futura com IA, prompts e dados devem ser separados por estrutura clara, e saídas devem ser consideradas não confiáveis até validação.

### 20.2 Prevenção contra LLM02: Insecure Output Handling

- Sanitize e normalize toda saída antes de renderização, persistência, logs, relatórios ou uso em integrações.
- Evite inserir conteúdo externo diretamente em UI, banco local, logs ou futuras APIs sem validação.
- Se no futuro houver backend, banco de dados ou painel administrativo, encode outputs para reduzir risco de SQL/NoSQL injection, XSS, log injection ou corrupção de dados.
- Mensagens geradas por IA, caso existam no futuro, devem ser tratadas como conteúdo não confiável até validação.
- Textos exibidos na UI devem passar por `AppStrings` quando forem copy do produto e por validação/normalização quando vierem de origem externa.
- Logs devem ser úteis para depuração, mas nunca devem virar canal de vazamento de dados sensíveis.

### 20.3 Prevenção contra LLM06: Sensitive Data Disclosure

- Não expor dados sensíveis, identificadores privados, tokens, chaves, recibos de compra, logs brutos ou informações pessoais em telas, logs, commits ou relatórios.
- Mascarar qualquer dado sensível antes de trafegar, registrar ou usar em contexto de IA.
- Nunca commitar secrets, keystore, `key.properties`, `google-services.json`, chaves privadas, tokens de API ou credenciais.
- A política de privacidade deve refletir exatamente os dados usados pelo app.
- Recibos de compra, status de unlock, IDs de transação, identificadores de dispositivo e dados de diagnóstico não devem ser exibidos integralmente em UI, prints públicos, logs de produção ou documentação compartilhável.
- Antes de qualquer integração com Firebase, Billing, backend ou Play Console, revisar se os dados trafegados estão cobertos pela política de privacidade e pela necessidade real do produto.

### 20.4 Blindagem específica de APIs, Billing, métricas e unlock

Estas regras são preventivas para fases futuras. Aplicar apenas quando houver backend, API remota, Billing, restore purchase, unlock, score, telemetria ou sincronização externa.

- Assinatura baseada em HMAC: qualquer requisição futura que envie, atualize ou valide pontuação, unlock, recibo, sessão, score ou métrica sensível deve usar assinatura HMAC ou mecanismo equivalente gerado em ambiente confiável, nunca hardcoded no cliente.
- Validação de estado: progresso, sessão, compra, restore, unlock e status premium devem respeitar sequência cronológica válida. Não aceitar atualização de estado alto sem registros coerentes anteriores.
- Rate limiting inteligente: limitar chamadas sensíveis por usuário, dispositivo, compra, IP ou identificador equivalente quando houver backend.
- Replay protection: usar timestamp, nonce ou mecanismo equivalente em APIs futuras sensíveis.
- Server-side validation: compras, restore, unlock e estados comerciais não devem depender exclusivamente de flags locais em release comercial.
- Logs seguros: nunca registrar recibos completos, tokens, secrets, HMAC, payloads sensíveis ou dados privados em logs de produção.
- Client-side flags podem existir para desenvolvimento, protótipo ou cache local, mas não devem ser tratadas como verdade comercial em release quando houver Billing real.
- Qualquer fallback local de desenvolvimento para unlock deve ser explicitamente bloqueado ou removido no build de release.

### 20.5 Segurança gratuita obrigatória no fluxo de desenvolvimento

Sem adicionar dependências, serviços pagos ou ferramentas externas, toda fase que tocar dados sensíveis, Billing, unlock, métricas, sessões, logs, IA, backend futuro ou validação de estado deve aplicar, quando fizer sentido:

- validação de entrada por tipo, tamanho e formato;
- normalização de strings antes de persistir ou comparar;
- whitelists para valores esperados;
- tratamento seguro de erro sem expor stack trace sensível ao usuário;
- logs mínimos e mascarados;
- testes unitários para entradas inválidas, vazias, longas, malformadas e inesperadas;
- revisão de `git diff` antes de commit;
- verificação de que nenhum secret foi incluído no repositório;
- execução de `flutter analyze`, `flutter test` e checker de strings quando houver copy.

### 20.6 Autoauditoria obrigatória antes de entregar código

Antes de entregar qualquer trecho de código, arquivo modificado ou prompt de implementação que toque APIs, Billing, unlock, restore, métricas, score, sessões, logs, IA, backend ou dados sensíveis, o agente deve listar uma autoauditoria curta com:

- quais regras desta seção foram aplicadas;
- quais riscos foram considerados;
- quais dados foram tratados como não confiáveis;
- quais validações foram adicionadas;
- quais pontos continuam fora de escopo ou dependem de fase futura.

---

# ADENDO 2026-06-10 — Funções Inovadoras e Camada Premium Memorável

**Autor do adendo:** Manus AI  
**Natureza do adendo:** acréscimo operacional ao `CLAUDE.md`, sem remoção, reescrita ou invalidação das regras anteriores.  
**Documentos incorporados:** `Funcionalidades_Inovadoras_Pouco_Exploradas_pelos_.md` e `Matriz_de_Lacunas_Competitivas_—_APEX_BOOSTER+.md`.  
**Regra comercial preservada:** **free install + one-time unlock**.

Este adendo deve ser obedecido junto com todas as seções anteriores deste arquivo. Em caso de aparente conflito, vencem as regras mais restritivas de honestidade técnica, privacidade, preservação do app existente, aprovação humana e proibição de claims falsos.

> **Regra operacional do adendo:** implementar as funcionalidades inovadoras como acréscimo incremental e controlado. Não recomeçar o app, não redesenhar telas congeladas sem aprovação e não transformar placebo visual em promessa técnica.

---

## 21. Camada Premium Memorável obrigatória

A continuidade do APEX BOOSTER+ deve incluir uma camada premium memorável. Essa camada não substitui as pendências oficiais; ela organiza os próximos refinamentos para que o app pareça referência no segmento, e não apenas um utilitário correto.

| Componente | Obrigação operacional | Proibição explícita |
|---|---|---|
| Apex Visual System | Criar Apex Core, Apex Ring, Apex Pulse, Apex Grid e Status Chips reutilizáveis | Não usar esses elementos para sugerir CPU/GPU/FPS real. |
| Apex Ritual Cinematográfico | Refinar Boost Apex como ritual curto, bonito e honesto | Não bloquear abertura do jogo nem prometer boost real. |
| Apex Result Card | Criar fechamento visual com dados seguros e CTA Abrir Jogo | Não exibir FPS/ping inventados ou dados sensíveis. |
| Honest Booster Mode | Explicar o que o app faz e não faz | Não esconder limitações técnicas. |
| Session Profiles | Reposicionar GFX/foco/visual como perfis de sessão | Não afirmar alteração de engine, resolução ou arquivos do jogo. |
| Widget e Quick Actions | Reduzir atrito e aumentar recorrência | Não exibir “FPS boost ativo”, “ping reduzido” ou “RAM limpa”. |
| Badges e Resumo Semanal | Enriquecer histórico local | Não criar gamificação abusiva ou notificação insistente. |
| Temas Contextuais | Valor visual premium | Não dizer que tema melhora performance. |

---

## 22. Novas fases operacionais recomendadas

As fases abaixo devem ser usadas para orientar tarefas futuras no repositório. Cada fase exige declaração prévia de arquivos prováveis, riscos, testes e evidências visuais quando houver UI.

| Fase | Nome | Objetivo | Dependência | Evidência mínima |
|---|---|---|---|---|
| PREMIUM-U1 | Apex Visual System | Criar tokens/componentes Apex Core, Ring, Pulse, Grid e Status Chips | Design atual | Screenshots Home/Preparar/Resultado e teste de overflow. |
| PREMIUM-U2 | Apex Ritual Cinematográfico | Refinar Boost Apex em fluxo curto com etapas reais/simbólicas | PREMIUM-U1 | Vídeo ou sequência de screenshots + validação de copy. |
| PREMIUM-U3 | Apex Result Card | Criar card pós-preparo com jogo, perfil, tempo, status e CTA | PREMIUM-U2 | Screenshot de card e teste de abertura do jogo. |
| TRUST-U1 | Honest Booster Mode | Criar explicação clara sobre FPS, ping, RAM, unlock e limites técnicos | Strings/i18n | PT-BR/EN/ES validados. |
| PROFILE-U1 | Session Profiles | Expandir GFX para perfis Balanced, Focus, Visual, Battery Mindful e Custom | Persistência local | Teste de salvar/carregar por jogo. |
| RETENTION-U1 | Badges locais | Criar badges de uso, recorrência e variedade | Histórico | Teste de persistência local. |
| RETENTION-U2 | Resumo Semanal Local | Criar card “Sua semana gamer” | RETENTION-U1 | Dados locais coerentes e copy segura. |
| CONVENIENCE-U1 | Quick Actions | Atalhos do ícone do app | Navegação estável | Teste em aparelho/emulador Android. |
| CONVENIENCE-U2 | Widget Premium | Widget de favorito/última sessão | Favoritos estáveis | Screenshot do widget e teste de atualização. |
| SHARE-U1 | Share Card Seguro | Compartilhamento opcional do Result Card | PREMIUM-U3 | Arquivo/imagem gerado sem dados sensíveis. |
| THEME-U1 | Temas Contextuais | Tema visual por jogo/perfil | PREMIUM-U1 | Screenshots comparativos e validação de contraste. |
| ACCESS-U1 | Modo Baixa Distração | Reduzir animações, brilho, haptics e duração | Motion System | Toggle funcional e validação visual. |

---

## 23. Contrato de copy das funcionalidades inovadoras

Toda copy nova deve existir em `AppStrings` para PT-BR, EN e ES. Não espalhar strings hardcoded. As novas funcionalidades devem usar linguagem de preparação e experiência, nunca linguagem de ganho técnico não comprovado.

| Contexto | Copy aprovada PT-BR | Copy proibida |
|---|---|---|
| Ritual | “Sessão pronta para abrir.” | “FPS aumentado.” |
| Perfil | “Perfil da sessão carregado.” | “Configuração interna do jogo aplicada.” |
| Result Card | “Preparado em 6s.” | “Jogo otimizado em 6s.” |
| Widget | “Preparar favorito.” | “Ativar turbo real.” |
| Honest Mode | “Não prometemos aumento real de FPS.” | “Boost garantido em todos os jogos.” |
| Badge | “5 sessões esta semana.” | “Performance melhorada 5 vezes.” |
| Tema | “Tema visual aplicado ao Apex.” | “Gráficos do jogo melhorados.” |
| Checklist | “Conexão verificada.” | “Ping reduzido.” |

---

## 24. Session Profiles e compatibilidade com GFX Profile

Session Profiles devem ser implementados como camada semântica acima das preferências locais existentes. Eles podem reutilizar dados do GFX Profile, Modo Foco e preferências visuais, mas não podem declarar alterações reais no jogo.

| Session Profile | Composição permitida | Observação operacional |
|---|---|---|
| Balanced | Ritual normal, tema padrão, checklist básico e GFX Equilibrado quando aplicável | Perfil padrão e seguro. |
| Focus | Modo Foco, animação reduzida, CTA direto e chips de foco | Deve respeitar opt-in do usuário. |
| Visual | Apex Core completo, tema premium e Result Card destacado | Valor premium visual. |
| Battery Mindful | Motion reduzido, brilho menor e ritual curto | Não prometer economia real sem medição. |
| Custom | Preferências de tema, duração, haptic, favoritos e checklist | Pode exigir persistência mais estruturada. |

Se a implementação exigir Hive, BLoC, DI, Firebase, Billing ou nova permissão, abrir fase específica e pedir aprovação quando aplicável.

---

## 25. Widget, Quick Actions e limitações Android

Widget e Quick Actions são desejáveis para valor premium, mas devem respeitar as limitações do Android, do Flutter e dos plugins necessários. Não adicionar plugin nativo sem justificar impacto no build, privacidade e testes.

| Recurso | Permitido | Bloqueado |
|---|---|---|
| Widget de favorito | Mostrar jogo favorito, botão preparar e última sessão | Mostrar FPS/ping/boost real. |
| Widget médio | Mostrar 2 a 4 favoritos | Coletar dados externos sem necessidade. |
| Widget de resultado | Mostrar última sessão local | Expor informações sensíveis. |
| Quick Action favorito | Abrir fluxo de preparação | Pular disclaimers obrigatórios quando necessários. |
| Quick Action histórico | Abrir Histórico | Alterar fluxo central sem teste. |

---

## 26. Badges, Streaks e Resumo Semanal

A retenção local deve ser honesta e controlada. Badges e streaks não podem criar sensação de obrigação, vício ou pressão. Notificações, se um dia forem adicionadas, exigem fase e aprovação explícita.

| Item | Regra |
|---|---|
| Badges | Devem ser locais, discretos e baseados em eventos reais do app. |
| Streaks | Devem ser informativos, não punitivos. |
| Resumo semanal | Deve usar somente histórico local e linguagem neutra. |
| Histórico enriquecido | Não pode inventar melhoria de performance. |
| Privacidade | Não sincronizar com servidor sem nova decisão de arquitetura e política. |

---

## 27. Share Card Seguro

Share Card só pode ser implementado se for seguro por padrão. Ele deve ser opcional, visualmente premium e sem dados sensíveis. O compartilhamento deve exportar uma peça estética do APEX BOOSTER+, não um relatório técnico falso.

| Elemento | Status |
|---|---|
| Nome do jogo | Permitido. |
| Ícone/arte visual do app | Permitido. |
| Badge local | Permitido. |
| Tempo de preparação real | Permitido. |
| FPS, ping, CPU, GPU, RAM como melhoria | Proibido. |
| Modelo do dispositivo | Proibido por padrão. |
| Lista de apps instalados | Proibido. |
| Identificadores do usuário/dispositivo | Proibido. |

---

## 28. Atualização das pendências oficiais

Sem remover as pendências da seção 7, acrescentar as seguintes pendências de inovação ao acompanhamento do projeto.

| Bloco | Pendência | Prioridade |
|---|---|---:|
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

---

## 29. Atualização da matriz Free versus One-time Unlock

A comunicação comercial deve continuar usando exatamente **free install + one-time unlock**. A versão gratuita precisa demonstrar utilidade; o desbloqueio único deve liberar a experiência completa e premium.

| Camada | Free install | One-time unlock |
|---|---|---|
| Biblioteca | Uso essencial da biblioteca e abertura de jogos | Conveniência avançada, favoritos refinados e atalhos quando implementados. |
| Preparação | Ritual básico e honesto | Apex Ritual completo e variações visuais premium. |
| Perfis | Perfil/GFX básico | Session Profiles avançados e Custom. |
| Resultado | Resultado simples | Apex Result Card premium e Share Card seguro. |
| Histórico | Histórico essencial | Badges, streaks e resumo semanal local. |
| Visual | Tema padrão | Temas contextuais e skins visuais. |
| Conveniência | Navegação pelo app | Widget e Quick Actions. |
| Confiança | Honest Booster Mode | Também disponível; confiança não deve ser bloqueada por paywall. |

---

## 30. Regra final do adendo

As funcionalidades inovadoras devem aumentar o valor percebido do APEX BOOSTER+ sem quebrar sua honestidade. O produto pode ser bonito, forte, memorável e premium, mas deve continuar dizendo a verdade: ele prepara, organiza, personaliza e cria uma experiência gamer antes da partida; ele não promete alterar FPS, ping, CPU, GPU, RAM ou desempenho real de jogos terceiros.


---

# ANEXO DE RASTREABILIDADE — Documento de Funcionalidades Inovadoras incorporado

> O conteúdo abaixo é mantido como referência interna de rastreabilidade da consolidação. Ele não revoga nem substitui as seções anteriores; apenas preserva a fonte que motivou os acréscimos.

# Funcionalidades Inovadoras Pouco Exploradas pelos Concorrentes para o Apex Booster+

**Autor:** Manus AI  
**Data:** 10/06/2026  
**Produto:** Apex Booster+  
**Modelo comercial obrigatório:** **free install + one-time unlock**  
**Objetivo:** propor funcionalidades inovadoras, premium e honestas que diferenciem o Apex Booster+ dos game boosters populares, sem recorrer a claims falsos de FPS, ping, CPU, GPU ou RAM.

---

## 1. Tese estratégica

A oportunidade do Apex Booster+ não está em copiar a promessa tradicional de game boosters. Muitos concorrentes do segmento se posicionam em torno de velocidade, limpeza, gerenciamento, modo jogo, redução de distrações ou launcher de jogos.[1] [2] [3] [4] Esses recursos podem ser úteis como referência competitiva, mas não bastam para tornar o Apex Booster+ memorável. O caminho mais forte é criar uma experiência própria: **um ritual premium de preparação gamer**, com identidade visual, perfis por jogo, recompensa pós-preparo, conveniência na tela inicial e retenção local.

A inovação recomendada deve obedecer a três regras. Primeiro, precisa ser perceptível pelo usuário em poucos segundos. Segundo, precisa ser tecnicamente honesta. Terceiro, precisa reforçar o modelo **free install + one-time unlock**, deixando claro que o pagamento único desbloqueia acabamento, personalização e conveniência, não uma promessa impossível de performance universal.

> **Tese final:** o Apex Booster+ pode se diferenciar ao assumir que seu produto real não é “turbinar hardware”, mas sim entregar o melhor cockpit Android para entrar em uma sessão gamer com foco, estética, controle e rotina.

---

## 2. Mapa de lacunas competitivas

A análise competitiva anterior indicou que os concorrentes são fortes em promessas simples e atalhos diretos, mas pouco exploram narrativa de preparação, recompensa visual pós-sessão, honestidade explícita, badges locais, perfis de sessão com linguagem segura e monetização premium transparente. Essa lacuna é especialmente importante porque o Apex Booster+ precisa competir tanto na utilidade quanto na percepção de qualidade.

| Área observada no mercado | Exploração comum nos concorrentes | Lacuna para o Apex Booster+ | Oportunidade de inovação |
|---|---|---|---|
| Booster visual | Botões de boost e animações genéricas | Pouca identidade proprietária | Criar Apex Core, Apex Ring e Apex Pulse. |
| Launcher de jogos | Listas ou grades funcionais | Pouca sensação de cockpit premium | Criar Home hero e Game Hero Card. |
| Modo jogo | Bloqueio de distrações e ajustes básicos | Pouca personalização por jogo | Criar Session Profiles por jogo. |
| Resultado final | Normalmente inexistente ou simples | Falta recompensa após preparar | Criar Apex Result Card. |
| Retenção | Uso depende de abrir jogo pelo app | Poucos motivos emocionais para voltar | Badges, streaks e resumo semanal local. |
| Transparência | Claims agressivos de performance | Pouca honestidade explícita | Criar “Honest Booster Mode”. |
| Monetização | Ads, PRO, assinaturas ou compras confusas | Falta promessa simples de valor | Comunicar **free install + one-time unlock**. |

---

## 3. Funcionalidades inovadoras prioritárias

As funcionalidades abaixo foram selecionadas por terem alto potencial de diferenciação e por serem coerentes com o PRD Definitivo. Elas não exigem alegar melhoria real de FPS ou ping. O valor vem de experiência, organização, conveniência, personalização e confiança.

| Prioridade | Funcionalidade | Grau de inovação | Impacto no produto | Risco técnico/político |
|---:|---|---|---|---|
| P0 | Apex Ritual Cinematográfico | Alto | Cria assinatura do app | Baixo, se copy for honesta. |
| P0 | Apex Result Card | Alto | Fecha o ciclo de preparo | Baixo. |
| P0 | Honest Booster Mode | Alto | Diferencia por confiança | Baixo; exige boa copy. |
| P1 | Session Profiles por jogo | Alto | Aumenta personalização | Médio, depende de UX clara. |
| P1 | Widget Premium de Jogo Favorito | Médio/alto | Aumenta recorrência | Médio, depende de Android widgets. |
| P1 | Quick Actions Inteligentes | Médio | Reduz atrito | Baixo/médio. |
| P1 | Badges locais e streaks | Médio/alto | Cria retenção | Baixo. |
| P1 | Resumo Semanal Local | Alto | Dá sentido ao histórico | Baixo. |
| P2 | Share Card social | Médio/alto | Gera divulgação orgânica | Baixo, se não expuser dados sensíveis. |
| P2 | Apex Focus Checklist | Médio | Reforça preparação real | Baixo. |
| P2 | Temas contextuais por jogo | Médio | Valor premium visual | Baixo. |
| P2 | Modo Baixa Distração | Médio | Acessibilidade e foco | Baixo. |

---

## 4. Apex Ritual Cinematográfico

O **Apex Ritual Cinematográfico** deve ser o momento assinatura do produto. Em vez de um botão que simplesmente mostra uma barra de progresso genérica, o app conduz o usuário por uma preparação curta, visual e honesta. Esse ritual deve durar poucos segundos e terminar em uma tela clara de resultado.

A experiência recomendada é inspirada em interfaces de cockpit: núcleo central, anel de progresso, etapas curtas, microcopy segura e conclusão com feedback visual. O ritual deve ser bonito o bastante para ser lembrado, mas rápido o suficiente para não virar obstáculo.

| Etapa | Nome sugerido | Tipo de valor | Texto seguro |
|---|---|---|---|
| 1 | Game Lock | Seleção real do jogo | “Jogo selecionado.” |
| 2 | Profile Load | Perfil local | “Perfil da sessão carregado.” |
| 3 | Focus Prep | Ajuste/opção real quando disponível | “Preferências de foco prontas.” |
| 4 | Visual Sync | Feedback simbólico | “Apex visual ativo.” |
| 5 | Ready State | Conclusão | “Sessão pronta para abrir.” |

Essa funcionalidade é pouco explorada porque a maioria dos boosters tenta vender resultado técnico. O Apex Booster+ pode vender uma **rotina premium**. Essa diferença é fundamental para cumprir a promessa sem risco de claim enganoso.

---

## 5. Apex Result Card

O **Apex Result Card** é uma das maiores oportunidades de diferenciação. Concorrentes normalmente tratam o “boost” como uma ação isolada. O Apex Booster+ deve transformar o final da preparação em uma recompensa visual. O card deve mostrar o jogo, o perfil usado, a hora, o status da preparação, um badge local e um botão para abrir o jogo.

| Elemento do card | Finalidade | Exemplo de copy |
|---|---|---|
| Ícone e nome do jogo | Confirma contexto | “Call of Duty Mobile” |
| Perfil usado | Reforça personalização | “Focus Profile” |
| Tempo da preparação | Dado real | “Preparado em 6s” |
| Status | Resultado honesto | “Checklist concluído” |
| Badge local | Recompensa | “5 sessões esta semana” |
| Compartilhar | Viralidade opcional | “Compartilhar card” |

O compartilhamento deve ser opcional e controlado. O card não deve expor dados sensíveis, lista de apps, identificadores do dispositivo ou métricas técnicas não verificadas. A melhor versão é estética e simples: nome do jogo, arte abstrata, badge e marca Apex Booster+.

---

## 6. Honest Booster Mode

O **Honest Booster Mode** é uma inovação de posicionamento. Em vez de esconder limitações técnicas, o app declara com clareza o que faz e o que não faz. Isso pode parecer contraintuitivo em um mercado cheio de promessas, mas pode virar vantagem competitiva para usuários mais maduros e para reduzir risco de rejeição na loja.

| Pergunta do usuário | Resposta recomendada dentro do app |
|---|---|
| “O app aumenta FPS?” | “O Apex Booster+ não promete aumento real de FPS. Ele prepara sua sessão com organização, perfis, foco e experiência visual.” |
| “O app reduz ping?” | “Ping depende da rede, servidor e operadora. O Apex Booster+ evita prometer controle sobre isso.” |
| “O que o unlock libera?” | “Temas, ritual premium, perfis avançados, histórico completo, badges, widget e cards.” |
| “Por que usar antes de jogar?” | “Para entrar com seus jogos organizados, perfil carregado e uma rotina visual de foco.” |

> **Inovação de confiança:** no segmento de game boosters, honestidade explícita pode funcionar como diferencial premium, especialmente quando combinada com uma interface forte e uma compra única sem assinatura.

---

## 7. Session Profiles por jogo

Os **Session Profiles** devem reposicionar recursos como GFX, foco e preferências em uma linguagem segura. Em vez de dizer que um perfil “aumenta performance”, o app deve dizer que ele define uma preparação visual e comportamental por jogo.

| Perfil | Proposta | Recursos associados | Copy segura |
|---|---|---|---|
| Balanced | Padrão equilibrado | Ritual normal, tema padrão, checklist básico | “Preparação equilibrada.” |
| Focus | Menos distrações | Modo foco, animação reduzida, CTA direto | “Entre com foco.” |
| Visual | Experiência estética | Apex Core completo, tema e Result Card premium | “Ritual visual completo.” |
| Battery Mindful | Menos animações | Motion reduzido, brilho menor, ritual curto | “Preparação leve.” |
| Custom | Perfil do usuário | Tema, duração, feedback e favoritos | “Seu jeito de preparar.” |

Essa funcionalidade é inovadora porque transforma a ideia de “boost” em **preferências de sessão**. Ela gera valor real e reduz risco jurídico e técnico. Além disso, cria forte argumento para o **one-time unlock**, já que perfis avançados são fáceis de entender como recurso premium.

---

## 8. Widget Premium de Jogo Favorito

O widget é uma funcionalidade de conveniência que poucos boosters tratam como elemento premium central. Para o Apex Booster+, ele pode ser uma das melhores formas de retenção, porque coloca o app na tela inicial do usuário.

| Tipo de widget | Comportamento | Valor percebido |
|---|---|---|
| Mini Widget | Mostra jogo favorito e botão “Preparar” | Acesso rápido com pouco espaço. |
| Medium Widget | Mostra 2 a 4 jogos favoritos | Parece launcher gamer na tela inicial. |
| Result Widget | Mostra última sessão preparada | Reforça hábito e histórico. |
| Focus Widget | Acesso direto ao perfil Focus | Valor para usuários competitivos. |

O widget deve respeitar a honestidade do produto. Ele não deve mostrar “FPS boost ativo” ou “ping reduzido”. Deve mostrar “última sessão”, “perfil favorito”, “preparar jogo” e “abrir jogo”.

---

## 9. Quick Actions inteligentes

As **Quick Actions** no ícone do app reduzem atrito e dão sensação de app bem integrado ao Android. Elas podem incluir abrir último jogo, preparar favorito, abrir biblioteca e ver histórico.

| Ação rápida | Destino | Benefício |
|---|---|---|
| Preparar favorito | Ritual direto do jogo principal | Uso recorrente em um toque. |
| Abrir último jogo | Game launcher | Conveniência imediata. |
| Biblioteca | Lista de jogos | Navegação rápida. |
| Histórico | Últimas sessões | Reforça progresso. |

Essa inovação não é chamativa como um visual cinematográfico, mas aumenta muito a percepção de maturidade do app. Apps premium costumam vencer pela soma de detalhes bem acabados.

---

## 10. Badges locais, streaks e resumo semanal

A retenção do Apex Booster+ pode ser construída sem servidor e sem gamificação invasiva. Badges locais, sequência de uso e resumo semanal fazem o usuário sentir progresso sem transformar o app em rede social.

| Mecânica | Exemplo | Cuidado necessário |
|---|---|---|
| Badge por uso | “Primeira sessão preparada” | Não exagerar em notificações. |
| Badge por consistência | “3 dias jogando com preparo” | Não induzir uso compulsivo. |
| Badge por variedade | “5 jogos adicionados” | Recompensar exploração. |
| Resumo semanal | “Você preparou 8 sessões em 4 jogos” | Usar dados locais claros. |
| Histórico enriquecido | Sessões por jogo e perfil | Evitar métricas falsas de performance. |

O resumo semanal é especialmente forte porque transforma o histórico em narrativa. Ele pode ser apresentado como um card local: “Sua semana gamer”. Isso dá ao usuário um motivo para abrir o app mesmo quando não vai iniciar uma partida naquele momento.

---

## 11. Apex Focus Checklist

O **Apex Focus Checklist** é uma funcionalidade simples e honesta que pode ser mais valiosa do que um claim falso de performance. Antes de abrir o jogo, o app exibe um checklist personalizável com itens como volume, bateria, conexão, modo não perturbe, carregador e postura de foco.

| Item | Tipo | Automação possível |
|---|---|---|
| Bateria suficiente | Real | Leitura de nível de bateria. |
| Volume pronto | Real/parcial | Verificação ou lembrete. |
| Conexão adequada | Real/parcial | Indicar Wi-Fi/dados sem prometer ping. |
| Modo foco | Real se opt-in | Atalho para configuração. |
| Notificações | Real se permissão existir | Orientar usuário. |
| Perfil da sessão | Local | Carregar preferências. |

Essa funcionalidade reforça a tese de preparação. Ela substitui a falsa promessa de “otimizar tudo” por uma lista concreta de prontidão.

---

## 12. Share Card social seguro

O compartilhamento pode gerar divulgação orgânica, mas precisa ser desenhado com cuidado. O card deve ser bonito, opcional e sem dados sensíveis. Ele pode mostrar marca, jogo, perfil e badge local, mas deve evitar lista completa de apps, localização, identificadores, métricas técnicas ou prints automáticos de tela.

| Elemento | Incluir? | Justificativa |
|---|---|---|
| Nome do jogo | Sim | Contexto central do card. |
| Badge local | Sim | Recompensa e orgulho. |
| Tempo de preparo | Sim, se real | Dado simples e verificável. |
| FPS/ping | Não | Alto risco de claim falso. |
| Modelo do dispositivo | Não por padrão | Privacidade. |
| Nome do usuário | Opcional | Deve ser configurável. |

---

## 13. Temas contextuais por jogo

Temas são um recurso premium de alto valor percebido e baixo risco. A inovação está em permitir que cada jogo tenha um tema de sessão. Por exemplo, jogos de tiro podem usar tema tático, jogos de corrida podem usar tema velocidade visual, MOBAs podem usar tema estratégia e jogos casuais podem usar tema minimalista.

| Tema | Personalidade | Uso recomendado |
|---|---|---|
| Neon Green | Clássico gamer | Padrão Apex. |
| Cyber Blue | Tecnologia e precisão | Jogos competitivos. |
| Inferno Orange | Energia e ação | Shooters e corrida. |
| Purple Void | Estética futurista | RPGs e jogos sci-fi. |
| Minimal Pro | Discreto e limpo | Usuários que preferem menos glow. |

A copy deve deixar claro que o tema muda a experiência visual do Apex Booster+, não o desempenho técnico do jogo.

---

## 14. Roadmap de inovação recomendado

A implementação deve priorizar recursos que criem identidade antes de recursos periféricos. O erro seria começar por muitas configurações e deixar a experiência principal sem personalidade. A ordem abaixo maximiza percepção premium e minimiza risco.

| Ordem | Entrega | Resultado esperado | Dependência |
|---:|---|---|---|
| 1 | Apex Visual System | Identidade visual consistente | Tokens e componentes base. |
| 2 | Apex Ritual Cinematográfico | Momento assinatura | Home e seleção de jogo. |
| 3 | Apex Result Card | Fechamento da jornada | Ritual concluído. |
| 4 | Honest Booster Mode | Confiança e política | Microcopy e tela informativa. |
| 5 | Session Profiles | Personalização por jogo | Biblioteca e armazenamento local. |
| 6 | Badges e resumo semanal | Retenção | Histórico local. |
| 7 | Widget e Quick Actions | Conveniência | Favoritos e último jogo. |
| 8 | Share Card | Divulgação orgânica | Result Card estável. |
| 9 | Temas contextuais | Valor premium adicional | Sistema visual maduro. |
| 10 | Store polish | Conversão | Screenshots e vídeo. |

---

## 15. Matriz de impacto versus esforço

A matriz abaixo organiza as funcionalidades por retorno esperado e complexidade relativa. O objetivo é orientar o refinamento do app já produzido, priorizando o que mais aproxima o Apex Booster+ de uma referência no segmento.

| Funcionalidade | Impacto percebido | Esforço | Prioridade prática |
|---|---|---|---|
| Apex Ritual | Muito alto | Médio | Implementar imediatamente. |
| Apex Result Card | Muito alto | Médio | Implementar imediatamente. |
| Honest Booster Mode | Alto | Baixo | Implementar imediatamente. |
| Temas premium | Alto | Baixo/médio | Implementar após sistema visual. |
| Session Profiles | Muito alto | Médio/alto | Implementar como pilar premium. |
| Badges locais | Médio/alto | Baixo/médio | Implementar para retenção. |
| Resumo semanal | Alto | Médio | Implementar após histórico. |
| Widget | Alto | Médio/alto | Implementar após favoritos estáveis. |
| Quick Actions | Médio/alto | Baixo/médio | Implementar com widget ou antes. |
| Share Card | Médio | Médio | Implementar após Result Card. |

---

## 16. Como essas inovações reforçam o one-time unlock

O **one-time unlock** precisa desbloquear uma experiência que o usuário veja e use. As funcionalidades inovadoras propostas ajudam exatamente nisso: elas criam valor tangível e recorrente.

| Recurso inovador | Fica gratuito? | Fica desbloqueado? | Justificativa |
|---|---|---|---|
| Ritual básico | Sim | Ritual completo premium | O free demonstra valor; o unlock encanta. |
| Result simples | Sim | Result Card premium e share | A compra melhora recompensa visual. |
| Honest Booster Mode | Sim | Sim | Confiança deve existir para todos. |
| Perfis básicos | Sim | Perfis por jogo e custom | Personalização avançada é premium. |
| Histórico curto | Sim | Histórico completo e resumo semanal | Retenção avançada justifica unlock. |
| Tema padrão | Sim | Temas premium | Valor visual claro. |
| Widget limitado | Opcional | Widget completo | Conveniência é valor premium. |
| Quick Actions | Parcial | Ações avançadas | Bom equilíbrio de demonstração e upgrade. |

Essa estrutura permite que o usuário experimente o produto sem pagar e entenda por que vale desbloquear. A venda fica mais honesta e mais forte.

---

## 17. Riscos e salvaguardas

Funcionalidades inovadoras também podem gerar riscos se forem mal comunicadas. A principal salvaguarda é separar sempre **experiência visual** de **resultado técnico real**.

| Risco | Exemplo de erro | Salvaguarda |
|---|---|---|
| Claim enganoso | “FPS otimizado” | Usar “sessão preparada” ou “perfil carregado”. |
| Excesso visual | Animações pesadas | Criar modo reduzido e limite de duração. |
| Paywall agressivo | Bloquear tudo no primeiro acesso | Entregar valor real no free install. |
| Privacidade | Share card com dados do dispositivo | Compartilhamento minimalista e opt-in. |
| Confusão com GFX | Prometer efeitos universais | Tratar como perfil visual/preferência quando aplicável. |
| Retenção abusiva | Notificações insistentes | Notificações opt-in e controláveis. |

---

## 18. Conclusão

O Apex Booster+ tem uma oportunidade rara: competir em um nicho barulhento sem repetir suas piores práticas. Em vez de prometer melhorias técnicas universais, ele pode criar uma experiência premium de preparação gamer. Essa experiência deve ser visual, rápida, honesta, personalizável e recorrente.

As funcionalidades mais inovadoras e menos exploradas pelos concorrentes são **Apex Ritual Cinematográfico, Apex Result Card, Honest Booster Mode, Session Profiles por jogo, Widget Premium, Quick Actions, Badges locais e Resumo Semanal Local**. Juntas, elas criam uma proposta difícil de copiar apenas com promessas de “boost”. Mais importante: elas sustentam o modelo **free install + one-time unlock** de forma clara, porque transformam o pagamento único em uma compra de experiência completa.

> **Resumo executivo:** o Apex Booster+ deve deixar de ser percebido como “mais um game booster” e passar a ser percebido como o **ritual premium de entrada em jogo no Android**.

---

## Referências

[1]: https://play.google.com/store/apps/details?id=com.g19mobile.gamebooster&hl=en_US "Google Play — Game Booster 4x Faster"  
[2]: https://play.google.com/store/apps/details?id=com.zappcues.gamingmode&hl=en_US "Google Play — Gaming Mode - Game Booster PRO"  
[3]: https://www.samsung.com/uk/support/mobile-devices/what-is-game-booster/ "Samsung Support — What is Game Booster"  
[4]: https://play.google.com/store/apps/details?id=com.arytan.gamebooster&hl=en_IE "Google Play — Game Booster: Manage, Launcher"  
[5]: https://www.rokform.com/blogs/rokform-blog/best-game-booster-apps-for-android-2026 "Rokform — Best Game Booster Apps for Android 2026"  
[6]: https://support.google.com/googleplay/android-developer/thread/301427350/misleading-claims-policy-help?hl=en "Google Play Help — Misleading Claims Policy Discussion"

---

# ANEXO DE RASTREABILIDADE — Matriz de Lacunas Competitivas incorporada

> O conteúdo abaixo é mantido como referência interna de rastreabilidade da consolidação. Ele não revoga nem substitui as seções anteriores; apenas preserva a fonte competitiva que motivou os acréscimos.

# Matriz de Lacunas Competitivas — APEX BOOSTER+

**Autor:** Manus AI  
**Data:** 10/06/2026  
**Base:** PRD Definitivo anexado, CLAUDE.md anexado, benchmarking público de apps de game booster e achados competitivos registrados.

---

## 1. Diagnóstico executivo

O PRD Definitivo e o CLAUDE.md estão conceitualmente corretos ao posicionar o APEX BOOSTER+ como **Gaming Prep, Scan & Launcher**, com modelo **free install + one-time unlock**, sem anúncios, sem assinatura e sem promessas técnicas falsas. Essa decisão dá ao produto uma vantagem ética e de publicabilidade frente a concorrentes que usam claims agressivos de FPS, ping, CPU/GPU e RAM.

A lacuna principal não está na direção estratégica, mas na **camada de desejo**. O produto já tem base funcional e documentação madura, porém ainda precisa transformar a sequência de preparação em uma experiência memorável, visualmente proprietária e repetível. O usuário precisa sentir que o app tem uma identidade própria, não apenas que possui telas corretas.

---

## 2. Matriz resumida de gaps

| Dimensão | Estado atual no PRD/CLAUDE | Gap percebido | Recomendação central |
|---|---|---|---|
| Posicionamento | Honesto, defensável e bem delimitado | Pode soar prudente demais frente a concorrentes agressivos | Criar narrativa de “ritual gamer premium”, não de “otimização milagrosa”. |
| Visual | Dark premium, neon controlado, motion e placebo previstos | Falta um sistema visual proprietário com assinatura Apex | Criar Apex Core, Apex Pulse, Apex Score simbólico e tela de resultado premium. |
| Funcionalidades | Biblioteca, preparar, GFX, histórico, métricas reais e abertura assistida | Falta camada de conveniência externa: widget, atalho, quick action | Adicionar widget/atalhos por jogo e modo “tap-to-play ritual”. |
| Métricas | RAM e Latência Apex próprias | Ainda pouco convincente para percepção premium | Expandir para health card honesto com bateria, rede, memória, foco e estabilidade local, se tecnicamente disponível. |
| Boost | Sequência de 8 etapas planejada | Ainda abstrata; precisa de roteiro de tela e sensação final | Implementar Boost Engine como experiência cinematográfica curta com etapas reais/simbólicas separadas. |
| GFX | Perfis locais por jogo | Pode parecer fraco se o usuário espera efeito real | Transformar GFX em “Session Style/Profile”, com presets visuais, intenção e histórico por jogo. |
| Histórico | Sessões locais | Falta progressão, rotina e retorno emocional | Criar badges de uso, streaks locais e resumo semanal sem gamificação enganosa. |
| Resultado | Card compartilhável previsto | Precisa ser tratado como feature de marketing orgânico | Criar Prep Result com score simbólico, jogo, perfil, tempo, status e visual compartilhável. |
| Monetização | free install + one-time unlock | Ainda falta arquitetura de valor percebido para compra | Definir claramente o que fica grátis e o que desbloqueia experiência premium. |
| Loja | Política, release e billing pendentes | Sem narrativa de screenshots e vídeo, o app pode parecer comum | Criar roteiro de screenshots Play Store focado em ritual, biblioteca, scan e unlock único. |

---

## 3. O “algo mais” que parece faltar

O que ainda falta não é simplesmente adicionar mais funções. O ponto central é criar uma **assinatura emocional e visual repetível**. Apps de game booster competem muito por sensação: barras animadas, feedback, HUD, status, cores fortes, promessas de energia e controle. Como o APEX BOOSTER+ não deve mentir tecnicamente, ele precisa vencer por outro caminho: **honestidade + estética superior + ritual de preparação mais bonito que o dos concorrentes**.

A oportunidade é transformar o botão de abrir jogo em um momento de marca. Em vez de “clicar e abrir”, o usuário deve sentir que ativou uma sequência Apex curta, bonita, sonora/háptica opcional, com resultado claro e abertura rápida. Esse ritual precisa virar o diferencial reconhecível do produto.

---

## 4. Recomendações prioritárias

| Prioridade | Recomendação | Por que importa |
|---:|---|---|
| P0 | Criar **Apex Core** como elemento visual central animado | Dá identidade proprietária ao produto. |
| P0 | Implementar **Boost Engine cinematográfico de 8 etapas** | Converte preparação em experiência premium. |
| P0 | Definir **free vs unlocked** com clareza | Faz o one-time unlock parecer justo e desejável. |
| P1 | Criar **Prep Result Card** compartilhável | Gera sensação de conclusão, prova visual e potencial viral. |
| P1 | Adicionar **Widget/atalho por jogo favorito** | Aproxima o app dos boosters mais práticos e populares. |
| P1 | Criar **Dashboard vivo** na Home | Evita que a tela inicial pareça estática ou genérica. |
| P1 | Expandir métricas reais quando possível | Aumenta credibilidade sem cair em promessa falsa. |
| P2 | Criar badges, streaks e resumos locais | Aumenta retenção e hábito de uso. |
| P2 | Adicionar feedback sonoro opcional | Eleva percepção premium, se for leve e desligável. |
| P2 | Preparar kit de screenshots/vídeo da Play Store | Melhora conversão e percepção profissional. |

---

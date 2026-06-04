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

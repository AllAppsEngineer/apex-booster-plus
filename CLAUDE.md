# CLAUDE.md — APEX BOOSTER+

LEIA ESTE ARQUIVO COMPLETAMENTE ANTES DE QUALQUER AÇÃO.

Este arquivo é o contrato técnico, visual e estratégico do projeto.  
Se houver conflito entre conversa, suposição e este arquivo, este arquivo vence.

---

## 1. PRODUTO

Estamos desenvolvendo o **APEX BOOSTER+**.

Tipo de produto:

App Android em Flutter para preparação gamer, diagnóstico visual, perfis locais e launcher de jogos.

Objetivo do produto:

Ajudar o usuário gamer a preparar sua sessão antes de jogar, com visual premium, leitura do ambiente, organização de jogos, perfis GFX locais, Apex Scan e abertura do jogo.

O app não vende milagre técnico.  
O app vende preparação, leitura, organização, foco, estilo e controle.

---

## 2. POSICIONAMENTO

Posicionamento técnico/mercado:

Gaming Prep, Scan & Launcher.

Importante:

Essa frase pode ser usada como referência de posicionamento técnico, documentação e loja, mas NÃO deve ser usada como frase fixa universal da interface.

A interface deve ser preparada para multilíngue.

Tagline base por idioma:

PT-BR:
Prepare. Analise. Jogue.

EN-US:
Prepare. Scan. Play.

ES:
Prepara. Analiza. Juega.

Enquanto localização completa ainda não estiver implementada, usar PT-BR como padrão visual:

Prepare. Analise. Jogue.

---

## 3. MODELO COMERCIAL OFICIAL

Decisão oficial atual do projeto:

Free install + one-time unlock.

Preço planejado:

Brasil:
R$2,99

Internacional:
US$2,99

Regras comerciais:

- Sem anúncios.
- Sem assinatura.
- Sem plano Pro.
- Sem plano Elite.
- Sem paywall recorrente.
- Sem SDK de ads.
- Desbloqueio único via Google Play Billing em fase futura.
- No MVP inicial, pode existir unlock local temporário apenas para desenvolvimento.

Não implementar Billing agora.  
Não implementar Firebase agora.  
Não implementar Analytics agora.

---

## 4. PACKAGE E IDENTIDADE ANDROID

Nome visual de marca/interface:

APEX BOOSTER+

Nome técnico Flutter:

apex_booster_plus

Package Android oficial:

com.allappsengineer.apex_booster_plus

Nome Android visível no launcher:

Apex Booster +

Status da identidade Android:

- Nome visível no launcher corrigido para Apex Booster +.
- Launcher icon real configurado.
- Splash nativa Android validada no Samsung S24 Ultra usando o launcher icon real.
- Ícone genérico Flutter removido da experiência inicial validada.

Não alterar nome Android, package ou launcher icon novamente sem aprovação explícita.

---

## 5. STACK TÉCNICO OFICIAL

Framework:

Flutter 3.x  
Dart 3.x

Plataforma inicial:

Android

Arquitetura alvo:

Clean Architecture

Camadas:

lib/core/  
lib/data/  
lib/domain/  
lib/presentation/

Estado:

flutter_bloc / Cubit

Navegação:

go_router

Storage local:

shared_preferences e/ou Hive

DI:

get_it  
injectable em fase futura, se necessário

Animações:

flutter_animate  
CustomPainter  
Rive/Lottie somente quando houver asset real aprovado

Billing futuro:

in_app_purchase

Localização futura:

flutter_localizations  
intl  
Arquivos ARB em lib/l10n/

Testes:

flutter_test  
integration_test em fase posterior

---

## 6. DEPENDÊNCIAS — REGRA DURA

Não adicionar dependências sem aprovação explícita.

Dependências já aceitas na base atual:

- go_router
- flutter_animate

Dependências planejadas, mas NÃO liberadas automaticamente:

- flutter_bloc
- get_it
- hive_flutter
- shared_preferences
- intl
- flutter_localizations
- in_app_purchase
- path_provider
- share_plus
- package_info_plus
- connectivity_plus
- battery_plus
- device_info_plus
- http

Antes de adicionar qualquer dependência:

1. Explicar por que ela é necessária.
2. Mostrar onde será usada.
3. Confirmar que não existe alternativa simples.
4. Aguardar aprovação.

---

## 7. REGRAS INVIOLÁVEIS DO PRODUTO

1. O app NUNCA deve afirmar que altera FPS real de jogos.
2. O app NUNCA deve afirmar que altera CPU, GPU ou resolução interna de jogos de terceiros.
3. O app NUNCA deve prometer redução garantida de lag, ping ou travamento.
4. O app NUNCA deve afirmar que mata processos de outros apps ou otimiza RAM de forma real.
5. GFX Profile é preferência local, não alteração real de jogo.
6. Apex Scan é diagnóstico e orientação, não milagre técnico.
7. Boost Apex é preparação visual e semântica, não otimização falsa.
8. Sem SDK de anúncios.
9. Sem assinatura.
10. Sem plano Pro.
11. Sem tracking no MVP.
12. Sem Firebase nesta fase.
13. Sem Billing nesta fase.
14. Sem Home até a Fase 2.
15. Sem Apex Scan até a Fase 2.
16. Sem Biblioteca de Jogos até a Fase 2.
17. Sem Boost Engine até a Fase 3.
18. Sem alteração de ícone Android sem aprovação explícita.
19. Sem alteração de nome Android sem aprovação explícita.
20. Não alterar fluxo sem aprovação.

---

## 8. REGRA DE VERDADE DE COPY

O APEX BOOSTER+ pode afirmar:

- prepara a sessão;
- organiza jogos;
- salva preferências locais;
- roda diagnóstico;
- orienta o usuário;
- cria experiência gamer visual;
- abre o jogo após preparação;
- melhora controle e clareza antes da partida.

O APEX BOOSTER+ não pode afirmar:

- aumenta FPS real;
- altera GPU;
- altera CPU;
- muda resolução interna de jogos;
- reduz ping garantidamente;
- remove lag garantidamente;
- acelera jogo de forma real e comprovada;
- fecha apps terceiros automaticamente;
- desbloqueia performance oculta do Android.

---

## 9. DESIGN — DIREÇÃO OFICIAL

O visual deve ser:

- dark premium;
- gamer moderno;
- jovem;
- limpo;
- profundo;
- tecnológico;
- com neon controlado;
- com microinterações;
- com sensação de produto real.

O visual NÃO pode ser:

- fundo preto chapado;
- tela estática;
- corporativo;
- infantil;
- genérico;
- poluído;
- carnavalesco;
- só texto verde em fundo preto;
- só Container com borda neon;
- protótipo com glow aplicado por cima.

Paleta oficial base:

Background profundo:
#050505 / #080808

Verde Apex:
#22C55E

Azul Cyber:
#3B82F6

Laranja energia/alerta:
#F97316

Texto principal:
#FFFFFF

Texto secundário:
#A1A1AA

Cards:
grafite escuro com contraste real, não preto puro.

---

## 10. CRITÉRIOS VISUAIS OBRIGATÓRIOS

Uma tela só é aprovada se:

1. Não parecer fundo preto chapado.
2. Tiver profundidade visual perceptível.
3. Tiver hierarquia clara.
4. Tiver contraste bom.
5. Tiver CTA forte.
6. Tiver microinteração.
7. Não tiver overflow.
8. Não parecer protótipo.
9. Não parecer app genérico.
10. Não parecer app corporativo.
11. Respeitar o fluxo do PDF.
12. Funcionar no celular físico.

`flutter analyze` e `flutter test` passando NÃO significam aprovação visual.

Aprovação visual depende de teste no aparelho físico e validação humana.

---

## 11. APEX MOTION SYSTEM — BASE

O Apex Motion System é o sistema central de identidade visual animada do app.

Elementos planejados:

- ApexCoreWidget
- EnergyRingProgress
- ParticleField
- GlowContainer
- GlitchText leve
- SpeedLines
- CompletionFlash
- ApexCheckIcon
- BoostStepRow
- ScanGauge

Na Fase 1, criar apenas a base visual necessária para onboarding.

Na Fase 1, não implementar todo o sistema final.

Para Fase 1, os componentes visuais permitidos são:

- background premium;
- cards premium;
- badges premium;
- CTA premium;
- partículas discretas;
- animações leves;
- transições suaves.

Não exagerar.  
Neon controlado.  
Premium acima de chamativo.

---

## 12. TELAS DO PRODUTO

Telas planejadas:

1. Splash
2. Welcome
3. How It Works
4. Permissions
5. Unlock / Purchase
6. Home
7. Game Library
8. Add Game
9. Game Detail
10. GFX Profile
11. Apex Scan
12. Boost Apex
13. Prep Result
14. History
15. Settings
16. About

Telas já existentes na base atual:

- SplashScreen
- WelcomeScreen
- HowItWorksScreen
- PermissionsScreen
- HomeScreen (com Bottom Navigation — 5 abas)
  - Aba Início (placeholder refinado visualmente)
  - Aba Biblioteca (placeholder refinado visualmente)
  - Aba Preparar (placeholder refinado visualmente)
  - Aba Histórico (placeholder refinado visualmente)
  - Aba Configurações (placeholder refinado visualmente)

A existência dessas telas não significa aprovação visual final.

As abas da Home são placeholders visuais honestos.
Nenhuma funcionalidade real foi implementada nelas ainda.

---

## 13. FASES OFICIAIS

### Fase 1 — Fundação e Onboarding

Objetivo:

Criar base visual, tema, roteamento, Splash, Welcome, HowItWorks e Permissions.

Inclui:

- estrutura inicial do projeto;
- AppTheme;
- cores;
- rotas;
- Splash;
- Welcome;
- HowItWorks;
- Permissions;
- base visual do Apex Motion System;
- testes básicos;
- validação visual no celular.

Não inclui:

- Home;
- Billing;
- Firebase;
- Apex Scan real;
- Biblioteca real de jogos;
- Boost Engine;
- GFX Profile funcional;
- publicação.

### Fase 2 — Core Features

Só começa após Fase 1 aprovada visualmente.

Inclui:

- Home;
- Bottom Navigation;
- Biblioteca;
- Add Game;
- Game Detail;
- GFX Profile;
- Apex Scan inicial.

### Fase 3 — Boost Engine

Inclui:

- SimulatedBoostEngine;
- BoostApexScreen;
- PrepResultScreen;
- M5/M6/M7;
- sons e vibração;
- histórico.

### Fase 4 — Polimento e Entrega

Inclui:

- Settings;
- About;
- localização completa;
- Billing;
- build release;
- Play Store Internal Track.

---

## 14. ESTADO ATUAL REAL DO DESENVOLVIMENTO

Projeto Flutter criado.

Package definido:

com.allappsengineer.apex_booster_plus

Git iniciado.

Fluxo básico atual:

Splash → Welcome → HowItWorks → Permissions → Home.

Telas existentes:

- SplashScreen
- WelcomeScreen
- HowItWorksScreen
- PermissionsScreen
- HomeScreen (com Bottom Navigation — 5 abas)

Componentes visuais já criados na Fase 1:

- ApexBackground
- ApexBadge
- ApexFeatureCard

Concluído:

- Projeto Flutter base criado.
- CLAUDE.md reforçado como contrato técnico, visual e estratégico do projeto.
- Fundação inicial criada com tema, cores, rotas e SplashScreen.
- WelcomeScreen criada.
- HowItWorksScreen criada.
- PermissionsScreen criada.
- Fase 1.5A concluída: SplashScreen e WelcomeScreen refinadas visualmente.
- Fase 1.5B concluída: HowItWorksScreen e PermissionsScreen refinadas visualmente.
- Fase 1.5C concluída: navegação do botão Voltar nativo Android corrigida no onboarding.
- Fase 1.6A concluída: nome visível do app Android corrigido para Apex Booster +.
- Fase 1.6C concluída: launcher icon real configurado.
- Splash nativa Android validada no Samsung S24 Ultra usando o launcher icon real.
- Ícone genérico Flutter removido da experiência inicial validada.
- Fluxo básico testado no celular físico Samsung S24 Ultra.
- Botão Voltar nativo Android validado:
  - Permissions → HowItWorks
  - HowItWorks → Welcome
  - Welcome → pode sair do app
- Fase 2A.1 concluída: Home mínima criada com estrutura base e placeholders das tabs.
- Fase 2A.4 concluída: Permissions → Home conectadas usando context.go('/home').
  - Home virou a nova raiz do stack de navegação.
  - Retorno ao onboarding a partir da Home está corretamente bloqueado.
- Fase 2A.5 concluída: comportamento do botão Voltar nativo Android corrigido na HomeScreen.
  - Qualquer aba diferente de Início volta para a aba Início sem sair do app.
  - Na aba Início, exibe SnackBar "Pressione voltar novamente para sair." na primeira pressão.
  - Segunda pressão em até 2 segundos sai do app via SystemNavigator.pop().
  - Nunca retorna ao onboarding.
  - Sem seta visual de voltar no topo da tela.
- Fase 2B concluída: refinamento visual inicial das 5 abas da Home.
  - Aba Início refinada como dashboard inicial gamer premium.
  - Aba Biblioteca refinada como estrutura visual inicial de lista de jogos.
  - Aba Preparar refinada como estrutura visual inicial da preparação de sessão.
  - Aba Histórico refinada como estrutura visual inicial de histórico de sessões.
  - Aba Configurações refinada como estrutura visual inicial de configurações do app.
- flutter analyze passando.
- flutter test passando.

Observação sobre a Fase 1.6B:

- A tentativa de esconder o ícone genérico Flutter apenas por ajuste de splash nativa Android foi descartada/revertida porque não resolveu o problema principal.
- A solução validada foi a Fase 1.6C: configurar o launcher icon real.

Estado visual atual:

Aprovado como checkpoint da Fase 2B: Home com 5 abas refinadas visualmente.
Ainda não é o visual final absoluto do produto.

Observação:

A base visual atual é aceitável para encerrar o checkpoint da Fase 2B e avançar para funcionalidades reais. Melhorias visuais finas ainda podem ocorrer, mas não devem bloquear o avanço.

Pendências conhecidas:

- Logo/asset oficial interno ainda não foi aprovado para uso definitivo nas telas Flutter.
- Localização multilíngue ainda não foi implementada.
- Biblioteca real não implementada (Add Game, Game Detail, banco local).
- GFX Profile funcional não implementado.
- Apex Scan real não implementado (sem leitura de métricas do dispositivo).
- Boost Engine não implementado.
- Estrutura local de dados não implementada (Hive / shared_preferences).
- Billing não implementado.
- Firebase não implementado.

---

## 15. PRÓXIMO PASSO OFICIAL

Fase 2A e Fase 2B concluídas.

Próxima decisão obrigatória:

Antes de iniciar qualquer implementação nova, decidir entre:

1. Iniciar funcionalidade real da Biblioteca:
   - Add Game (formulário básico de cadastro de jogo);
   - Game Detail (tela de detalhe do jogo);
   - banco local simples para persistência.

2. Iniciar estrutura local de dados:
   - shared_preferences ou Hive;
   - definir modelo de dados base (jogo, sessão, perfil GFX);
   - preparar repositório local antes das features.

3. Iniciar preparação de sessão:
   - GFX Profile com preferências locais;
   - estrutura do Boost Apex (visual e semântica, sem otimização falsa).

4. Fazer micro-refino visual pontual:
   - somente se houver problema visual objetivo identificado no celular;
   - sem reabrir toda a estrutura visual;
   - sem alterar escopo funcional.

Regra:

Nenhuma implementação nova deve começar sem escolher explicitamente uma dessas opções.

---

## 16. PROIBIÇÕES TEMPORÁRIAS

Na Fase 2, até aprovação individual de cada item, é proibido:

- implementar Apex Scan real (leitura de métricas do dispositivo);
- implementar GFX Profile funcional (persistência e aplicação de preferências);
- implementar Boost Engine;
- implementar Billing;
- implementar Firebase;
- implementar banco local (Hive / shared_preferences) sem aprovação da estrutura de dados;
- adicionar logo asset sem aprovação;
- criar dependências novas sem aprovação explícita;
- commitar visual não aprovado;
- alterar nome Android sem aprovação explícita;
- alterar launcher icon sem aprovação explícita;
- avançar para Fase 3 sem Fase 2 funcional aprovada.

---

## 17. FLUXO DE TRABALHO OBRIGATÓRIO COM CLAUDE CODE

Para qualquer sessão:

1. Ler CLAUDE.md.
2. Confirmar produto, regras e estado atual.
3. Apresentar plano curto.
4. Aguardar aprovação.
5. Executar apenas o escopo aprovado.
6. Rodar flutter analyze.
7. Rodar flutter test.
8. Relatar arquivos criados e alterados.
9. Testar visualmente no celular físico.
10. Só commitar após aprovação humana.

Nunca fazer commit automaticamente.

Nunca usar "commit this" sem autorização explícita.

---

## 18. PADRÃO DE COMMITS

Commits devem ser pequenos e atômicos.

Exemplos:

feat: criar tela de permissoes

feat: refinar onboarding visual da fase 1

docs: atualizar estado do projeto

fix: corrigir overflow em permissions

Não misturar:

- visual + ícone Android;
- visual + Billing;
- copy + Firebase;
- assets + Home;
- refatoração + feature.

---

## 19. TESTES OBRIGATÓRIOS

Após cada bloco funcional:

flutter analyze

flutter test

Em seguida, teste visual no celular:

flutter run -d RXCX704PG2H

O celular físico é fonte de verdade para validação visual.

---

## 20. STRINGS E LOCALIZAÇÃO

O app terá suporte futuro a:

- Português Brasil
- English
- Español

Regra:

Não espalhar strings hardcoded de forma descontrolada.

`flutter analyze` não garante ausência de strings hardcoded.

Em fase futura, criar script próprio para varrer strings em lib/.

Por enquanto:

- evitar textos soltos;
- manter copy simples;
- preparar mentalmente estrutura para l10n;
- não implementar l10n antes da fase correta.

---

## 21. FIREBASE

Firebase não será configurado na Fase 1.

Motivos:

- pode quebrar CI se google-services.json e firebase_options.dart forem ignorados;
- exige estratégia de secrets;
- app promete sem tracking;
- Crashlytics pode ser avaliado depois.

Quando Firebase for necessário:

- documentar estratégia;
- configurar CI;
- proteger arquivos sensíveis;
- não ativar Analytics no MVP.

---

## 22. BILLING

Billing não será implementado na Fase 1.

Modelo futuro:

Free install + one-time unlock.

Plugin futuro:

in_app_purchase

Antes de implementar Billing:

- configurar Play Console;
- configurar license testers;
- definir product id;
- definir fluxo de unlock;
- testar restore purchase.

---

## 23. PERMISSÕES E DND

O app não deve forçar Do Not Disturb.

Pode:

- explicar permissões;
- orientar usuário;
- abrir configurações do Android quando aplicável;
- solicitar notificações com clareza em fase futura.

Não pode:

- prometer ativação automática de foco;
- forçar configuração sensível;
- criar comportamento invasivo.

---

## 24. GFX PROFILE

Perfis planejados:

- Fluidez
- Equilibrado
- Competitivo
- Ultra Visual
- Personalizado

Disclaimer obrigatório em toda tela GFX:

Preferências salvas localmente. Não altera jogos de terceiros.

Não usar label "2K" nos sliders.

Não afirmar alteração real de FPS, resolução ou qualidade interna do jogo.

---

## 25. APEX SCAN

Métricas planejadas:

- Network Pulse
- Power Core
- Thermal Zone
- Focus Shield
- Apex Score

Fórmula planejada:

networkScore * 0.35  
batteryScore * 0.25  
thermalScore * 0.25  
focusScore * 0.15

Não implementar Apex Scan na Fase 1.

O pacote http ainda não está aprovado.

Antes de adicionar http:

- avaliar connectivity_plus;
- avaliar dart:io;
- justificar necessidade.

---

## 26. BOOST APEX

Boost Apex será uma sequência visual e semântica de preparação.

Etapas planejadas:

1. Núcleo Apex Online
2. Jogo travado no alvo
3. Pulso de rede analisado
4. Energia sincronizada
5. Temperatura verificada
6. Foco de sessão pronto
7. Perfil GFX carregado
8. Sequência de jogo armada

Cada etapa deve ter significado real ou informativo.

Não simular falsa otimização técnica.

Não implementar Boost Apex na Fase 1.

---

## 27. CRITÉRIO DE REJEIÇÃO AUTOMÁTICA

Rejeitar qualquer implementação que:

- pareça fundo preto com texto verde;
- use glow exagerado para esconder layout fraco;
- deixe cards sem hierarquia;
- quebre navegação;
- gere overflow;
- altere escopo sem permissão;
- adicione dependência sem aprovação;
- prometa melhoria técnica falsa;
- mexa em Firebase/Billing antes da hora;
- faça commit sem aprovação.

---

## 28. COMANDOS IMPORTANTES

Analisar:

flutter analyze

Testar:

flutter test

Rodar no celular:

flutter run -d RXCX704PG2H

Ver Git:

git status

Adicionar arquivos:

git add .

Commit:

git commit -m "mensagem"

Sair do Claude Code:

/exit

---

## 29. REGRA FINAL

Qualidade acima de velocidade.

Não estamos apenas fazendo telas funcionarem.

Estamos construindo um produto Android gamer premium, honesto, vendável, tecnicamente limpo e visualmente forte.

Se uma implementação passar nos testes, mas parecer ruim no celular, ela está reprovada.
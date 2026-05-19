\# CLAUDE.md — APEX BOOSTER+



LEIA ESTE ARQUIVO COMPLETAMENTE ANTES DE QUALQUER AÇÃO.



Este arquivo é o contrato técnico, visual e estratégico do projeto.  

Se houver conflito entre conversa, suposição e este arquivo, este arquivo vence.



\---



\## 1. PRODUTO



Estamos desenvolvendo o \*\*APEX BOOSTER+\*\*.



Tipo de produto:



App Android em Flutter para preparação gamer, diagnóstico visual, perfis locais e launcher de jogos.



Objetivo do produto:



Ajudar o usuário gamer a preparar sua sessão antes de jogar, com visual premium, leitura do ambiente, organização de jogos, perfis GFX locais, Apex Scan e abertura do jogo.



O app não vende milagre técnico.  

O app vende preparação, leitura, organização, foco, estilo e controle.



\---



\## 2. POSICIONAMENTO



Posicionamento técnico/mercado:



Gaming Prep, Scan \& Launcher.



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



\---



\## 3. MODELO COMERCIAL OFICIAL



Decisão oficial atual do projeto:



Free install + one-time unlock.



Preço planejado:



Brasil:

R$2,99



Internacional:

US$2,99



Regras comerciais:



\- Sem anúncios.

\- Sem assinatura.

\- Sem plano Pro.

\- Sem plano Elite.

\- Sem paywall recorrente.

\- Sem SDK de ads.

\- Desbloqueio único via Google Play Billing em fase futura.

\- No MVP inicial, pode existir unlock local temporário apenas para desenvolvimento.



Não implementar Billing agora.  

Não implementar Firebase agora.  

Não implementar Analytics agora.



\---



\## 4. PACKAGE E IDENTIDADE ANDROID



Nome visual do app:



APEX BOOSTER+



Nome técnico Flutter:



apex\_booster\_plus



Package Android oficial:



com.allappsengineer.apex\_booster\_plus



O nome Android visível no launcher deverá ser corrigido em etapa própria para:



APEX BOOSTER+



O ícone Android deverá ser corrigido em etapa própria.  

Não alterar ícone Android dentro de sessões de tela/onboarding.



\---



\## 5. STACK TÉCNICO OFICIAL



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



flutter\_bloc / Cubit



Navegação:



go\_router



Storage local:



shared\_preferences e/ou Hive



DI:



get\_it  

injectable em fase futura, se necessário



Animações:



flutter\_animate  

CustomPainter  

Rive/Lottie somente quando houver asset real aprovado



Billing futuro:



in\_app\_purchase



Localização futura:



flutter\_localizations  

intl  

Arquivos ARB em lib/l10n/



Testes:



flutter\_test  

integration\_test em fase posterior



\---



\## 6. DEPENDÊNCIAS — REGRA DURA



Não adicionar dependências sem aprovação explícita.



Dependências já aceitas na base atual:



\- go\_router

\- flutter\_animate



Dependências planejadas, mas NÃO liberadas automaticamente:



\- flutter\_bloc

\- get\_it

\- hive\_flutter

\- shared\_preferences

\- intl

\- flutter\_localizations

\- in\_app\_purchase

\- path\_provider

\- share\_plus

\- package\_info\_plus

\- connectivity\_plus

\- battery\_plus

\- device\_info\_plus

\- http



Antes de adicionar qualquer dependência:



1\. Explicar por que ela é necessária.

2\. Mostrar onde será usada.

3\. Confirmar que não existe alternativa simples.

4\. Aguardar aprovação.



\---



\## 7. REGRAS INVIOLÁVEIS DO PRODUTO



1\. O app NUNCA deve afirmar que altera FPS real de jogos.

2\. O app NUNCA deve afirmar que altera CPU, GPU ou resolução interna de jogos de terceiros.

3\. O app NUNCA deve prometer redução garantida de lag, ping ou travamento.

4\. O app NUNCA deve afirmar que mata processos de outros apps ou otimiza RAM de forma real.

5\. GFX Profile é preferência local, não alteração real de jogo.

6\. Apex Scan é diagnóstico e orientação, não milagre técnico.

7\. Boost Apex é preparação visual e semântica, não otimização falsa.

8\. Sem SDK de anúncios.

9\. Sem assinatura.

10\. Sem plano Pro.

11\. Sem tracking no MVP.

12\. Sem Firebase nesta fase.

13\. Sem Billing nesta fase.

14\. Sem Home até a Fase 2.

15\. Sem Apex Scan até a Fase 2.

16\. Sem Biblioteca de Jogos até a Fase 2.

17\. Sem Boost Engine até a Fase 3.

18\. Sem ícone Android dentro de sessão visual de tela.

19\. Sem nome Android dentro de sessão visual de tela.

20\. Não alterar fluxo sem aprovação.



\---



\## 8. REGRA DE VERDADE DE COPY



O APEX BOOSTER+ pode afirmar:



\- prepara a sessão;

\- organiza jogos;

\- salva preferências locais;

\- roda diagnóstico;

\- orienta o usuário;

\- cria experiência gamer visual;

\- abre o jogo após preparação;

\- melhora controle e clareza antes da partida.



O APEX BOOSTER+ não pode afirmar:



\- aumenta FPS real;

\- altera GPU;

\- altera CPU;

\- muda resolução interna de jogos;

\- reduz ping garantidamente;

\- remove lag garantidamente;

\- acelera jogo de forma real e comprovada;

\- fecha apps terceiros automaticamente;

\- desbloqueia performance oculta do Android.



\---



\## 9. DESIGN — DIREÇÃO OFICIAL



O visual deve ser:



\- dark premium;

\- gamer moderno;

\- jovem;

\- limpo;

\- profundo;

\- tecnológico;

\- com neon controlado;

\- com microinterações;

\- com sensação de produto real.



O visual NÃO pode ser:



\- fundo preto chapado;

\- tela estática;

\- corporativo;

\- infantil;

\- genérico;

\- poluído;

\- carnavalesco;

\- só texto verde em fundo preto;

\- só Container com borda neon;

\- protótipo com glow aplicado por cima.



Paleta oficial base:



Background profundo:

\#050505 / #080808



Verde Apex:

\#22C55E



Azul Cyber:

\#3B82F6



Laranja energia/alerta:

\#F97316



Texto principal:

\#FFFFFF



Texto secundário:

\#A1A1AA



Cards:

grafite escuro com contraste real, não preto puro.



\---



\## 10. CRITÉRIOS VISUAIS OBRIGATÓRIOS



Uma tela só é aprovada se:



1\. Não parecer fundo preto chapado.

2\. Tiver profundidade visual perceptível.

3\. Tiver hierarquia clara.

4\. Tiver contraste bom.

5\. Tiver CTA forte.

6\. Tiver microinteração.

7\. Não tiver overflow.

8\. Não parecer protótipo.

9\. Não parecer app genérico.

10\. Não parecer app corporativo.

11\. Respeitar o fluxo do PDF.

12\. Funcionar no celular físico.



`flutter analyze` e `flutter test` passando NÃO significam aprovação visual.



Aprovação visual depende de teste no aparelho físico e validação humana.



\---



\## 11. APEX MOTION SYSTEM — BASE



O Apex Motion System é o sistema central de identidade visual animada do app.



Elementos planejados:



\- ApexCoreWidget

\- EnergyRingProgress

\- ParticleField

\- GlowContainer

\- GlitchText leve

\- SpeedLines

\- CompletionFlash

\- ApexCheckIcon

\- BoostStepRow

\- ScanGauge



Na Fase 1, criar apenas a base visual necessária para onboarding.



Na Fase 1, não implementar todo o sistema final.



Para Fase 1, os componentes visuais permitidos são:



\- background premium;

\- cards premium;

\- badges premium;

\- CTA premium;

\- partículas discretas;

\- animações leves;

\- transições suaves.



Não exagerar.  

Neon controlado.  

Premium acima de chamativo.



\---



\## 12. TELAS DO PRODUTO



Telas planejadas:



1\. Splash

2\. Welcome

3\. How It Works

4\. Permissions

5\. Unlock / Purchase

6\. Home

7\. Game Library

8\. Add Game

9\. Game Detail

10\. GFX Profile

11\. Apex Scan

12\. Boost Apex

13\. Prep Result

14\. History

15\. Settings

16\. About



Telas já existentes na base atual:



\- SplashScreen

\- WelcomeScreen

\- HowItWorksScreen

\- PermissionsScreen



A existência dessas telas não significa aprovação visual final.



\---



\## 13. FASES OFICIAIS



\### Fase 1 — Fundação e Onboarding



Objetivo:



Criar base visual, tema, roteamento, Splash, Welcome, HowItWorks e Permissions.



Inclui:



\- estrutura inicial do projeto;

\- AppTheme;

\- cores;

\- rotas;

\- Splash;

\- Welcome;

\- HowItWorks;

\- Permissions;

\- base visual do Apex Motion System;

\- testes básicos;

\- validação visual no celular.



Não inclui:



\- Home;

\- Billing;

\- Firebase;

\- Apex Scan real;

\- Biblioteca real de jogos;

\- Boost Engine;

\- GFX Profile funcional;

\- ícone Android;

\- publicação.



\### Fase 2 — Core Features



Só começa após Fase 1 aprovada visualmente.



Inclui:



\- Home;

\- Bottom Navigation;

\- Biblioteca;

\- Add Game;

\- Game Detail;

\- GFX Profile;

\- Apex Scan inicial.



\### Fase 3 — Boost Engine



Inclui:



\- SimulatedBoostEngine;

\- BoostApexScreen;

\- PrepResultScreen;

\- M5/M6/M7;

\- sons e vibração;

\- histórico.



\### Fase 4 — Polimento e Entrega



Inclui:



\- Settings;

\- About;

\- localização completa;

\- Billing;

\- build release;

\- Play Store Internal Track.



\---



\## 14. ESTADO ATUAL REAL DO DESENVOLVIMENTO



Projeto Flutter criado.



Package definido:



com.allappsengineer.apex\_booster\_plus



Git iniciado.



Fluxo básico atual:



Splash → Welcome → HowItWorks → Permissions.



Telas existentes:



\- SplashScreen

\- WelcomeScreen

\- HowItWorksScreen

\- PermissionsScreen



Componentes visuais já criados na Fase 1:



\- ApexBackground

\- ApexBadge

\- ApexFeatureCard



Concluído:



\- Projeto Flutter base criado.

\- CLAUDE.md reforçado como contrato técnico, visual e estratégico do projeto.

\- Fundação inicial criada com tema, cores, rotas e SplashScreen.

\- WelcomeScreen criada.

\- HowItWorksScreen criada.

\- PermissionsScreen criada.

\- Fase 1.5A concluída: SplashScreen e WelcomeScreen refinadas visualmente.

\- Fase 1.5B concluída: HowItWorksScreen e PermissionsScreen refinadas visualmente.

\- Fase 1.5C concluída: navegação do botão Voltar nativo Android corrigida no onboarding.

\- Fluxo básico testado no celular físico Samsung S24 Ultra.

\- Botão Voltar nativo Android validado:

&#x20; - Permissions → HowItWorks

&#x20; - HowItWorks → Welcome

&#x20; - Welcome → pode sair do app

\- flutter analyze passando.

\- flutter test passando.



Estado visual atual:



Aprovado como checkpoint da Fase 1, ainda não como visual final absoluto do produto.



Observação:



A base visual atual é aceitável para encerrar o checkpoint do onboarding e seguir o plano com controle. Melhorias visuais finas ainda podem ocorrer futuramente, mas não devem bloquear indefinidamente o avanço do projeto.



Pendências conhecidas:



\- Splash nativa Android ainda mostra ícone genérico Flutter.

\- Nome do app no launcher ainda precisa ser corrigido para APEX BOOSTER+.

\- Ícone Android precisa ser configurado em etapa própria.

\- Logo/asset oficial ainda não foi aprovado para uso definitivo.

\- Localização multilíngue ainda não foi implementada.

\- Home ainda não foi implementada.

\- Features reais ainda não começaram.



\---



\## 15. PRÓXIMO PASSO OFICIAL



Próxima decisão obrigatória:



Antes de iniciar qualquer implementação nova, decidir entre:



1\. Fazer etapa isolada de identidade Android:

&#x20;  - corrigir nome visível do app para APEX BOOSTER+;

&#x20;  - configurar launcher icon;

&#x20;  - ajustar splash nativa Android.



2\. Avançar para a Fase 2 — Core Features:

&#x20;  - Home;

&#x20;  - Bottom Navigation;

&#x20;  - Biblioteca;

&#x20;  - Add Game;

&#x20;  - Game Detail;

&#x20;  - GFX Profile;

&#x20;  - Apex Scan inicial.



3\. Fazer micro-refino visual pontual da Fase 1:

&#x20;  - somente se houver problema visual objetivo;

&#x20;  - sem reabrir toda a estrutura visual;

&#x20;  - sem alterar escopo funcional.



Regra:



Nenhuma implementação nova deve começar sem escolher explicitamente uma dessas opções.



\---



\## 16. PROIBIÇÕES TEMPORÁRIAS



Até a Fase 1 ser aprovada visualmente, é proibido:



\- implementar Home;

\- implementar Bottom Navigation;

\- implementar Apex Scan;

\- implementar Biblioteca;

\- implementar GFX;

\- implementar Boost Engine;

\- implementar Billing;

\- implementar Firebase;

\- implementar ícone Android;

\- alterar nome Android;

\- adicionar logo asset sem aprovação;

\- criar dependências novas;

\- commitar visual não aprovado.



\---



\## 17. FLUXO DE TRABALHO OBRIGATÓRIO COM CLAUDE CODE



Para qualquer sessão:



1\. Ler CLAUDE.md.

2\. Confirmar produto, regras e estado atual.

3\. Apresentar plano curto.

4\. Aguardar aprovação.

5\. Executar apenas o escopo aprovado.

6\. Rodar flutter analyze.

7\. Rodar flutter test.

8\. Relatar arquivos criados e alterados.

9\. Testar visualmente no celular físico.

10\. Só commitar após aprovação humana.



Nunca fazer commit automaticamente.



Nunca usar "commit this" sem autorização explícita.



\---



\## 18. PADRÃO DE COMMITS



Commits devem ser pequenos e atômicos.



Exemplos:



feat: criar tela de permissoes



feat: refinar onboarding visual da fase 1



docs: atualizar estado do projeto



fix: corrigir overflow em permissions



Não misturar:



\- visual + ícone Android;

\- visual + Billing;

\- copy + Firebase;

\- assets + Home;

\- refatoração + feature.



\---



\## 19. TESTES OBRIGATÓRIOS



Após cada bloco funcional:



flutter analyze



flutter test



Em seguida, teste visual no celular:



flutter run -d RXCX704PG2H



O celular físico é fonte de verdade para validação visual.



\---



\## 20. STRINGS E LOCALIZAÇÃO



O app terá suporte futuro a:



\- Português Brasil

\- English

\- Español



Regra:



Não espalhar strings hardcoded de forma descontrolada.



`flutter analyze` não garante ausência de strings hardcoded.



Em fase futura, criar script próprio para varrer strings em lib/.



Por enquanto:



\- evitar textos soltos;

\- manter copy simples;

\- preparar mentalmente estrutura para l10n;

\- não implementar l10n antes da fase correta.



\---



\## 21. FIREBASE



Firebase não será configurado na Fase 1.



Motivos:



\- pode quebrar CI se google-services.json e firebase\_options.dart forem ignorados;

\- exige estratégia de secrets;

\- app promete sem tracking;

\- Crashlytics pode ser avaliado depois.



Quando Firebase for necessário:



\- documentar estratégia;

\- configurar CI;

\- proteger arquivos sensíveis;

\- não ativar Analytics no MVP.



\---



\## 22. BILLING



Billing não será implementado na Fase 1.



Modelo futuro:



Free install + one-time unlock.



Plugin futuro:



in\_app\_purchase



Antes de implementar Billing:



\- configurar Play Console;

\- configurar license testers;

\- definir product id;

\- definir fluxo de unlock;

\- testar restore purchase.



\---



\## 23. PERMISSÕES E DND



O app não deve forçar Do Not Disturb.



Pode:



\- explicar permissões;

\- orientar usuário;

\- abrir configurações do Android quando aplicável;

\- solicitar notificações com clareza em fase futura.



Não pode:



\- prometer ativação automática de foco;

\- forçar configuração sensível;

\- criar comportamento invasivo.



\---



\## 24. GFX PROFILE



Perfis planejados:



\- Fluidez

\- Equilibrado

\- Competitivo

\- Ultra Visual

\- Personalizado



Disclaimer obrigatório em toda tela GFX:



Preferências salvas localmente. Não altera jogos de terceiros.



Não usar label "2K" nos sliders.



Não afirmar alteração real de FPS, resolução ou qualidade interna do jogo.



\---



\## 25. APEX SCAN



Métricas planejadas:



\- Network Pulse

\- Power Core

\- Thermal Zone

\- Focus Shield

\- Apex Score



Fórmula planejada:



networkScore \* 0.35  

batteryScore \* 0.25  

thermalScore \* 0.25  

focusScore \* 0.15



Não implementar Apex Scan na Fase 1.



O pacote http ainda não está aprovado.



Antes de adicionar http:



\- avaliar connectivity\_plus;

\- avaliar dart:io;

\- justificar necessidade.



\---



\## 26. BOOST APEX



Boost Apex será uma sequência visual e semântica de preparação.



Etapas planejadas:



1\. Núcleo Apex Online

2\. Jogo travado no alvo

3\. Pulso de rede analisado

4\. Energia sincronizada

5\. Temperatura verificada

6\. Foco de sessão pronto

7\. Perfil GFX carregado

8\. Sequência de jogo armada



Cada etapa deve ter significado real ou informativo.



Não simular falsa otimização técnica.



Não implementar Boost Apex na Fase 1.



\---



\## 27. CRITÉRIO DE REJEIÇÃO AUTOMÁTICA



Rejeitar qualquer implementação que:



\- pareça fundo preto com texto verde;

\- use glow exagerado para esconder layout fraco;

\- deixe cards sem hierarquia;

\- quebre navegação;

\- gere overflow;

\- altere escopo sem permissão;

\- adicione dependência sem aprovação;

\- prometa melhoria técnica falsa;

\- mexa em Firebase/Billing antes da hora;

\- faça commit sem aprovação.



\---



\## 28. COMANDOS IMPORTANTES



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



\---



\## 29. REGRA FINAL



Qualidade acima de velocidade.



Não estamos apenas fazendo telas funcionarem.



Estamos construindo um produto Android gamer premium, honesto, vendável, tecnicamente limpo e visualmente forte.



Se uma implementação passar nos testes, mas parecer ruim no celular, ela está reprovada.


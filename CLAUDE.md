\# CLAUDE.md — Apex Booster+



LEIA ESTE ARQUIVO COMPLETAMENTE ANTES DE QUALQUER AÇÃO.



\## PRODUTO



Apex Booster+ é um app Android feito em Flutter.



Linguagem de mercado:



Gaming Prep, Scan \& Launcher.



O app ajuda o usuário gamer a preparar a sessão antes de jogar, com:



\- biblioteca de jogos;

\- perfis GFX locais;

\- Apex Scan;

\- preparação visual de sessão;

\- launcher para abrir o jogo;

\- histórico local;

\- configurações de idioma, motion e experiência.



\## MODELO COMERCIAL OFICIAL



Free install + one-time unlock.



Preço:



\- Brasil: R$2,99

\- Internacional: US$2,99



Regras comerciais:



\- sem anúncios;

\- sem assinatura;

\- sem plano Pro;

\- sem paywall recorrente;

\- sem SDK de ads;

\- desbloqueio único via Google Play Billing em fase futura.



No MVP inicial, o app pode funcionar com unlock local temporário apenas para desenvolvimento.



\## PACKAGE ANDROID



Package oficial:



com.allappsengineer.apex\_booster\_plus



Nome técnico do projeto Flutter:



apex\_booster\_plus



Nome visual do app:



Apex Booster+



\## STACK TÉCNICO



\- Flutter 3.x

\- Dart 3.x

\- Android primeiro

\- Clean Architecture

\- Presentation / Domain / Data

\- State management: flutter\_bloc / Cubit

\- Navegação: go\_router

\- DI: get\_it

\- Storage local: shared\_preferences e/ou Hive

\- Localização: flutter\_localizations + intl

\- Motion: flutter\_animate, CustomPainter e, futuramente, Rive/Lottie

\- Compra única futura: in\_app\_purchase

\- Compartilhamento futuro: share\_plus + path\_provider

\- Informações do app futuras: package\_info\_plus



\## REGRA DE VERDADE DO PRODUTO



O Apex Booster+ nunca deve afirmar que altera de forma real:



\- FPS do jogo;

\- CPU;

\- GPU;

\- resolução interna de jogos de terceiros;

\- memória RAM de outros apps;

\- performance real garantida;

\- ping garantido;

\- eliminação automática de lag.



O app pode afirmar que:



\- prepara a sessão;

\- organiza jogos;

\- salva preferências locais;

\- roda diagnóstico;

\- orienta o usuário;

\- cria uma experiência gamer visual;

\- abre o jogo após a preparação.



\## FRASE DE POSICIONAMENTO



Apex Booster+ não vende milagre técnico.



Apex Booster+ entrega preparação, leitura do ambiente, foco e experiência gamer premium antes da partida.



\## ARQUITETURA DE PASTAS DESEJADA



lib/

&#x20; core/

&#x20;   constants/

&#x20;   theme/

&#x20;   motion/

&#x20;   routing/

&#x20;   utils/

&#x20; data/

&#x20;   datasources/

&#x20;   models/

&#x20;   repositories/

&#x20; domain/

&#x20;   entities/

&#x20;   repositories/

&#x20;   usecases/

&#x20; presentation/

&#x20;   cubits/

&#x20;   screens/

&#x20;   widgets/

&#x20; l10n/



\## TELAS PLANEJADAS



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



\## REGRAS DE DESENVOLVIMENTO



1\. Antes de escrever código, apresente um plano curto.

2\. Execute apenas o que foi pedido.

3\. Não antecipe fases futuras.

4\. Não criar arquivos desnecessários.

5\. Não instalar dependências sem justificar.

6\. Não criar placeholders finais.

7\. Placeholders temporários são permitidos apenas se forem claramente marcados como temporários.

8\. Nenhum placeholder pode permanecer na versão final.

9\. Rodar flutter analyze após blocos funcionais, não após cada arquivo.

10\. Manter commits pequenos e claros.

11\. Não adicionar Firebase agora.

12\. Não adicionar Billing agora.

13\. Não adicionar SDK de anúncios nunca.

14\. Não adicionar tracking/analytics no MVP.



\## STRINGS E LOCALIZAÇÃO



O app terá suporte a:



\- Português Brasil

\- English

\- Español



Regra importante:



flutter analyze não garante ausência de strings hardcoded.



Em fase futura, criar script próprio para scan de strings hardcoded em lib/.



Enquanto isso:



\- evitar textos diretos espalhados;

\- centralizar textos quando possível;

\- preparar estrutura para internacionalização.



\## FIREBASE



Firebase não será configurado na primeira fase.



Motivo:



\- pode quebrar CI se google-services.json e firebase\_options.dart forem ignorados;

\- precisa estratégia própria com GitHub Secrets;

\- Crashlytics pode ser avaliado depois;

\- o app promete sem tracking.



Quando Firebase for necessário:



\- criar estratégia segura para google-services.json;

\- criar estratégia segura para firebase\_options.dart;

\- documentar CI/CD antes de ativar.



\## NOTIFICAÇÕES E DND



O app não deve forçar Do Not Disturb.



Pode:



\- verificar permissões quando possível;

\- orientar o usuário;

\- abrir tela de configuração do Android quando aplicável;

\- solicitar notificações com clareza.



Não pode:



\- prometer ativar foco automaticamente;

\- forçar configurações sensíveis;

\- criar comportamento invasivo.



\## APEX SCAN



Métricas planejadas:



\- Network Pulse

\- Power Core

\- Thermal Zone

\- Focus Shield

\- Apex Score



Apex Score planejado:



networkScore \* 0.35

batteryScore \* 0.25

thermalScore \* 0.25

focusScore \* 0.15



O pacote http ainda não está aprovado.



Antes de adicionar http, avaliar se connectivity\_plus + dart:io resolvem a necessidade inicial.



\## GFX PROFILE



Perfis locais:



\- Fluidez

\- Equilibrado

\- Competitivo

\- Ultra Visual

\- Personalizado



Regra obrigatória:



Sempre exibir disclaimer nas telas GFX:



"Preferências salvas localmente. Não altera jogos de terceiros."



\## BOOST APEX



O Boost Apex será uma preparação visual e semântica de sessão.



Etapas planejadas:



1\. Núcleo Apex Online

2\. Jogo travado no alvo

3\. Pulso de rede analisado

4\. Energia sincronizada

5\. Temperatura verificada

6\. Foco de sessão pronto

7\. Perfil GFX carregado

8\. Sequência de jogo armada



Cada etapa deve ter sentido real ou informativo.



Não simular falsa otimização técnica.



\## DESIGN



Direção visual:



\- gamer;

\- neon;

\- premium;

\- jovem;

\- rápido;

\- moderno;

\- sem aparência corporativa;

\- sem cara de app velho.



Paleta base:



\- Background: #080808

\- Verde Apex: #22C55E

\- Laranja energia: #F97316

\- Azul cyber: #3B82F6

\- Cinza texto: #A1A1AA

\- Branco: #FFFFFF



\## APEX MOTION SYSTEM



Toda tela importante deve ter alguma microinteração.



Nada de telas completamente estáticas.



Elementos planejados:



\- GlowContainer

\- EnergyRingProgress

\- ApexCoreWidget

\- ScanGauge

\- GlitchText leve

\- SpeedLines

\- CompletionFlash

\- feedback háptico



Intensidades futuras:



\- Suave

\- Gamer

\- Neon Max



\## ESTADO ATUAL DO DESENVOLVIMENTO



Fase atual:



Fundação inicial.



Concluído:



\- projeto Flutter criado;

\- package definido;

\- flutter analyze sem issues;

\- Git iniciado;

\- primeiro commit de segurança feito;

\- CLAUDE.md criado.



Próximo passo:



Abrir Claude Code dentro da pasta do projeto e iniciar a Sessão 1: estrutura base, tema, rotas e primeira tela.



\## COMANDOS IMPORTANTES



Rodar análise:



flutter analyze



Rodar app:



flutter run



Ver status Git:



git status



Commit padrão:



git add .

git commit -m "mensagem"



\## REGRA FINAL



Qualidade acima de velocidade.



O objetivo não é apenas fazer o app rodar.



O objetivo é construir um produto simples, honesto, bonito, vendável e tecnicamente limpo.


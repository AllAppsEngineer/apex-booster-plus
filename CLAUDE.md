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
- shared_preferences (aprovado apenas para persistência simples da Biblioteca nesta fase)

Dependências planejadas, mas NÃO liberadas automaticamente:

- flutter_bloc
- get_it
- hive_flutter
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
- GameDetailScreen

A existência dessas telas não significa aprovação visual final.

Estado funcional das abas da Home:

- Aba Início: placeholder visual refinado. Sem funcionalidade real.
- Aba Biblioteca: funcionalidade real implementada (lista de jogos, adicionar por nome via BottomSheet com autocomplete inteligente desde a primeira letra, sugestões por ranking de relevância, lista rolável sem limite artificial, seleção de sugestão preenche nome + packageName, packageName manual validado contra apps instalados, jogos fantasmas bloqueados, duplicados bloqueados com mensagem "Já instalado", favoritar/desfavoritar, remover, persistência local com shared_preferences, navegação para detalhe ao tocar em um jogo, edição de nome e packageName via diálogo inline no detalhe com validação: packageName inválido bloqueado, packageName duplicado em outro jogo bloqueado, packageName vazio permitido com fallback de ícone, packageName igual ao jogo atual permitido, edição apenas do nome preservada sem validação desnecessária, seleção de GFX Profile local via bottom sheet no detalhe, seleção restrita de apps Android instalados via AppPickerSheet com intent MAIN/LAUNCHER — entrada manual permanece como fallback, exibição de ícone real do app instalado via AppIconWidget quando packageName disponível — fallback genérico quando ausente, app desinstalado ou erro, microcopy final ajustado: contagem exibe "na biblioteca", empty state honesto "Nenhum jogo adicionado ainda.", subtítulo orienta ação real, copy do card Perfis locais reflete que GFX Profile já existe no detalhe de cada jogo, launcher real implementado na GameDetailScreen via botão ABRIR JOGO com Apex Boost Mode visual antes da abertura).
- Aba Preparar: placeholder visual. Sem funcionalidade real.
- Aba Histórico: placeholder visual. Sem funcionalidade real.
- Aba Configurações: card "Modo Foco Gamer" implementado (Fase 2-P.4) com UI de permissão. Restante placeholder visual.

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
- Fase 2C.1 concluída: domínio ApexGame criado com serialização toJson/fromJson.
- Fase 2C.2 concluída: contrato GameLibraryRepository criado.
- Fase 2C.3 concluída: repositório em memória (InMemoryGameLibraryRepository) criado.
- Fase 2C.4 concluída: GameLibraryState e GameLibraryController criados.
- Fase 2C.5 concluída: BibliotecaTab conectada ao controller com adição manual de jogo por nome.
- Fase 2C.6 concluída: lista real refinada com favoritar/desfavoritar e remover em memória.
- Fase 2C.7B concluída: persistência local da Biblioteca implementada com shared_preferences.
  - Jogos adicionados persistem ao fechar e reabrir o app.
  - Favorito persiste.
  - Remoção persiste.
  - Empty state aparece quando não há jogos.
  - BibliotecaTab usa SharedPreferencesGameLibraryRepository.
- Fase 2D.1 concluída: tela de detalhe básico do jogo criada.
  - GameDetailScreen criada com exibição de nome, favorito, packageName
    (com mensagem honesta quando ausente), perfil local (com mensagem
    honesta quando ausente), createdAt e updatedAt.
  - Rota /game-detail/:id criada no app_router.dart.
  - BibliotecaTab navega para detalhe ao tocar em um jogo real.
  - Detalhe carrega o jogo salvo pelo id instanciando
    SharedPreferencesGameLibraryRepository diretamente em initState.
  - Estado "Jogo não encontrado" tratado.
  - Back inline e back nativo retornam corretamente à Biblioteca.
  - Navegação usa push para preservar stack da Biblioteca.
- Fase 2D.3 concluída: edição básica do jogo implementada na GameDetailScreen.
  - Edição feita por diálogo inline, sem tela separada.
  - Campos editáveis: nome e packageName.
  - Nome obrigatório (não pode ficar vazio).
  - packageName opcional (pode ficar vazio).
  - updatedAt atualizado ao salvar.
  - Alterações persistidas via SharedPreferencesGameLibraryRepository.
  - Biblioteca reflete nome atualizado ao retornar do detalhe.
  - Cancelamento não altera dados.
- Fase 2E.1 concluída: GFX Profile local simples implementado na GameDetailScreen.
  - Enum GfxProfile criado com 4 valores: Equilibrado, Desempenho, Qualidade, Economia.
  - "Nenhum" é a ausência de perfil (localProfileName == null), oferecida como opção de limpeza no bottom sheet.
  - Seleção feita via bottom sheet na GameDetailScreen.
  - GFX Profile usa o campo localProfileName do ApexGame (existente desde a Fase 2C.1) para salvar a preferência escolhida.
  - updatedAt atualizado ao salvar perfil.
  - Disclaimer visível no bottom sheet: "Preferência salva localmente. Não altera jogos de terceiros."
  - Perfil selecionado exibido no detalhe do jogo.
  - Persiste ao fechar e reabrir o app via SharedPreferencesGameLibraryRepository (sem alteração no repositório).
- Fase 2F.2 concluída: seleção restrita de apps Android instalados implementada na Biblioteca.
  - Seleção restrita via intent MAIN/LAUNCHER em <queries> no AndroidManifest.
  - Não usa QUERY_ALL_PACKAGES.
  - Não adiciona uses-permission sensível.
  - Não solicita permissão runtime ao usuário.
  - MethodChannel Android/Kotlin criado (canal: apex_booster_plus/apps).
  - InstalledAppsDatasource criado em Dart (chama MethodChannel).
  - InstalledApp entity criada (packageName, appName).
  - AppPickerSheet criado (bottom sheet com lista de apps instalados).
  - BibliotecaTab permite escolher app instalado via AppPickerSheet.
  - Escolha preenche automaticamente nome e packageName no diálogo de adicionar jogo.
  - Entrada manual permanece como fallback quando o usuário prefere digitar.
  - Persistência continua via SharedPreferencesGameLibraryRepository (sem alteração no repositório).
  - Launcher real / abertura do jogo não implementado nesta fase.
- Fase 2G.2 concluída: ícone real do app selecionado exibido na Biblioteca e no detalhe.
  - AppIconWidget criado (widget reutilizável com fallback genérico).
  - MethodChannel Android/Kotlin expandido: getAppIcon retorna bytes PNG do ícone por packageName.
  - InstalledAppsDatasource expandido com getAppIcon.
  - Cache em memória por sessão para evitar recarregamento repetido.
  - Ícone real exibido no card da Biblioteca e na GameDetailScreen quando packageName disponível.
  - Fallback genérico mantido quando: sem packageName, app desinstalado, erro ou ícone inválido.
  - Fluxo "ADICIONAR JOGO" manual tenta vínculo automático por nome quando há match claro e único.
  - Quando há múltiplas correspondências, não escolhe automaticamente.
  - Não usa QUERY_ALL_PACKAGES.
  - Não adiciona uses-permission sensível.
  - Não solicita permissão runtime.
  - Ícone não é salvo em shared_preferences.
  - Ícone não é persistido como bytes/base64 em disco.
  - Launcher real / abertura do jogo não implementado.
- Fase 2H.2 concluída: autocomplete inteligente no fluxo ADICIONAR JOGO.
  - ADICIONAR JOGO migrado de AlertDialog para showModalBottomSheet.
  - BottomSheet suporta teclado aberto sem red screen.
  - Sugestões aparecem desde a primeira letra digitada.
  - Lista de sugestões rolável sem limite artificial de 3 itens.
  - Ranking por relevância:
    1. appName começa com o termo;
    2. appName contém o termo;
    3. packageName começa com o termo;
    4. packageName contém o termo.
  - Seleção de sugestão preenche nome + packageName automaticamente.
  - packageName digitado manualmente validado contra apps instalados/launchable.
  - Jogos fantasmas bloqueados (nome sem vínculo real não é salvo).
  - Duplicados bloqueados com mensagem exata: "Já instalado".
  - Fluxo ESCOLHER APP INSTALADO (AppPickerSheet) preservado.
  - Ícone real preservado quando packageName disponível.
  - Launcher real / abertura do jogo não implementado.
  - Boost real não implementado.
  - Alteração real de FPS/resolução/GPU não implementada.
- Fase 2I.2 concluída: validação de packageName na edição do detalhe do jogo.
  - packageName vazio salva como null — usa fallback de ícone genérico.
  - packageName válido e não duplicado salva normalmente.
  - packageName inválido (não instalado/launchable) é bloqueado com mensagem "App não encontrado nos instalados".
  - packageName duplicado em outro jogo é bloqueado com mensagem "Já instalado".
  - packageName igual ao jogo atual (sem alteração real) é permitido.
  - Edição apenas do nome continua funcionando sem validação de packageName desnecessária.
  - Favorito, Perfil GFX e createdAt não são alterados pela edição.
  - Risco pré-launcher reduzido: detalhes do jogo agora têm integridade de packageName garantida.
  - Launcher real / abertura do jogo não implementado.
  - Boost real não implementado.
  - Alteração real de FPS/resolução/GPU não implementada.
- Fase 2J.2 concluída: microcopy final da Biblioteca.
  - Contagem corrigida de "na sessão" para "na biblioteca".
  - Empty state honesto: "Nenhum jogo adicionado ainda."
  - Subtítulo do empty state orienta ação real: "Toque em ADICIONAR JOGO para começar sua biblioteca gamer."
  - Copy do card Perfis locais reflete que GFX Profile já existe no detalhe de cada jogo.
  - Nenhuma lógica alterada.
  - Nenhuma estrutura visual alterada.
  - Launcher real / abertura do jogo não implementado.
  - Boost real não implementado.
  - Alteração real de FPS/resolução/GPU não implementada.
- Fase 2K.2 concluída: launcher real controlado com Apex Boost Mode.
  - Launcher real implementado: app/jogo aberto pelo packageName via Intent Android.
  - MethodChannel existente expandido com case launchApp na MainActivity.kt.
  - InstalledAppsDatasource expandido com método launchApp.
  - GameDetailScreen recebeu botão ABRIR JOGO com fluxo visual Apex Boost Mode antes da abertura.
  - Apex Boost Mode exibe preparação visual honesta sem prometer FPS, RAM, GPU, Ping ou otimização real.
  - Tratamento de erro implementado: mensagem exibida se app não for encontrado ou não puder ser aberto.
  - AndroidManifest não foi alterado.
  - QUERY_ALL_PACKAGES não foi adicionado.
  - Nenhuma permissão nova foi adicionada.
  - Boost real não implementado.
  - Alteração real de FPS/RAM/GPU/Ping não implementada.
- flutter analyze passando.
- flutter test passando.
- Fase 2L.1 concluída: revisão end-to-end aprovada manualmente no Samsung S24 Ultra.
  - Biblioteca validada: adição, sugestões, duplicados, favoritar, remover, persistência.
  - ADICIONAR JOGO validado: BottomSheet, autocomplete desde 1ª letra, lista rolável, bloqueio de fantasmas.
  - ESCOLHER APP INSTALADO validado: picker, busca, ícones reais, duplicado tratado.
  - Detalhe do jogo validado: edição de nome/packageName, validações, GFX Profile.
  - Launcher real validado: botão ABRIR JOGO funciona pelo packageName.
  - Apex Boost Mode validado: sequência visual honesta, sem FPS/RAM/GPU/Ping/otimização real.
  - Nenhum crash. Nenhuma tela vermelha. Retorno ao app após jogo: normal.
- Fase 2L.2 concluída: CLAUDE.md atualizado para refletir revisão end-to-end aprovada.
- Fase 2M.1 concluída: escopo da Fase 2M aprovado e registrado.
- Fase 2M.2 concluída: motor local do Apex Scan criado.
  - ApexScanResult criado (entity com score, status, mensagens, detalhes).
  - ApexScanService criado (serviço puro Dart, sem permissões).
  - Score honesto baseado somente em packageName + isLaunchable.
  - ScanScore binário: pronto / incompleto.
  - GFX Profile, favorito e consistência: informação/ok, sem peso no score.
  - Ausência de GFX Profile informa "perfil padrão será usado" (neutro).
  - Testes criados e passando (flutter test).
  - flutter analyze passando.
  - Não usa PACKAGE_USAGE_STATS, SYSTEM_ALERT_WINDOW, AccessibilityService.
  - Não mede FPS, RAM, GPU, Ping real.
  - Não usa AndroidManifest, MainActivity, MethodChannel.
  - Apex Scan ainda não aparece na aba Preparar.
- Fase 2M.4A concluída: Apex Scan visual no Detalhe do Jogo implementado.
  - Card Apex Scan adicionado à GameDetailScreen.
  - Visual premium/gamer com animação, glow sutil e checks de status.
  - Status local exibido: "Pronto para iniciar", "Cadastro incompleto" ou "App não encontrado".
  - Indicadores visuais no módulo Apex Scan.
  - Motor local ApexScanService utilizado (sem alteração).
  - Sem métricas reais de FPS, RAM, GPU, Ping ou otimização.
  - Sem novas permissões.
  - AndroidManifest não alterado. MainActivity não alterada.
  - Aba Preparar não alterada.
  - flutter analyze passando. flutter test passando (64/64).
- Fase 2N concluída: decisão visual do Apex Scan registrada.
  - Visual atual do card Apex Scan no Detalhe do Jogo aprovado e mantido como está.
  - Indicadores visuais (FPS, RAM, GPU, Ping, Otimização, Boost, Performance) permanecem como efeito visual de produto.
  - _PerformanceModulesSection não removida nesta etapa.
  - Nenhum arquivo Dart, Kotlin ou AndroidManifest alterado.
  - Esses indicadores NÃO representam métricas reais de sistema implementadas.
- Fase 2-O.3 concluída: seção "MÉTRICAS REAIS" exibida no Apex Scan do Detalhe do Jogo.
  - Memória disponível exibida (leitura real do dispositivo).
  - Memória total exibida (leitura real do dispositivo).
  - Estado de memória exibido (calculado a partir dos valores reais).
  - Latência Apex exibida (teste de rede próprio, sem prometer ping de jogo externo).
  - Tratamento seguro de loading: indicador enquanto métricas carregam.
  - Tratamento seguro de erro: mensagem clara se leitura falhar.
  - Tratamento seguro de timeout: limite global de 4 segundos configurado.
  - Tratamento seguro de sem rede: estado específico exibido ao usuário.
  - Disclaimer exibido: "Snapshot do dispositivo. Não representa alteração de jogos."
  - Botão ABRIR JOGO preservado e funcionando.
  - Apex Boost Mode preservado e funcionando.
  - Seção visual do Apex Scan (indicadores visuais) preservada intacta.
  - FPS real não implementado.
  - GPU real não implementado.
  - Limpeza de RAM não implementada.
  - Boost real não implementado.
  - Otimização real não implementada.
  - AndroidManifest não alterado. MainActivity não alterada.
  - flutter analyze passando. flutter test passando (90/90).
- Fase 2-O.5 concluída: revisão visual das métricas reais aprovada no Samsung S24 Ultra.
  - Card Apex Scan carrega normalmente.
  - Seção "MÉTRICAS REAIS" aparece corretamente.
  - Memória disponível exibida em MB.
  - Memória total exibida em MB.
  - Estado de memória exibido corretamente.
  - Latência Apex exibida em ms ou estado seguro.
  - Loading não trava a tela.
  - Sem tela vermelha. Sem overflow visual.
  - Disclaimer "Snapshot do dispositivo. Não representa alteração de jogos." visível.
  - Botão ABRIR JOGO funcional.
  - Fluxo aprovado para avançar.
  - Observação não bloqueadora de performance: ao tocar no card de um jogo na
    Biblioteca, foi percebida demora de ~3 segundos para abrir a GameDetailScreen.
    O fluxo funciona, não há crash e o Detalhe abre corretamente. Porém, para
    padrão premium, o alvo é abertura em até 1 segundo, idealmente abaixo de
    500ms. Registrado como ponto de otimização futura antes de acumular novas
    camadas visuais ou funcionais.
- Fase 2-P.2 concluída: base Android/Kotlin do Modo Foco Gamer criada.
  - AndroidManifest com permissão ACCESS_NOTIFICATION_POLICY.
  - MainActivity.kt com MethodChannel focus_mode criado.
  - Métodos implementados: isPermissionGranted, openSettings, saveAndEnable, restore.
  - Sem UI nesta fase.
  - Sem ativação automática de DND.
- Fase 2-P.3 concluída: camada Dart do Modo Foco Gamer criada.
  - FocusModeService (contrato) criado.
  - FocusModeServiceImpl criado (Dart, via MethodChannel).
  - Testes criados para o serviço Dart.
  - Sem ativação automática de DND.
- Fase 2-P.4 concluída: UI de permissão do Modo Foco Gamer criada.
  - Card "Modo Foco Gamer" adicionado à aba Configurações.
  - Status "Permissão necessária" exibido quando acesso não concedido.
  - Status "Ativo" / "Permissão concedida" exibido quando acesso concedido.
  - Botão "PERMITIR MODO FOCO" abre configurações Android.
  - Revalidação automática ao retornar ao app (AppLifecycleState.resumed).
  - Correção do mismatch de MethodChannel: canal Dart/testes alinhado ao canal Kotlin
    (apex_booster_plus/focus_mode → com.allappsengineer.apex_booster_plus/focus_mode).
  - UI não ativa DND automaticamente.
  - UI não chama saveAndEnable nem restore.
  - Integração com ABRIR JOGO não implementada nesta fase.
  - flutter analyze passando. flutter test passando (102/102).
  - Validação visual no Samsung S24 Ultra aprovada.
- Fase 2-P.6 concluída: Modo Foco Gamer integrado ao fluxo ABRIR JOGO.
  - saveAndEnable chamado antes de abrir o jogo quando permissão concedida.
  - Ausência de permissão não bloqueia o lançamento do jogo.
  - Falha do saveAndEnable não bloqueia o lançamento do jogo.
  - restore chamado ao retornar ao app (AppLifecycleState.resumed), apenas se o app ativou o Modo Foco.
  - restore protegido no dispose sem setState e sem travar a tela.
  - App não abre configurações Android automaticamente.
  - Estado anterior do Não Perturbe respeitado.
  - Nenhuma nova permissão adicionada.
  - AndroidManifest não alterado. MainActivity não alterada. Configurações não alterada.
  - flutter analyze passando. flutter test passando (102/102).
  - Validação no Samsung S24 Ultra aprovada: com permissão concedida, sem permissão concedida, jogo abre normalmente, sem crash, sem tela vermelha, sem bloqueio do ABRIR JOGO.
- Fase 2-P.8 concluída: revisão end-to-end do Modo Foco Gamer no celular físico.
  - Modo Foco Gamer exibido como Ativo / Permissão concedida na aba Configurações.
  - Fluxo com permissão concedida validado no Samsung S24 Ultra:
    - Apex Boost Mode aparece normalmente ao tocar em ABRIR JOGO.
    - Jogo abre normalmente após o Apex Boost Mode.
    - Modo Foco Gamer não bloqueia o lançamento.
    - Retorno ao Apex Booster+: sem crash, sem tela vermelha, sem travamento.
  - Fluxo sem permissão validado no Samsung S24 Ultra:
    - Jogo abre normalmente.
    - App não tenta abrir configurações Android automaticamente.
    - Fluxo não trava.
  - Modo Foco Gamer integrado e validado de ponta a ponta.

Observação sobre a Fase 1.6B:

- A tentativa de esconder o ícone genérico Flutter apenas por ajuste de splash nativa Android foi descartada/revertida porque não resolveu o problema principal.
- A solução validada foi a Fase 1.6C: configurar o launcher icon real.

Arquivos relevantes criados na Fase 2C:

- lib/domain/entities/apex_game.dart
- lib/domain/repositories/game_library_repository.dart
- lib/data/repositories/in_memory_game_library_repository.dart
- lib/data/repositories/shared_preferences_game_library_repository.dart
- lib/presentation/controllers/game_library_state.dart
- lib/presentation/controllers/game_library_controller.dart
- lib/presentation/screens/home/tabs/biblioteca_tab.dart
- test/data/shared_preferences_game_library_repository_test.dart
- test/presentation/ (testes do GameLibraryController)

Arquivos relevantes criados ou alterados na Fase 2D.1:

- lib/presentation/screens/game_detail/game_detail_screen.dart
- lib/core/routing/app_router.dart (rota /game-detail/:id adicionada)
- lib/presentation/screens/home/tabs/biblioteca_tab.dart (navegação para detalhe adicionada)

Arquivos relevantes criados ou alterados na Fase 2D.3:

- lib/presentation/screens/game_detail/game_detail_screen.dart (diálogo de edição adicionado)
- lib/presentation/screens/home/tabs/biblioteca_tab.dart (reflete nome atualizado ao retornar)

Arquivos relevantes criados ou alterados na Fase 2E.1:

- lib/domain/entities/gfx_profile.dart (criado — enum GfxProfile)
- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — bottom sheet GFX Profile adicionado)

Arquivos relevantes criados ou alterados na Fase 2F.2:

- android/app/src/main/AndroidManifest.xml (queries com intent MAIN/LAUNCHER adicionada)
- android/app/src/main/kotlin/com/allappsengineer/apex_booster_plus/MainActivity.kt (MethodChannel registrado)
- lib/data/datasources/installed_apps_datasource.dart (criado)
- lib/domain/entities/installed_app.dart (criado)
- lib/presentation/widgets/app_picker_sheet.dart (criado)
- lib/presentation/screens/home/tabs/biblioteca_tab.dart (alterado — AppPickerSheet integrado)

Arquivos relevantes criados ou alterados na Fase 2G.2:

- android/app/src/main/kotlin/com/allappsengineer/apex_booster_plus/MainActivity.kt (alterado — getAppIcon adicionado ao MethodChannel)
- lib/data/datasources/installed_apps_datasource.dart (alterado — getAppIcon adicionado)
- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — AppIconWidget integrado no detalhe)
- lib/presentation/screens/home/tabs/biblioteca_tab.dart (alterado — AppIconWidget integrado nos cards)
- lib/presentation/widgets/app_picker_sheet.dart (alterado — AppIconWidget integrado no picker)
- lib/presentation/widgets/app_icon_widget.dart (criado)

Arquivos relevantes alterados na Fase 2H.2:

- lib/presentation/screens/home/tabs/biblioteca_tab.dart (alterado — ADICIONAR JOGO migrado para BottomSheet com autocomplete, validações e bloqueio de duplicados)

Arquivos relevantes alterados na Fase 2I.2:

- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — validação de packageName adicionada ao diálogo de edição)

Arquivos relevantes alterados na Fase 2J.2:

- lib/presentation/screens/home/tabs/biblioteca_tab.dart (alterado — microcopy final: "na biblioteca", empty state honesto, copy do card Perfis locais)

Arquivos relevantes alterados na Fase 2K.2:

- android/app/src/main/kotlin/com/allappsengineer/apex_booster_plus/MainActivity.kt (alterado — case launchApp adicionado ao MethodChannel)
- lib/data/datasources/installed_apps_datasource.dart (alterado — método launchApp adicionado)
- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — botão ABRIR JOGO e fluxo Apex Boost Mode adicionados)

Arquivos relevantes criados na Fase 2M.2:

- lib/domain/entities/apex_scan_result.dart (criado)
- lib/domain/services/apex_scan_service.dart (criado)
- test/domain/services/apex_scan_service_test.dart (criado)

Arquivos alterados na Fase 2M.4A:

- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — card Apex Scan adicionado)

Arquivos alterados na Fase 2-O.3:

- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — seção "MÉTRICAS REAIS" adicionada ao Apex Scan)

Arquivos criados ou alterados nas Fases 2-P.2 e 2-P.3:

- android/app/src/main/AndroidManifest.xml (alterado — ACCESS_NOTIFICATION_POLICY adicionado)
- android/app/src/main/kotlin/com/allappsengineer/apex_booster_plus/MainActivity.kt (alterado — MethodChannel focus_mode adicionado com isPermissionGranted, openSettings, saveAndEnable, restore)
- lib/domain/services/focus_mode_service.dart (criado — contrato FocusModeService)
- lib/data/services/focus_mode_service_impl.dart (criado — FocusModeServiceImpl via MethodChannel)
- test/data/services/focus_mode_service_impl_test.dart (criado — testes do serviço Dart)

Arquivos alterados na Fase 2-P.4:

- lib/data/services/focus_mode_service_impl.dart (alterado — canal MethodChannel corrigido para com.allappsengineer.apex_booster_plus/focus_mode)
- lib/presentation/screens/home/tabs/configuracoes_tab.dart (alterado — card Modo Foco Gamer adicionado)
- test/data/services/focus_mode_service_impl_test.dart (alterado — testes atualizados para canal correto)

Arquivos alterados na Fase 2-P.6:

- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — integração do Modo Foco Gamer ao fluxo ABRIR JOGO)

Estado visual atual:

Aprovado como checkpoint da Fase 2-O.5: seção "MÉTRICAS REAIS" validada no Samsung S24 Ultra com RAM disponível, RAM total, estado de memória e latência Apex lidos do dispositivo real.
Indicadores visuais (FPS, RAM, GPU, Ping, Otimização, Boost, Performance) são efeito visual de produto — não são métricas reais implementadas (exceto RAM e Latência Apex, exibidas na seção dedicada "MÉTRICAS REAIS").
flutter analyze e flutter test passando (90/90).
Fase 2-O.6 concluída por diagnóstico: demora de ~3s observada apenas no cold start (primeira abertura após iniciar o app). Após cache aquecido (SharedPreferences + getInstalledApps), navegação seguinte abre imediata. Sem crash, sem tela vermelha, sem bloqueio funcional. Classificado como refinamento futuro, não bloqueador. Meta futura: abertura em até 1s, ideal abaixo de 500ms.
Fase 2-P.4 aprovada: UI de permissão do Modo Foco Gamer validada no Samsung S24 Ultra. flutter analyze e flutter test passando (102/102).
Fase 2-P.6 aprovada: integração do Modo Foco Gamer ao ABRIR JOGO validada no Samsung S24 Ultra com e sem permissão concedida. flutter analyze e flutter test passando (102/102).
Fase 2-P.8 aprovada: revisão end-to-end do Modo Foco Gamer validada no Samsung S24 Ultra. Fluxo com permissão e sem permissão aprovados. ABRIR JOGO não bloqueado. Sem crash. Sem tela vermelha. Sem travamento.
Ainda não é o visual final absoluto do produto.

Observação:

A Biblioteca funciona com adição via BottomSheet com autocomplete inteligente (sugestões desde a primeira letra, ranking por relevância, lista rolável), validação de packageName manual contra apps instalados, bloqueio de jogos fantasmas, bloqueio de duplicados com mensagem "Já instalado", favoritar, remover, persistência entre sessões, navegação para detalhe, edição de nome e packageName com validação completa no detalhe (packageName inválido bloqueado, duplicado em outro jogo bloqueado, vazio permitido com fallback de ícone, igual ao jogo atual permitido), seleção de GFX Profile local, seleção restrita de apps instalados via AppPickerSheet (intent MAIN/LAUNCHER), e exibição de ícone real do app via AppIconWidget quando packageName disponível. Entrada manual permanece como fallback. Ícone não é persistido em disco — cache em memória por sessão. Contagem exibe "na biblioteca". Empty state honesto. Launcher real implementado na GameDetailScreen: botão ABRIR JOGO abre o app pelo packageName via Intent Android, precedido por sequência visual honesta Apex Boost Mode. Tratamento de erro presente se app não puder ser aberto. Apex Scan visual implementado na GameDetailScreen: card premium/gamer com animação, glow sutil, checks de status local e indicadores visuais. Status exibido: "Pronto para iniciar", "Cadastro incompleto" ou "App não encontrado". Motor local ApexScanService utilizado sem alteração. Seção "MÉTRICAS REAIS" implementada na GameDetailScreen (Fase 2-O.3): exibe memória disponível, memória total, estado de memória e latência Apex lidos do dispositivo real, com tratamento seguro de loading, erro, timeout e sem rede. Disclaimer exibido: "Snapshot do dispositivo. Não representa alteração de jogos." FPS real e GPU real não implementados.

Pendências conhecidas:

- Logo/asset oficial interno ainda não foi aprovado para uso definitivo nas telas Flutter.
- Localização multilíngue ainda não foi implementada.
- Tela Add Game separada não implementada (adição atual é diálogo inline na BibliotecaTab).
- GFX Profile avançado não implementado (perfis futuros: Fluidez, Competitivo, Ultra Visual, Personalizado).
- Apex Scan: motor local criado (Fase 2M.2). Card visual implementado no Detalhe do Jogo (Fase 2M.4A). Métricas reais parciais implementadas (Fase 2-O.3): RAM disponível, RAM total, estado de memória e latência Apex. Integração na aba Preparar ainda não implementada. FPS real, GPU real, limpeza de RAM, boost real e otimização real não implementados.
- Boost Engine não implementado.
- Histórico real não implementado.
- Configurações reais não implementadas.
- Hive não implementado (shared_preferences cobre a necessidade atual).
- Billing não implementado.
- Firebase não implementado.
- Overlay gamer não implementado.
- Modo Foco Gamer: UI de permissão implementada (Fase 2-P.4). Integração ao ABRIR JOGO implementada (Fase 2-P.6). Revisão end-to-end aprovada (Fase 2-P.8). Persistência segura do estado DND se o processo Android morrer: pendente. Ajustes avançados de lifecycle: pendente.
- Usage Stats não implementado.

---

## 15. PRÓXIMO PASSO OFICIAL

Fases 2A, 2B, 2C, 2D.1, 2D.3, 2E.1, 2F.2, 2G.2, 2H.2, 2I.2, 2J.2, 2K.2, 2L.1, 2L.2, 2M.1, 2M.2, 2M.4A, 2N, 2-O.1, 2-O.2, 2-O.3, 2-O.5, 2-O.6, 2-P.2, 2-P.3, 2-P.4, 2-P.6 e 2-P.8 concluídas.

Fase 2-O — Apex Metrics Real v1 (concluída):
- Fase 2-O.1: camada de dados de métricas reais criada.
- Fase 2-O.2: dados de métricas reais integrados ao Apex Scan.
- Fase 2-O.3: seção "MÉTRICAS REAIS" exibida na GameDetailScreen.
  - RAM disponível, RAM total, estado de memória e latência Apex implementados.
  - FPS real e GPU real: fora da v1, em estudo futuro.
- Fase 2-O.5: revisão visual aprovada no Samsung S24 Ultra.
  - Observação de performance: abertura do Detalhe com ~3s de demora. Não bloqueador.
  - Meta futura: abertura em até 1s, idealmente abaixo de 500ms.
- Fase 2-O.6: diagnóstico de performance concluído.
  - Demora observada apenas no cold start (primeira abertura após iniciar o app).
  - Origem: aquecimento de SharedPreferences + cache de getInstalledApps.
  - Após cache aquecido, navegação seguinte abre imediata.
  - Classificado como refinamento futuro, não bloqueador.
  - Logs temporários [DIAG 2-O.6A] removidos do código.

Fase 2-P — Modo Foco Gamer (concluída):
- Fase 2-P.2: base Android/Kotlin criada (MethodChannel focus_mode, AndroidManifest, métodos).
- Fase 2-P.3: camada Dart criada (FocusModeService, FocusModeServiceImpl, testes).
- Fase 2-P.4: UI de permissão criada e validada no Samsung S24 Ultra.
- Fase 2-P.6: integração do Modo Foco Gamer ao ABRIR JOGO concluída e validada.
  - saveAndEnable chamado antes de abrir o jogo quando permissão concedida.
  - Ausência de permissão não bloqueia o lançamento do jogo.
  - Falha do Modo Foco não bloqueia o lançamento do jogo.
  - restore chamado ao retornar ao app, apenas se o app ativou o Modo Foco.
  - restore protegido no dispose sem setState.
  - App não abre configurações automaticamente.
  - Estado anterior do Não Perturbe respeitado.
  - Nenhuma nova permissão adicionada.
- Fase 2-P.8: revisão end-to-end aprovada no Samsung S24 Ultra.
  - Fluxo com permissão concedida aprovado: Apex Boost Mode normal, jogo abre, sem crash, sem tela vermelha, sem travamento ao retornar.
  - Fluxo sem permissão aprovado: jogo abre normalmente, app não abre configurações automaticamente, fluxo não trava.
  - ABRIR JOGO não bloqueado em nenhum cenário.

Próximo passo imediato:
- Fase 2-Q — Planejamento de Histórico Real / Sessões.
  - Aguarda aprovação de escopo.

Nota estratégica:
- Fase 2M.4B (integração do Apex Scan na aba Preparar): adiada. A aba Preparar pode esperar.

Regra:

Nenhuma implementação nova deve começar sem aprovação explícita do escopo da fase correspondente.

---

## 16. PROIBIÇÕES TEMPORÁRIAS

Na Fase 2, até aprovação individual de cada item, é proibido:

- implementar Apex Scan real (leitura de métricas do dispositivo);
- implementar Boost Engine;
- implementar Billing;
- implementar Firebase;
- implementar Hive sem aprovação explícita (shared_preferences está aprovado apenas para persistência simples da Biblioteca);
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

Perfis implementados na Fase 2E.1:

- Equilibrado
- Desempenho
- Qualidade
- Economia
- Nenhum (remoção do perfil — ausência de localProfileName)

Perfis planejados para fases futuras (não implementados):

- Fluidez
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

Estado atual da implementação (Fase 2-O.3):

Motor local criado. Puro Dart. Sem permissões.
- ApexScanResult: entity com score, status, mensagens e detalhes por campo.
- ApexScanService: serviço que recebe ApexGame + isLaunchable e retorna ApexScanResult.
- Score binário: pronto (packageName + launchable) / incompleto.
- GFX Profile e favorito entram apenas como informação — sem peso negativo no score.
- Ausência de GFX Profile usa mensagem neutra: "perfil padrão será usado".
- Não usa PACKAGE_USAGE_STATS, SYSTEM_ALERT_WINDOW, AccessibilityService.
- UI do Detalhe do Jogo implementada (Fase 2M.4A): card premium/gamer com animação, status local e indicadores visuais.
- Apex Scan ainda não aparece na aba Preparar.
- Seção "MÉTRICAS REAIS" implementada na GameDetailScreen (Fase 2-O.3):
  - Memória disponível: leitura real do dispositivo.
  - Memória total: leitura real do dispositivo.
  - Estado de memória: calculado a partir dos valores reais.
  - Latência Apex: teste de rede próprio (sem prometer ping de jogo externo).
  - Tratamento seguro de loading, erro, timeout (4s) e sem rede.
  - Disclaimer: "Snapshot do dispositivo. Não representa alteração de jogos."
- FPS real: não implementado. Fora do escopo da v1.
- GPU real: não implementado. Fora do escopo da v1.
- Limpeza de RAM: não implementada.
- Boost real: não implementado.
- Otimização real: não implementada.

Decisão da Fase 2N: visual do Apex Scan mantido como está no Detalhe do Jogo.
Os indicadores visuais (FPS, RAM, GPU, Ping, Otimização, Boost aplicado,
Performance melhorada) são efeito visual de produto —
não representam métricas reais de sistema implementadas.
As métricas reais implementadas (RAM + Latência Apex) aparecem na seção dedicada "MÉTRICAS REAIS", separada dos indicadores visuais.

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
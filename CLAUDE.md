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
  - Aba Preparar (funcionalidade real implementada — Fase 2-S.4)
  - Aba Histórico (placeholder refinado visualmente)
  - Aba Configurações (placeholder refinado visualmente)
- GameDetailScreen
- GfxProfileScreen (tela dedicada de GFX Profile — criada na Fase GFX-U1.1; migrada para AppStrings na Fase LANG-U1.4A)

A existência dessas telas não significa aprovação visual final.

Estado funcional das abas da Home:

- Aba Início: refresh on tab focus implementado (Fase 2-T.1) e chips de métricas reais da última sessão implementados (Fase 2-T.2A): contagem de jogos, dados de sessão e chips de métricas reais atualizam ao retornar para a aba. Chips usam apenas dados reais já existentes no SessionRecord — sem nova query, sem novo MethodChannel, sem getInstalledApps. Nenhum dado inventado. Layout estrutural preservado. Fase GFX-U2.D: chip de Perfil GFX da última sessão exibido na InicioTab usando GfxProfile.fromLabel(session.gfxProfile) com cor e label semânticos — fallback seguro para nulos, vazios e valores desconhecidos; sessões sem perfil não exibem chip; chips de RAM e latência preservados; _loadData, cache de ícone e navegação não alterados. Fase LANG-U1.3A: InicioTab migrada para AppStrings/languageNotifier — textos respondem à troca de idioma sem reinicialização.
- Aba Biblioteca: funcionalidade real implementada (lista de jogos, adicionar por nome via BottomSheet com autocomplete inteligente desde a primeira letra, sugestões por ranking de relevância, lista rolável sem limite artificial, seleção de sugestão preenche nome + packageName, packageName manual validado contra apps instalados, jogos fantasmas bloqueados, duplicados bloqueados com mensagem "Já instalado", favoritar/desfavoritar, remover, persistência local com shared_preferences, navegação para detalhe ao tocar em um jogo, edição de nome e packageName via diálogo inline no detalhe com validação: packageName inválido bloqueado, packageName duplicado em outro jogo bloqueado, packageName vazio permitido com fallback de ícone, packageName igual ao jogo atual permitido, edição apenas do nome preservada sem validação desnecessária, seleção de GFX Profile local via bottom sheet no detalhe, seleção restrita de apps Android instalados via AppPickerSheet com intent MAIN/LAUNCHER — entrada manual permanece como fallback, exibição de ícone real do app instalado via AppIconWidget quando packageName disponível — fallback genérico quando ausente, app desinstalado ou erro, microcopy final ajustado: contagem exibe "na biblioteca", empty state honesto "Nenhum jogo adicionado ainda.", subtítulo orienta ação real, copy do card Perfis locais reflete que GFX Profile já existe no detalhe de cada jogo, launcher real implementado na GameDetailScreen via botão ABRIR JOGO com Apex Boost Mode visual antes da abertura). Observação (descoberta Fase 2-Q.4 — tratada na Fase 2-R): o launcher abre qualquer packageName válido instalado, incluindo apps não-game como Waze. O Android não diferencia automaticamente neste fluxo. Não é bug técnico — é lacuna de classificação/curadoria gamer. Tratamento implementado na Fase 2-R: badge "JOGO" e toggle "Apenas jogos verificados" no AppPickerSheet, confirmação obrigatória ao adicionar app com isGame == false, e badge "Não verificado" nos cards da Biblioteca para packageName com isGame == false. Nenhum app é bloqueado permanentemente — decisão fica com o usuário. ABRIR JOGO continua funcionando para qualquer packageName válido, sem restrição por isGame.
- Aba Preparar: funcionalidade real implementada (Fase 2-S.4): seletor de jogo com botão TROCAR (visível quando há mais de 1 jogo na biblioteca), pré-seleção automática por histórico (último jogo lançado → primeiro da biblioteca → null se vazia), Apex Scan local com 3 checks honestos (App vinculado, Perfil GFX, Prioridade — sem métricas falsas), snapshot real do dispositivo (RAM disponível, RAM total, estado de memória, latência Apex, Modo Foco), CTA "CONTINUAR PARA DETALHES" funcional com disable state quando não há jogo selecionado, navegação para GameDetailScreen via context.push, dois disclaimers honestos visíveis. Sem promessa de boost, FPS, GPU, ping ou otimização automática. Funções puras exportadas e cobertas por testes (selectGameForPreparation, buildIsLaunchableHint). Fase GFX-U2.A: Perfil GFX exibido na PrepararTab com cor e semântica por perfil selecionado (verde/Desempenho, azul/Qualidade, laranja/Economia, neutro/Equilibrado, cinza/Nenhum). Fase GFX-U2.B: Apex Scan local usa mensagem contextual por perfil GFX selecionado no check de Perfil GFX — sem alterar score nem status do scan. Fase GFX-U2.E.1: seção "Sugestões" exibida no _PrepScanCard quando há Perfil GFX selecionado — sugestões locais, leves e baseadas no perfil; Perfil "Nenhum" não exibe seção; sem promessa de FPS, GPU, resolução ou alteração real; refresh correto ao retornar da GfxProfileScreen.
- Aba Histórico: histórico real implementado e visualmente refinado (Fases 2-Q.5 e 2-Q.7): exibe sessões reais via SessionRecord e SharedPreferencesSessionRepository; estado vazio honesto; status success/attempted/failed exibidos com visual premium; sem duração real; sem "partida concluída"; revisão visual aprovada no Samsung S24 Ultra. Fase GFX-U2.C: chip de Perfil GFX exibido nos cards de sessão quando presente, usando GfxProfile.fromLabel(session.gfxProfile) com cor e label semânticos por perfil; fallback seguro para nulos e valores desconhecidos; sessões sem perfil não exibem chip. Fase SET-U1.1: refresh ao ganhar foco via isActive implementado — após limpeza de histórico nas Configurações, HistoricoTab exibe estado vazio imediatamente sem necessidade de reiniciar o app. Fase LANG-U1.3A: HistoricoTab migrada para AppStrings/languageNotifier — textos respondem à troca de idioma; chip de memória corrigido com variante por idioma (PT-BR: GB livre · normal, EN: GB free · stable, ES: GB libres · estable).
- Aba Configurações: card "Modo Foco Gamer" implementado (Fase 2-P.4) com UI de permissão. Ação "Limpar histórico de sessões" implementada (Fase SET-U1.1) com diálogo de confirmação — CANCELAR preserva sessões, LIMPAR apaga apenas apex_sessions. Card "Sobre" implementado (Fase SET-U1.2): exibe nome do app (Apex Booster+), versão (1.0.0), tagline "Prepare. Analise. Jogue.", modelo comercial "Instalação gratuita · Desbloqueio único" e disclaimer "Não altera jogos de terceiros automaticamente." — placeholder APP removido, CTA morta "ABRIR AJUSTES" removida. Fase SET-U1.3: card "Preferências em preparação" removido, card "Idioma do app" placeholder removido, import órfão de apex_feature_card.dart removido — aba exibe apenas itens reais: Modo Foco Gamer, Limpar histórico, Sobre. Fase LANG-U1.2: card "Idioma do app" real adicionado — exibe idioma atual, abre seletor com Português (BR), English e Español, opção atual marcada, seleção salva via LanguageService (chave apex_app_language), languageNotifier atualiza a UI imediatamente, idioma persiste ao fechar e reabrir o app. BottomNav migrada para AppStrings. Configurações migrada para AppStrings. Configurações e BottomNav mudam de idioma sem reiniciar o app. Fase LANG-U1.2A: seletor de idioma ajustado visualmente — opção "Español" não fica cortada ou colada na borda inferior, bottom sheet com respiro inferior adequado; lógica de idioma não alterada.

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
- Fase 2-Q.1 concluída: domínio SessionRecord criado.
- Fase 2-Q.2 concluída: repositório local de histórico criado (SharedPreferencesSessionRepository).
- Fase 2-Q.3 concluída: integração ao launcher implementada (sessão registrada ao abrir jogo).
- Fase 2-Q.4 concluída: validação no celular físico concluída.
  - Descoberta: launcher abre qualquer packageName válido instalado, incluindo apps não-game.
  - Lacuna de classificação/curadoria gamer. Não é bug crítico.
- Fase 2-Q.5 concluída: HistoricoTab exibe histórico real de sessões.
  - HistoricoTab conectada ao SharedPreferencesSessionRepository.
  - Exibe lista de SessionRecord salvas localmente.
  - Estado vazio honesto quando não há sessões.
  - Status das sessões exibido: success, attempted, failed.
  - Sem termos falsos: sem "tempo jogado", "duração" ou "partida concluída".
  - Placeholder visual substituído por funcionalidade real.
  - Apps não-game podem aparecer no histórico se forem abertos por packageName válido (lacuna de curadoria, não bug crítico).
  - flutter analyze passando. flutter test passando.
- Fase 2-Q.7 concluída: revisão visual premium da HistoricoTab.
  - Header refinado com identidade gamer premium.
  - Cards de sessão refinados com hierarquia clara.
  - Status success / attempted / failed mais legíveis e distintos visualmente.
  - Métricas opcionais exibidas como chips (ex: RAM).
  - RAM humanizada em MB.
  - Copy honesta preservada: sem duração real, sem tempo jogado, sem "partida concluída".
  - Sem novas permissões. Sem Firebase. Sem Usage Stats.
  - flutter analyze passando. flutter test passando (139/139).
  - Aprovado no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow.
- Fase 2-R.1 concluída: InstalledApp.isGame adicionado ao data layer.
  - Campo isGame (bool, default false) adicionado à entity InstalledApp.
  - InstalledApp.fromMap lê isGame do mapa retornado pelo MethodChannel Android.
  - MainActivity.kt retorna isGame usando ApplicationInfo.FLAG_IS_GAME e categoria GAME do Android.
  - Sem nova permissão. Sem QUERY_ALL_PACKAGES. AndroidManifest não alterado.
- Fase 2-R.2 concluída: badge "JOGO" e toggle "Apenas jogos verificados" no AppPickerSheet.
  - Badge verde "JOGO" exibido para apps com isGame == true no AppPickerSheet.
  - Toggle "Apenas jogos verificados" adicionado (inicia desligado por padrão).
  - Quando ligado, exibe somente apps com isGame == true.
  - Quando desligado, exibe lista completa.
  - Estado vazio honesto quando nenhum jogo verificado corresponde à busca.
  - Função pura applyPickerFilter criada (testável de forma isolada).
  - flutter analyze passando. flutter test passando.
- Fase 2-R.3 concluída: confirmação obrigatória ao adicionar app com isGame == false.
  - Ao selecionar app com isGame == false no AppPickerSheet, diálogo de confirmação exibido.
  - Cancelar: não adiciona o app à Biblioteca.
  - Adicionar mesmo assim: adiciona normalmente, sem bloqueio.
  - App com isGame == true: adiciona diretamente, sem diálogo.
  - Nenhum app bloqueado permanentemente. Decisão fica com o usuário.
  - flutter analyze passando. flutter test passando.
- Fase 2-R.4 concluída: badge "Não verificado" nos cards da Biblioteca.
  - Badge laranja "Não verificado" exibido nos cards quando: packageName está definido + app instalado + isGame == false.
  - Apps com isGame == true não exibem badge.
  - Apps sem packageName (entrada manual sem vínculo) não exibem badge.
  - buildNotVerifiedSet helper criado para calcular o conjunto de packageNames não verificados.
  - flutter analyze passando. flutter test passando (167/167).
  - Aprovado no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow.
- Fase 2-R.5 concluída: revisão end-to-end da Fase 2-R aprovada no Samsung S24 Ultra + CLAUDE.md atualizado.
- Fase PERF-G1.5 concluída: carregamento de apps instalados sob demanda na BibliotecaTab.
  - getInstalledApps não roda mais no cold start da HomeScreen.
  - BibliotecaTab carrega apps instalados sob demanda: quando a aba fica ativa ou no fluxo adicionar/escolher app.
  - Passagem entre telas ficou mais fluida, sem engasgos.
  - Commit: b5bca87 — perf: carregar apps instalados sob demanda na biblioteca.
  - flutter analyze passando. flutter test passando (177/177).
- Tentativa UI-G1.5 rejeitada: redesign visual pesado da BibliotecaTab reprovado no celular físico.
  - Quebrou visualmente cards e botões.
  - Revertida com git restore. Working tree limpo após reversão.
  - BibliotecaTab voltou ao estado do commit b5bca87.
  - Decisão registrada: manter a Biblioteca como está. Qualquer ajuste futuro deve ser mínimo, pontual e somente se o usuário pedir explicitamente.
  - flutter analyze passando. flutter test passando (177/177).
- Fase 2-S.4 concluída (documentada retroativamente por auditoria): PrepararTab — snapshot do dispositivo + CTA final.
  - PrepararTab deixou de ser placeholder visual.
  - Seletor de jogo implementado com botão TROCAR (visível quando _games.length > 1) → abre _GameSelectorSheet.
  - Pré-seleção automática: último jogo lançado (via SessionRecord) → primeiro da biblioteca → null se vazia.
  - Apex Scan local (_PrepScanCard): checks honestos de App vinculado, Perfil GFX e Prioridade. Não usa ApexScanService diretamente.
  - Snapshot real do dispositivo (_DeviceSnapshotCard): RAM disponível, RAM total, estado de memória, latência Apex, Modo Foco — via DeviceMetricsServiceImpl e FocusModeServiceImpl. Timeout de 6s. Fallback "Indisponível" por campo.
  - CTA "CONTINUAR PARA DETALHES": leva para GameDetailScreen via context.push('/game-detail/:id'). Desabilitado quando game == null.
  - Dois disclaimers honestos sempre visíveis: "Snapshot local. Sem alteração automática de desempenho." e "Snapshot local. Não representa alteração automática no jogo."
  - Sem promessa de boost, FPS, GPU, ping ou otimização automática.
  - Funções puras exportadas para testes: selectGameForPreparation, buildIsLaunchableHint.
  - Testes existentes: test/presentation/screens/home/tabs/preparar_tab_selection_test.dart (cobrindo selectGameForPreparation e buildIsLaunchableHint).
  - Arquivo principal: lib/presentation/screens/home/tabs/preparar_tab.dart.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (177/177).
  - Aprovação visual no celular físico: pendente.
- Fase 2-S.5 concluída: validação end-to-end da jornada principal no Samsung S24 Ultra.
  - Resultado reportado pelo usuário: "Tudo certo, tudo fluido." — aprovado.
  - Jornada principal validada de ponta a ponta:
    - abertura do app → Home;
    - Biblioteca: adicionar jogo e escolher app instalado;
    - Preparar: seletor de jogo, Apex Scan local, snapshot do dispositivo, CTA funcional;
    - Detalhe do Jogo: métricas reais, ABRIR JOGO, Apex Boost Mode;
    - retorno ao app após jogo;
    - Histórico: sessão registrada e exibida com visual premium;
    - troca entre abas: fluida.
  - Sem crash. Sem tela vermelha. Sem overflow relevante. Sem engasgos relevantes.
  - Biblioteca preservada visualmente e com lazy load aprovado.
  - PrepararTab funcional aprovada no celular físico.
  - Home fluida.
  - Produto com jornada principal funcional e validada end-to-end.
  - Nenhum arquivo Dart, Kotlin, AndroidManifest ou pubspec alterado nesta fase.
- Fase 2-T.1 concluída: InicioTab refresh on tab focus implementado e aprovado no Samsung S24 Ultra.
  - Contagem de jogos atualiza ao retornar para a aba Início após mudanças na Biblioteca.
  - Contagem de sessões e dados da última sessão atualizam após uso do fluxo principal.
  - Sem novo atraso perceptível ao trocar de aba.
  - BibliotecaTab e lazy load da PERF-G1.5 preservados intactos.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando com baseline atual.
- Fase 2-T.2A concluída: InicioTab — chips de métricas reais na última sessão.
  - Chips de métricas reais exibidos no card de última sessão da InicioTab.
  - Chips usam apenas dados reais já existentes no SessionRecord.
  - Nenhum dado inventado ou simulado exibido.
  - Nenhuma nova query. Nenhum novo MethodChannel. Nenhuma chamada a getInstalledApps.
  - Cache de ícone aprovado preservado. Layout estrutural da InicioTab preservado.
  - BibliotecaTab e lazy load da PERF-G1.5 preservados intactos.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (177/177).
  - Commit: 33fb6c2 — ux: exibir metricas reais na ultima sessao da inicio.
  - Aprovado no Samsung S24 Ultra.
- Fase GFX-U1.1 concluída: tela dedicada de GFX Profile criada.
  - GfxProfileScreen criada com cards selecionáveis para Equilibrado, Desempenho, Qualidade, Economia e Nenhum.
  - Seleção persiste por jogo via localProfileName (SharedPreferencesGameLibraryRepository, sem alteração no repositório).
  - Ao selecionar um perfil, o app retorna ao Detalhe do Jogo e atualiza o valor exibido.
  - Bottom sheet legado de GFX Profile removido (código morto detectado pelo flutter analyze).
  - Rota /gfx-profile/:id criada no app_router.dart.
  - Disclaimer obrigatório preservado: "Preferências salvas localmente. Não altera jogos de terceiros."
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (177/177).
  - Aprovado visualmente no Samsung S24 Ultra.
- Fase GFX-U1.1A concluída: acesso ao GFX Profile no Detalhe do Jogo melhorado.
  - Item Perfil GFX no Detalhe do Jogo deixou de parecer linha secundária.
  - Passou a ter peso visual de botão/card premium.
  - Aprovado visualmente pelo usuário no Samsung S24 Ultra.
  - flutter analyze passando. flutter test passando (177/177).
- Fase GFX-U2.A+B concluída: GFX Profile influenciando a jornada local de preparação.
  - Fase GFX-U2.A: PrepararTab exibe Perfil GFX com cor e semântica por perfil selecionado.
    - Cor e label do perfil vinculados ao localProfileName real do jogo selecionado.
    - Verde/Desempenho, azul/Qualidade, laranja/Economia, neutro/Equilibrado, cinza/Nenhum.
    - Sem inventar dados. Sem promessa de FPS, GPU, resolução, textura ou gráficos internos.
  - Fase GFX-U2.B: Apex Scan local (_PrepScanCard) usa mensagem contextual por perfil.
    - Mensagem do check de Perfil GFX reflete o perfil selecionado (ex: "Desempenho ativo", "Nenhum perfil — padrão será usado").
    - Score e status do Apex Scan não foram alterados.
    - Sem promessa falsa de melhoria técnica.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (190/190).
  - Aprovado no Samsung S24 Ultra.
- Fase GFX-U2.C concluída: Histórico exibindo o Perfil GFX usado na sessão.
  - Chip "GFX: [Perfil]" exibido no card de cada sessão na HistoricoTab quando session.gfxProfile está presente.
  - Chip usa GfxProfile.fromLabel(session.gfxProfile): cor e label semânticos por perfil.
  - Desempenho → verde; Equilibrado → azul; Qualidade → laranja; Economia → cinza.
  - Sessões sem perfil não exibem chip — fallback seguro para nulos.
  - Perfil inválido/desconhecido não quebra a tela — fallback seguro.
  - Nenhuma lógica de sessão alterada.
  - SessionRecord, repositories, GameDetailScreen, PrepararTab e ApexScanService não alterados.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (190/190).
  - Aprovado no Samsung S24 Ultra.
- Fase GFX-U2.D concluída: InicioTab exibindo Perfil GFX semântico da última sessão.
  - Chip "GFX: [Perfil]" exibido no card de última sessão da InicioTab quando session.gfxProfile está presente.
  - Chip usa GfxProfile.fromLabel(session.gfxProfile): cor e label semânticos por perfil.
  - Perfil nulo, vazio ou desconhecido não exibe chip — fallback seguro.
  - Chips de RAM e latência preservados visualmente.
  - Nenhuma lógica de sessão alterada.
  - _loadData, cache de ícone e navegação permaneceram intactos.
  - BibliotecaTab, PrepararTab, HistoricoTab, GameDetailScreen, GfxProfileScreen, ApexScanService, SessionRecord, repositories, services, Kotlin, AndroidManifest e pubspec não alterados.
  - flutter analyze passando. flutter test passando (190/190).
  - Aprovado no Samsung S24 Ultra.
- Fase GFX-U2 — validação end-to-end física concluída no Samsung S24 Ultra.
  - Ciclo completo validado: Detalhe do Jogo → GFX Profile → Preparar → Apex Scan → Abrir Jogo → Histórico → Início.
  - Todos os perfis validados fisicamente: Desempenho, Qualidade, Economia, Equilibrado e Nenhum.
  - Detalhe do Jogo: perfil selecionado exibido corretamente para cada perfil.
  - PrepararTab: cor, label e mensagem contextual corretos por perfil.
  - Apex Scan local: contextualiza o perfil sem alterar score nem status.
  - Abrir Jogo: registra sessão normalmente independente do perfil ativo.
  - Histórico: chip GFX exibido com perfil correto para cada sessão registrada.
  - Início: chip GFX da última sessão exibido com semântica correta.
  - Perfil "Nenhum": não gera chip falso, "GFX: null" ou chip vazio em nenhuma tela.
  - Sessões antigas: preservam o perfil registrado no momento da abertura.
  - Sem crash. Sem tela vermelha. Sem overflow relevante. Sem engasgos relevantes.
  - flutter analyze passando. flutter test passando (190/190).
  - GFX-U2 marcada como concluída end-to-end.
- Fase GFX-U2.E.1 concluída: recomendações locais por Perfil GFX na PrepararTab.
  - Seção "Sugestões" exibida no _PrepScanCard quando há Perfil GFX selecionado.
  - Sugestões locais, leves e baseadas no perfil selecionado.
  - Perfil "Nenhum" não exibe seção de sugestões.
  - Sem promessa de FPS, GPU, resolução, textura ou alteração gráfica real.
  - Recomendações usam apenas dados já carregados na PrepararTab — sem nova chamada de MethodChannel, sem getInstalledApps, sem nova permissão, sem nova dependência.
  - Correção de refresh da PrepararTab validada: ao mudar o Perfil GFX no Detalhe/GfxProfile e retornar à PrepararTab, o perfil, a mensagem do Apex Scan e as sugestões atualizam corretamente.
  - Score/status do Apex Scan preservados. CTA e navegação preservados.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão. Nenhuma nova dependência.
  - flutter analyze passando. flutter test passando (226/226).
  - Commit: 3fc4a7a — feat: adicionar recomendacoes gfx na preparacao.
  - Aprovado no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo relevante.
- Fase SET-U1.1 concluída: Limpar histórico de sessões nas Configurações.
  - Ação real "Limpar histórico" adicionada à ConfiguraçõesTab.
  - Diálogo de confirmação obrigatório antes de apagar.
  - CANCELAR não apaga o histórico.
  - LIMPAR remove apenas as sessões salvas (chave apex_sessions no SharedPreferences).
  - Biblioteca, jogos, perfis GFX, modo foco e demais dados locais permanecem intactos.
  - SharedPreferencesSessionRepository.clearAll() utilizado como contrato existente.
  - HistoricoTab recebeu refresh ao ganhar foco via isActive: após limpeza, exibe estado vazio imediatamente.
  - HomeScreen atualizada para passar isActive para a HistoricoTab.
  - InicioTab: não mantém última sessão antiga após limpeza — atualiza corretamente no próximo foco.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão. Nenhuma nova dependência.
  - flutter analyze passando. flutter test passando (233/233).
  - Commit: 6fc286f — feat: adicionar limpeza de historico nas configuracoes.
  - Aprovado no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo relevante.
  - Fecha a primeira configuração real mínima do app.
- Fase SET-U1.2 concluída: Sobre / versão do app nas Configurações.
  - Card "Sobre" adicionado à ConfiguraçõesTab.
  - Exibe nome do app: Apex Booster+.
  - Exibe versão: 1.0.0 (valor fixo — sem package_info_plus).
  - Exibe tagline: "Prepare. Analise. Jogue."
  - Exibe modelo comercial: "Instalação gratuita · Desbloqueio único".
  - Exibe disclaimer: "Não altera jogos de terceiros automaticamente."
  - Placeholder APP removido da aba Configurações.
  - CTA morta "ABRIR AJUSTES" removida.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão. Nenhuma nova dependência. Sem package_info_plus.
  - flutter analyze passando. flutter test passando (239/239).
  - Commit: 5a614b7 — feat: adicionar sobre do app nas configuracoes.
  - Aprovado no Samsung S24 Ultra.
- Fase SET-U1.3 concluída: Limpeza dos placeholders restantes em Configurações.
  - Card "Preferências em preparação" removido da ConfiguraçõesTab.
  - Card "Idioma do app" placeholder removido da ConfiguraçõesTab.
  - Import órfão de apex_feature_card.dart removido.
  - Aba Configurações exibe apenas itens reais/funcionais: Header, Modo Foco Gamer, Limpar histórico de sessões, Sobre o Apex Booster+.
  - Modo Foco Gamer, Limpar histórico e Sobre preservados e funcionais.
  - Observação estratégica: remoção do card "Idioma do app" não elimina a necessidade de idioma no produto — foi removido um placeholder morto. Idioma retorna futuramente como funcionalidade real em fase própria (LANG-U1).
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão. Nenhuma nova dependência.
  - flutter analyze passando. flutter test passando (241/241).
  - Commit: ad75f54 — ux: remover placeholders das configuracoes.
  - Aprovado no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo relevante.
- Fase LANG-U1.1 concluída: infraestrutura de idioma criada.
  - Enum AppLanguage criado com ptBr, en e es.
  - Extensão com code, label, nativeLabel e fromName/fallback seguro.
  - languageNotifier global criado para permitir rebuild da UI quando o idioma mudar.
  - LanguageService criado com persistência via shared_preferences (chave: apex_app_language).
  - AppStrings criado com getters e métodos iniciais para as telas principais.
  - main.dart carrega o idioma salvo antes do runApp.
  - ApexBoosterApp usa ListenableBuilder ligado ao languageNotifier.
  - Nenhuma tela de apresentação migrada ainda.
  - Nenhum card de idioma adicionado ainda.
  - Nenhuma dependência nova adicionada. pubspec.yaml não alterado.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (316/316).
  - Commit: a5d9310 — feat: adicionar infraestrutura de idioma.
- Fase LANG-U1.2 concluída: seletor de idioma real nas Configurações + migração de BottomNav e Configurações.
  - Card "Idioma do app" real adicionado à ConfiguraçõesTab.
  - Card exibe o idioma atual do app.
  - Ao tocar, abre seletor com Português (BR), English e Español.
  - A opção atual aparece marcada no seletor.
  - Ao selecionar idioma, a escolha é salva via LanguageService (chave apex_app_language).
  - languageNotifier atualiza a UI imediatamente — sem reinicialização do app.
  - Idioma persiste ao fechar e reabrir o app.
  - BottomNav migrada para AppStrings — labels mudam conforme idioma selecionado.
  - ConfiguraçõesTab migrada para AppStrings — textos mudam conforme idioma selecionado.
  - Sem flutter_localizations. Sem intl. Sem nova dependência.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando com baseline atual.
  - Commits: 4ad1c0f — feat: adicionar seletor de idioma nas configuracoes.
  - Aprovado no Samsung S24 Ultra.
- Fase LANG-U1.2A concluída: ajuste visual do seletor de idioma.
  - Opção "Español" deixou de ficar cortada ou colada na borda inferior do bottom sheet.
  - Bottom sheet com respiro inferior adequado.
  - Lógica de idioma, persistência e atualização imediata preservadas sem alteração.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando com baseline atual.
  - Commit: 10f9559 — ux: ajustar seletor de idioma nas configuracoes.
  - Aprovado no Samsung S24 Ultra.
- Fase LANG-U1.3A concluída: InicioTab + HistoricoTab + SplashScreen migradas para AppStrings.
  - InicioTab migrada para AppStrings/languageNotifier.
  - HistoricoTab migrada para AppStrings/languageNotifier.
  - SplashScreen Flutter passou a usar a tagline via AppStrings.
  - Splash nativa Android não alterada.
  - Onboarding completo não alterado: Welcome, HowItWorks e Permissions não alterados.
  - BibliotecaTab, PrepararTab, GameDetailScreen, GfxProfileScreen, ConfiguracoesTab e HomeScreen não alteradas nesta fase.
  - AppStrings recebeu getters/métodos necessários para Início, Histórico e Splash.
  - Tempo relativo centralizado em AppStrings.
  - Chip de memória do Histórico corrigido com variante por idioma:
    - PT-BR: "GB livre · normal"
    - EN: "GB free · stable"
    - ES: "GB libres · estable"
  - Chip GFX no Histórico e na Início permanece traduzido conforme perfil.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão. Nenhuma nova dependência.
  - flutter analyze passando. flutter test passando (361/361).
  - Commit: f6bfa02 — feat: traduzir inicio historico e splash.
  - Aprovado no Samsung S24 Ultra em English, Español e Português (BR). Sem crash. Sem tela vermelha. Sem overflow relevante. Sem atraso novo.
- Fase LANG-U1.3B concluída: Welcome + HowItWorks + Permissions migradas para AppStrings.
  - WelcomeScreen migrada para AppStrings/languageNotifier.
  - HowItWorksScreen migrada para AppStrings/languageNotifier.
  - PermissionsScreen migrada para AppStrings/languageNotifier.
  - Textos do onboarding traduzidos para PT-BR, English e Español.
  - Tagline consistente por idioma: PT-BR "Prepare. Analise. Jogue." / EN "Prepare. Scan. Play." / ES "Prepara. Analiza. Juega."
  - Splash nativa Android não alterada. InicioTab, HistoricoTab e SplashScreen Flutter não alteradas.
  - ConfiguracoesTab, HomeScreen, BibliotecaTab, PrepararTab, GameDetailScreen e GfxProfileScreen não alteradas.
  - ApexScanService, repositories, services, Kotlin, AndroidManifest e pubspec não alterados.
  - Nenhuma nova dependência adicionada.
  - flutter analyze passando. flutter test passando (397/397).
  - Commit: a0308a1 — feat: traduzir onboarding.
  - Aprovado no Samsung S24 Ultra em Português, English e Español. Sem crash. Sem tela vermelha. Sem overflow relevante. Sem atraso novo.
- Fase LANG-U1.4A concluída: GfxProfileScreen migrada para AppStrings.
  - GfxProfileScreen migrada para AppStrings/languageNotifier.
  - Título, prefixo "Atual/Current/Actual", nomes dos perfis, descrições e disclaimer migrados.
  - Tela Perfil GFX responde à troca de idioma sem reinicialização do app.
  - Seleção de perfil continua funcionando.
  - Retorno automático ao Detalhe do Jogo continua funcionando.
  - Persistência em localProfileName preservada.
  - Layout, ícones, cores, destaque do perfil selecionado e SingleChildScrollView preservados.
  - PrepararTab, BibliotecaTab e GameDetailScreen não alteradas.
  - InicioTab, HistoricoTab, ConfiguracoesTab, HomeScreen, onboarding e SplashScreen não alterados.
  - ApexScanService, repositories, services, Kotlin, AndroidManifest e pubspec não alterados.
  - Nenhuma dependência nova adicionada.
  - flutter analyze passando. flutter test passando (417/417).
  - Commit: b4a1d2e — feat: traduzir tela de perfil gfx.
  - Aprovado no Samsung S24 Ultra em Português (BR), English e Español. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo.

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

Arquivos relevantes criados ou alterados nas Fases 2-Q.1 a 2-Q.5:

- lib/domain/entities/session_record.dart (criado — entity SessionRecord)
- lib/domain/repositories/session_repository.dart (criado — contrato SessionRepository)
- lib/data/repositories/shared_preferences_session_repository.dart (criado — persistência local de sessões)
- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — registro de sessão ao abrir jogo)
- lib/presentation/screens/home/tabs/historico_tab.dart (alterado — exibição real de sessões)

Arquivos alterados na Fase 2-Q.7:

- lib/presentation/screens/home/tabs/historico_tab.dart (alterado — revisão visual premium: header, cards, status chips, RAM humanizada, copy honesta preservada)

Arquivos relevantes criados ou alterados nas Fases 2-R.1 a 2-R.4:

- lib/domain/entities/installed_app.dart (alterado — campo isGame adicionado com fromMap)
- android/app/src/main/kotlin/com/allappsengineer/apex_booster_plus/MainActivity.kt (alterado — isGame retornado no MethodChannel de apps instalados via FLAG_IS_GAME + categoria GAME)
- lib/presentation/widgets/app_picker_sheet.dart (alterado — badge JOGO, toggle filtro, applyPickerFilter)
- lib/presentation/screens/home/tabs/biblioteca_tab.dart (alterado — confirmação para isGame == false, badge Não verificado, buildNotVerifiedSet)
- test/presentation/widgets/app_picker_sheet_filter_test.dart (criado — testes da função applyPickerFilter)

Arquivos criados ou alterados nas Fases GFX-U1.1 e GFX-U1.1A:

- lib/presentation/screens/gfx_profile/gfx_profile_screen.dart (criado — GfxProfileScreen com cards selecionáveis)
- lib/core/routing/app_router.dart (alterado — rota /gfx-profile/:id adicionada)
- lib/presentation/screens/game_detail/game_detail_screen.dart (alterado — bottom sheet legado removido, acesso GFX Profile com visual premium, navegação para GfxProfileScreen)

Arquivos alterados na Fase GFX-U2.A+B:

- lib/presentation/screens/home/tabs/preparar_tab.dart (alterado — exibição de Perfil GFX com cor/semântica por perfil; mensagem contextual por perfil no _PrepScanCard)

Arquivos alterados na Fase GFX-U2.C:

- lib/presentation/screens/home/tabs/historico_tab.dart (alterado — chip de Perfil GFX adicionado aos cards de sessão via GfxProfile.fromLabel)

Arquivos alterados na Fase GFX-U2.E.1:

- lib/presentation/screens/home/home_screen.dart (alterado — refresh da PrepararTab corrigido)
- lib/presentation/screens/home/tabs/preparar_tab.dart (alterado — seção "Sugestões" adicionada ao _PrepScanCard por perfil GFX)
- test/presentation/screens/home/tabs/preparar_tab_recommendations_test.dart (criado — testes das recomendações por perfil)

Arquivos alterados na Fase SET-U1.1:

- lib/presentation/screens/home/home_screen.dart (alterado — isActive passado para HistoricoTab)
- lib/presentation/screens/home/tabs/configuracoes_tab.dart (alterado — ação "Limpar histórico" com diálogo de confirmação)
- lib/presentation/screens/home/tabs/historico_tab.dart (alterado — refresh ao ganhar foco via isActive)
- test/presentation/screens/home/tabs/configuracoes_tab_clear_test.dart (criado — testes da ação de limpeza)

Arquivos alterados na Fase SET-U1.2:

- lib/presentation/screens/home/tabs/configuracoes_tab.dart (alterado — card "Sobre" adicionado; placeholder APP e CTA morta removidos)
- test/presentation/screens/home/tabs/configuracoes_tab_about_test.dart (criado — testes do card Sobre)

Arquivos alterados na Fase SET-U1.3:

- lib/presentation/screens/home/tabs/configuracoes_tab.dart (alterado — card "Preferências em preparação" removido, card "Idioma do app" removido, import órfão de apex_feature_card.dart removido)

Arquivos criados ou alterados na Fase LANG-U1.1:

- lib/core/i18n/app_language.dart (criado — enum AppLanguage com ptBr, en, es; extensão com code, label, nativeLabel, fromName e fallback seguro)
- lib/core/i18n/app_strings.dart (criado — AppStrings com getters e métodos iniciais por idioma para as telas principais)
- lib/core/i18n/language_service.dart (criado — LanguageService com persistência via shared_preferences, chave apex_app_language; languageNotifier global)
- lib/main.dart (alterado — carrega idioma salvo antes do runApp; ApexBoosterApp usa ListenableBuilder ligado ao languageNotifier)
- test/core/i18n/app_language_test.dart (criado — testes do enum e extensão AppLanguage)
- test/core/i18n/app_strings_test.dart (criado — testes do AppStrings)
- test/core/i18n/language_service_test.dart (criado — testes do LanguageService)

Arquivos alterados nas Fases LANG-U1.2 e LANG-U1.2A:

- lib/presentation/screens/home/tabs/configuracoes_tab.dart (alterado — card "Idioma do app" real adicionado com seletor bottom sheet; migração para AppStrings; ajuste visual de respiro inferior no seletor — LANG-U1.2A)
- lib/presentation/screens/home/home_screen.dart (alterado — BottomNav migrada para AppStrings)

Arquivos alterados na Fase LANG-U1.3A:

- lib/core/i18n/app_strings.dart (alterado — getters/métodos para Início, Histórico, Splash e tempo relativo centralizado)
- lib/presentation/screens/home/tabs/inicio_tab.dart (alterado — migrada para AppStrings/languageNotifier)
- lib/presentation/screens/home/tabs/historico_tab.dart (alterado — migrada para AppStrings/languageNotifier; chip de memória corrigido PT-BR/EN/ES)
- lib/presentation/screens/splash/splash_screen.dart (alterado — tagline via AppStrings)
- test/core/i18n/app_strings_test.dart (alterado — testes dos novos getters/métodos)

Arquivos alterados na Fase LANG-U1.3B:

- lib/core/i18n/app_strings.dart (alterado — getters/métodos para Welcome, HowItWorks e Permissions; taglines por idioma)
- lib/presentation/screens/welcome/welcome_screen.dart (alterado — migrada para AppStrings/languageNotifier)
- lib/presentation/screens/how_it_works/how_it_works_screen.dart (alterado — migrada para AppStrings/languageNotifier)
- lib/presentation/screens/permissions/permissions_screen.dart (alterado — migrada para AppStrings/languageNotifier)
- test/core/i18n/app_strings_test.dart (alterado — testes dos novos getters/métodos de onboarding)

Arquivos alterados na Fase LANG-U1.4A:

- lib/core/i18n/app_strings.dart (alterado — getters/métodos para GfxProfileScreen: título, prefixo atual, nomes e descrições de perfis, disclaimer)
- lib/presentation/screens/gfx_profile/gfx_profile_screen.dart (alterado — migrada para AppStrings/languageNotifier)
- test/core/i18n/app_strings_test.dart (alterado — testes dos novos getters/métodos da GfxProfileScreen)

Estado visual atual:

Aprovado como checkpoint da Fase 2-O.5: seção "MÉTRICAS REAIS" validada no Samsung S24 Ultra com RAM disponível, RAM total, estado de memória e latência Apex lidos do dispositivo real.
Indicadores visuais (FPS, RAM, GPU, Ping, Otimização, Boost, Performance) são efeito visual de produto — não são métricas reais implementadas (exceto RAM e Latência Apex, exibidas na seção dedicada "MÉTRICAS REAIS").
flutter analyze e flutter test passando (90/90).
Fase 2-O.6 concluída por diagnóstico: demora de ~3s observada apenas no cold start (primeira abertura após iniciar o app). Após cache aquecido (SharedPreferences + getInstalledApps), navegação seguinte abre imediata. Sem crash, sem tela vermelha, sem bloqueio funcional. Classificado como refinamento futuro, não bloqueador. Meta futura: abertura em até 1s, ideal abaixo de 500ms.
Fase 2-P.4 aprovada: UI de permissão do Modo Foco Gamer validada no Samsung S24 Ultra. flutter analyze e flutter test passando (102/102).
Fase 2-P.6 aprovada: integração do Modo Foco Gamer ao ABRIR JOGO validada no Samsung S24 Ultra com e sem permissão concedida. flutter analyze e flutter test passando (102/102).
Fase 2-P.8 aprovada: revisão end-to-end do Modo Foco Gamer validada no Samsung S24 Ultra. Fluxo com permissão e sem permissão aprovados. ABRIR JOGO não bloqueado. Sem crash. Sem tela vermelha. Sem travamento.
Fase 2-Q.5 implementada: HistoricoTab exibe histórico real de sessões via SharedPreferencesSessionRepository.
Fase 2-Q.7 aprovada: revisão visual premium da HistoricoTab validada no Samsung S24 Ultra. Header, cards, status e chips refinados. Copy honesta preservada. flutter analyze e flutter test passando (139/139).
Fase 2-R.5 aprovada: revisão end-to-end da Fase 2-R validada no Samsung S24 Ultra. Badge JOGO, toggle filtro, confirmação não-game e badge Não verificado funcionando. ABRIR JOGO preservado. flutter analyze passando. flutter test passando (167/167).
Fase PERF-G1.5 aprovada: carregamento de apps instalados sob demanda implementado e validado no Samsung S24 Ultra. getInstalledApps não roda mais no cold start da HomeScreen. BibliotecaTab carrega apps sob demanda — passagem entre telas mais fluida. Commit b5bca87. flutter analyze passando. flutter test passando (177/177).
Tentativa UI-G1.5 rejeitada e revertida: redesign visual pesado da BibliotecaTab quebrou cards e botões no celular físico. Revertida com git restore para o estado do commit b5bca87. BibliotecaTab mantida como está. Não insistir em redesign visual pesado dessa tela — qualquer ajuste futuro deve ser mínimo, pontual e somente se explicitamente solicitado.
Fase 2-S.4 aprovada por auditoria: PrepararTab deixou de ser placeholder. Seletor de jogo, pré-seleção por histórico, Apex Scan local, snapshot real do dispositivo e CTA funcional verificados. flutter analyze passando. flutter test passando (177/177).
Fase 2-S.5 aprovada: validação end-to-end da jornada principal no Samsung S24 Ultra. "Tudo certo, tudo fluido." — aprovado pelo usuário. Jornada principal: abertura do app → Home → Biblioteca → Preparar → Detalhe do Jogo → ABRIR JOGO → retorno → Histórico → troca de abas. Sem crash. Sem tela vermelha. Sem overflow. Sem engasgos. Produto com jornada principal funcional e validada.
Fase 2-T.1 aprovada: InicioTab refresh on tab focus implementado e validado no Samsung S24 Ultra. Contagem de jogos e dados de sessão atualizam ao retornar para a aba. Sem novo atraso perceptível. BibliotecaTab e lazy load PERF-G1.5 preservados. flutter analyze passando. flutter test passando.
Fase 2-T.2A aprovada: InicioTab exibe chips de métricas reais no card de última sessão. Dados reais apenas (SessionRecord existente). Sem nova query, novo MethodChannel ou getInstalledApps. Nenhum dado inventado. Layout estrutural preservado. BibliotecaTab e lazy load PERF-G1.5 intactos. flutter analyze passando. flutter test passando (177/177). Commit 33fb6c2. Aprovado no Samsung S24 Ultra.
Fase GFX-U1.1 aprovada: tela dedicada de GFX Profile validada no Samsung S24 Ultra. Cards selecionáveis para Equilibrado, Desempenho, Qualidade, Economia e Nenhum. Seleção persiste por jogo. Retorno ao Detalhe do Jogo atualiza valor exibido. Bottom sheet legado removido. flutter analyze passando. flutter test passando (177/177). Commits: feat: adicionar tela dedicada de perfil gfx + ux: destacar perfil gfx como acao no detalhe.
Fase GFX-U1.1A aprovada: acesso ao GFX Profile no Detalhe do Jogo com peso visual de card/botão premium. Aprovado pelo usuário no Samsung S24 Ultra. flutter analyze passando. flutter test passando (177/177).
Fase GFX-U2.A+B aprovada: GFX Profile influenciando a jornada local de preparação. PrepararTab exibe perfil com cor/semântica real. Apex Scan local usa mensagem contextual por perfil — score e status preservados. Sem promessa falsa. Nenhum Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando (190/190). Aprovado no Samsung S24 Ultra.
Fase GFX-U2.C aprovada: Histórico exibe chip de Perfil GFX por sessão. Chip usa GfxProfile.fromLabel com cor e label semântico por perfil (Desempenho → verde, Equilibrado → azul, Qualidade → laranja, Economia → cinza). Fallback seguro para nulos e desconhecidos. Sessões sem perfil não exibem chip. Nenhum Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando (190/190). Aprovado no Samsung S24 Ultra.
Fase GFX-U2.D aprovada: InicioTab exibe chip de Perfil GFX semântico da última sessão. Chip usa GfxProfile.fromLabel com cor e label semântico por perfil. Fallback seguro para nulos, vazios e desconhecidos. Sessões sem perfil não exibem chip. Chips de RAM e latência preservados. _loadData, cache de ícone e navegação intactos. Nenhum Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando (190/190). Aprovado no Samsung S24 Ultra.
Fase GFX-U2 aprovada end-to-end no Samsung S24 Ultra: ciclo completo validado fisicamente — Detalhe do Jogo → GFX Profile → Preparar → Apex Scan → Abrir Jogo → Histórico → Início. Todos os perfis validados (Desempenho, Qualidade, Economia, Equilibrado, Nenhum). Perfil "Nenhum" não gera chip falso em nenhuma tela. Sessões antigas preservam perfil original. Sem crash, sem tela vermelha, sem overflow, sem engasgos. flutter analyze passando. flutter test passando (190/190). GFX-U2 marcada como concluída end-to-end.
Fase GFX-U2.E.1 aprovada: recomendações locais por Perfil GFX implementadas na PrepararTab e validadas no Samsung S24 Ultra. Seção "Sugestões" exibida por perfil. Perfil "Nenhum" não exibe seção. Refresh correto ao retornar da GfxProfileScreen. Score/status do Apex Scan e CTA preservados. Sem nova permissão, dependência ou chamada de MethodChannel. flutter analyze passando. flutter test passando (226/226). Commit 3fc4a7a.
Fase SET-U1.1 aprovada: ação "Limpar histórico de sessões" implementada na ConfiguraçõesTab e validada no Samsung S24 Ultra. Diálogo de confirmação funcional. CANCELAR preserva sessões. LIMPAR apaga apenas apex_sessions. Biblioteca, jogos, perfis GFX e demais dados intactos. HistoricoTab exibe estado vazio imediatamente após limpeza. InicioTab não mantém última sessão antiga. Sem nova permissão, dependência, Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando (233/233). Commit 6fc286f. Fecha a primeira configuração real mínima do app.
Fase SET-U1.2 aprovada: card "Sobre" implementado na ConfiguraçõesTab e validado no Samsung S24 Ultra. Exibe nome do app, versão 1.0.0, tagline, modelo comercial e disclaimer. Placeholder APP removido. CTA morta removida. Sem package_info_plus. Sem nova permissão, dependência, Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando (239/239). Commit 5a614b7.
Fase SET-U1.3 aprovada: placeholders restantes removidos da ConfiguraçõesTab e validado no Samsung S24 Ultra. Card "Preferências em preparação" e card "Idioma do app" removidos. Import órfão de apex_feature_card.dart removido. Aba exibe apenas Modo Foco Gamer, Limpar histórico e Sobre — todos funcionais. Sem nova permissão, dependência, Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando (241/241). Commit ad75f54.
Fase LANG-U1.1 concluída: infraestrutura de idioma criada. Enum AppLanguage (ptBr, en, es) com code, label, nativeLabel e fromName/fallback seguro. languageNotifier global. LanguageService com persistência via shared_preferences (chave apex_app_language). AppStrings com getters e métodos iniciais. main.dart carrega idioma salvo antes do runApp. ApexBoosterApp usa ListenableBuilder. Nenhuma tela migrada. Sem impacto visual nesta fase. Sem nova dependência, Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando (316/316). Commit a5d9310.
Fase LANG-U1.2 concluída: card "Idioma do app" real na ConfiguraçõesTab. Exibe idioma atual. Seletor bottom sheet com PT-BR, English e Español. Opção atual marcada. Seleção salva via LanguageService. languageNotifier atualiza UI imediatamente. Idioma persiste ao fechar e reabrir o app. BottomNav e ConfiguraçõesTab migradas para AppStrings — mudam sem reiniciar o app. Sem flutter_localizations, intl ou nova dependência. Nenhum Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando com baseline atual. Commit 4ad1c0f. Aprovado no Samsung S24 Ultra.
Fase LANG-U1.2A concluída: ajuste visual do seletor de idioma. Opção "Español" não fica cortada na borda inferior. Respiro inferior adequado no bottom sheet. Lógica de idioma preservada. Nenhum Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando. Commit 10f9559. Aprovado no Samsung S24 Ultra.
Fase LANG-U1.3A concluída: InicioTab, HistoricoTab e SplashScreen migradas para AppStrings. Chip de memória do Histórico corrigido com variante por idioma (PT-BR: GB livre · normal, EN: GB free · stable, ES: GB libres · estable). Validado em English, Español e Português (BR) no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo. Nenhum Kotlin, AndroidManifest ou pubspec alterado. flutter analyze passando. flutter test passando (361/361). Commit f6bfa02.
Fase LANG-U1.3B concluída: Welcome, HowItWorks e Permissions migradas para AppStrings. Textos do onboarding traduzidos para PT-BR, English e Español. Tagline consistente por idioma. Splash nativa Android não alterada. Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma dependência nova. flutter analyze passando. flutter test passando (397/397). Commit a0308a1. Aprovado no Samsung S24 Ultra em Português, English e Español. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo.
Fase LANG-U1.4A concluída: GfxProfileScreen migrada para AppStrings/languageNotifier. Título, prefixo "Atual/Current/Actual", nomes dos perfis, descrições e disclaimer traduzidos para PT-BR, English e Español. Seleção de perfil, retorno ao Detalhe do Jogo e persistência em localProfileName preservados. PrepararTab, BibliotecaTab e GameDetailScreen não alteradas. Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma dependência nova. flutter analyze passando. flutter test passando (417/417). Commit b4a1d2e. Aprovado no Samsung S24 Ultra em Português (BR), English e Español. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo.
Ainda não é o visual final absoluto do produto.

Observação:

A Biblioteca funciona com adição via BottomSheet com autocomplete inteligente (sugestões desde a primeira letra, ranking por relevância, lista rolável), validação de packageName manual contra apps instalados, bloqueio de jogos fantasmas, bloqueio de duplicados com mensagem "Já instalado", favoritar, remover, persistência entre sessões, navegação para detalhe, edição de nome e packageName com validação completa no detalhe (packageName inválido bloqueado, duplicado em outro jogo bloqueado, vazio permitido com fallback de ícone, igual ao jogo atual permitido), seleção de GFX Profile local, seleção restrita de apps instalados via AppPickerSheet (intent MAIN/LAUNCHER), e exibição de ícone real do app via AppIconWidget quando packageName disponível. Entrada manual permanece como fallback. Ícone não é persistido em disco — cache em memória por sessão. Contagem exibe "na biblioteca". Empty state honesto. Launcher real implementado na GameDetailScreen: botão ABRIR JOGO abre o app pelo packageName via Intent Android, precedido por sequência visual honesta Apex Boost Mode. Tratamento de erro presente se app não puder ser aberto. Apex Scan visual implementado na GameDetailScreen: card premium/gamer com animação, glow sutil, checks de status local e indicadores visuais. Status exibido: "Pronto para iniciar", "Cadastro incompleto" ou "App não encontrado". Motor local ApexScanService utilizado sem alteração. Seção "MÉTRICAS REAIS" implementada na GameDetailScreen (Fase 2-O.3): exibe memória disponível, memória total, estado de memória e latência Apex lidos do dispositivo real, com tratamento seguro de loading, erro, timeout e sem rede. Disclaimer exibido: "Snapshot do dispositivo. Não representa alteração de jogos." FPS real e GPU real não implementados. Classificação gamer implementada (Fase 2-R): AppPickerSheet exibe badge "JOGO" para apps com isGame == true, com toggle "Apenas jogos verificados" (inicia desligado). Confirmação obrigatória ao adicionar app com isGame == false — usuário pode cancelar ou adicionar mesmo assim. Badge "Não verificado" exibido nos cards da Biblioteca para apps com packageName definido e isGame == false. Nenhum app bloqueado permanentemente. ABRIR JOGO não restrito por isGame.

Pendências conhecidas:

- Logo/asset oficial interno ainda não foi aprovado para uso definitivo nas telas Flutter.
- Localização multilíngue: infraestrutura criada (Fase LANG-U1.1). Card "Idioma do app" real + BottomNav + ConfiguraçõesTab migrados (Fase LANG-U1.2). Seletor visual ajustado (Fase LANG-U1.2A). InicioTab + HistoricoTab + SplashScreen migradas (Fase LANG-U1.3A). Welcome + HowItWorks + Permissions migradas (Fase LANG-U1.3B). GfxProfileScreen migrada (Fase LANG-U1.4A). Migração das telas restantes pendente: LANG-U1.4B (PrepararTab), LANG-U1.5 (Biblioteca + Detalhe do Jogo), LANG-U1.6 (validação final PT-BR / EN / ES).
- Tela Add Game separada não implementada (adição atual é diálogo inline na BibliotecaTab).
- GFX Profile: tela dedicada GfxProfileScreen criada (Fase GFX-U1.1) com Equilibrado, Desempenho, Qualidade, Economia e Nenhum. Acesso no Detalhe do Jogo com visual premium (Fase GFX-U1.1A). Influência na jornada — PrepararTab e Apex Scan local: implementada (Fase GFX-U2.A+B). Influência no Histórico: implementada (Fase GFX-U2.C — chip GFX nos cards do Histórico). Influência na InicioTab: implementada (Fase GFX-U2.D — chip GFX semântico no card de última sessão). Recomendações locais baseadas em perfil: implementadas (Fase GFX-U2.E.1 — seção "Sugestões" no _PrepScanCard da PrepararTab). Perfis avançados não implementados (futuros: Fluidez, Competitivo, Ultra Visual, Personalizado). Recomendações mais granulares por perfil avançado: pendente (futuro).
- Apex Scan: motor local criado (Fase 2M.2). Card visual implementado no Detalhe do Jogo (Fase 2M.4A). Métricas reais parciais implementadas (Fase 2-O.3): RAM disponível, RAM total, estado de memória e latência Apex. PrepararTab possui _PrepScanCard com checks locais honestos (app vinculado, GFX, prioridade) — não usa ApexScanService diretamente. Integração da aba Preparar com ApexScanService completo: pendente (Fase 2M.4B adiada). FPS real, GPU real, limpeza de RAM, boost real e otimização real não implementados.
- Boost Engine não implementado.
- Histórico real: captura, exibição local e revisão visual premium implementadas (Fases 2-Q.1 a 2-Q.7). HistoricoTab exibe sessões reais via SessionRecord e SharedPreferencesSessionRepository com visual premium aprovado. Sem duração real. Sem Usage Stats. Sem Firebase. Apps não-game podem aparecer no histórico se forem lançados — comportamento esperado, o histórico registra o que foi aberto sem filtro retroativo.
- Configurações: Limpar histórico de sessões implementado (Fase SET-U1.1). Card Sobre implementado (Fase SET-U1.2 — nome, versão 1.0.0, tagline, modelo comercial, disclaimer). Placeholders removidos (Fase SET-U1.3). Infraestrutura de idioma criada (Fase LANG-U1.1). Card "Idioma do app" real + migração de BottomNav e ConfiguraçõesTab para AppStrings implementados (Fase LANG-U1.2 — seletor bottom sheet, persistência, troca sem reinicialização). Seletor ajustado visualmente (Fase LANG-U1.2A — respiro inferior). Migração das telas restantes: LANG-U1.3A concluída (InicioTab + HistoricoTab + SplashScreen). Pendente: LANG-U1.3B (Welcome + HowItWorks + Permissions), LANG-U1.4 e seguintes. Demais configurações reais pendentes (outras a definir).
- Hive não implementado (shared_preferences cobre a necessidade atual).
- Billing não implementado.
- Firebase não implementado.
- Overlay gamer não implementado.
- Modo Foco Gamer: UI de permissão implementada (Fase 2-P.4). Integração ao ABRIR JOGO implementada (Fase 2-P.6). Revisão end-to-end aprovada (Fase 2-P.8). Persistência segura do estado DND se o processo Android morrer: pendente. Ajustes avançados de lifecycle: pendente.
- Usage Stats não implementado.

---

## 15. PRÓXIMO PASSO OFICIAL

Fases 2A, 2B, 2C, 2D.1, 2D.3, 2E.1, 2F.2, 2G.2, 2H.2, 2I.2, 2J.2, 2K.2, 2L.1, 2L.2, 2M.1, 2M.2, 2M.4A, 2N, 2-O.1, 2-O.2, 2-O.3, 2-O.5, 2-O.6, 2-P.2, 2-P.3, 2-P.4, 2-P.6, 2-P.8, 2-Q.1, 2-Q.2, 2-Q.3, 2-Q.4, 2-Q.5, 2-Q.6, 2-Q.7, 2-R.1, 2-R.2, 2-R.3, 2-R.4, 2-R.5, PERF-G1.5, 2-S.4, 2-S.5, 2-T.1, 2-T.2A, GFX-U1.1, GFX-U1.1A, GFX-U2.A+B, GFX-U2.C, GFX-U2.D, GFX-U2.E.1, SET-U1.1, SET-U1.2, SET-U1.3, LANG-U1.1, LANG-U1.2, LANG-U1.2A, LANG-U1.3A, LANG-U1.3B e LANG-U1.4A concluídas.

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

Fase 2-Q — Histórico Real / Sessões (concluída):
- Fase 2-Q.1: domínio SessionRecord criado.
- Fase 2-Q.2: repositório local de histórico criado (SharedPreferencesSessionRepository).
- Fase 2-Q.3: integração ao launcher implementada (sessão registrada ao abrir jogo).
- Fase 2-Q.4: validação no celular físico concluída.
- Fase 2-Q.5: HistoricoTab exibe histórico real de sessões.
  - HistoricoTab conectada ao SharedPreferencesSessionRepository.
  - Exibe SessionRecord salvas localmente.
  - Estado vazio honesto. Status sem termos falsos (sem duração, sem tempo jogado).
  - Apps não-game podem aparecer se abertos por packageName válido (lacuna de curadoria).
- Fase 2-Q.6: CLAUDE.md atualizado para refletir Fase 2-Q.5 e setup auxiliar de skills.
- Fase 2-Q.7: revisão visual premium da HistoricoTab concluída.
  - Header refinado com identidade gamer premium.
  - Cards de sessão refinados com hierarquia clara.
  - Status success / attempted / failed mais legíveis e distintos visualmente.
  - Métricas opcionais como chips. RAM humanizada em MB.
  - Copy honesta preservada: sem duração real, sem tempo jogado, sem "partida concluída".
  - Sem novas permissões. Sem Firebase. Sem Usage Stats.
  - flutter analyze passando. flutter test passando (139/139).
  - Aprovado no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow.

Fase 2-R — Classificação/Curadoria Gamer de Apps (concluída):
- Fase 2-R.1: InstalledApp.isGame adicionado ao data layer (leitura de categoria Android via FLAG_IS_GAME + categoria GAME).
- Fase 2-R.2: badge "JOGO" e toggle "Apenas jogos verificados" no AppPickerSheet.
  - Badge verde para isGame == true. Toggle inicia desligado. Estado vazio honesto.
  - Função pura applyPickerFilter criada e testada.
- Fase 2-R.3: confirmação obrigatória ao adicionar app com isGame == false.
  - Cancelar não adiciona. Adicionar mesmo assim adiciona. Nenhum app bloqueado permanentemente.
- Fase 2-R.4: badge "Não verificado" nos cards da Biblioteca para packageName com isGame == false.
  - Jogos verificados e apps sem packageName não exibem badge.
  - flutter analyze passando. flutter test passando (167/167).
  - Aprovado no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow.
- Fase 2-R.5: revisão end-to-end aprovada no Samsung S24 Ultra + CLAUDE.md atualizado.
  - AppPickerSheet: badge JOGO, toggle, filtro e estado vazio validados.
  - Fluxo de adição: confirmação de não-game e adição direta de jogo validados.
  - Biblioteca: badge Não verificado presente em não-game, ausente em verificados e sem packageName.
  - ABRIR JOGO: funcional e sem restrição por isGame.
  - Sem tela vermelha. Sem overflow. Sem travamento.
  - flutter analyze passando. flutter test passando (167/167).

Fase PERF-G1.5 — Lazy Load de Apps Instalados (concluída):
- getInstalledApps removido do cold start da HomeScreen.
- BibliotecaTab carrega apps sob demanda: ao ativar a aba ou abrir fluxo adicionar/escolher app.
- Passagem entre telas mais fluida, sem engasgos.
- Commit: b5bca87. flutter analyze passando. flutter test passando (177/177).
- Aprovado no Samsung S24 Ultra.

Tentativa UI-G1.5 — Redesign Visual da BibliotecaTab (rejeitada e revertida):
- Proposta de redesign visual pesado reprovada no celular físico.
- Quebrou cards e botões visualmente.
- Revertida com git restore para o estado do commit b5bca87.
- Decisão: BibliotecaTab mantida como está. Não insistir em redesign visual pesado.
- Qualquer ajuste futuro na BibliotecaTab deve ser mínimo, pontual e somente se explicitamente solicitado pelo usuário.

Fase 2-S — PrepararTab funcional (concluída):
- Fase 2-S.4: PrepararTab — snapshot do dispositivo + CTA final.
  - Seletor de jogo com botão TROCAR (visível quando há mais de 1 jogo).
  - Pré-seleção por histórico: último jogo lançado → primeiro da biblioteca → null (empty state honesto).
  - Apex Scan local (_PrepScanCard): checks honestos de app vinculado, perfil GFX e prioridade. Não usa ApexScanService diretamente.
  - Snapshot real do dispositivo (_DeviceSnapshotCard): RAM disponível, RAM total, estado de memória, latência Apex, Modo Foco.
  - CTA "CONTINUAR PARA DETALHES" com disable state correto quando sem jogo.
  - Dois disclaimers honestos visíveis.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (177/177).
- Fase 2-S.5: validação end-to-end da jornada principal no Samsung S24 Ultra.
  - Resultado reportado pelo usuário: "Tudo certo, tudo fluido." — aprovado.
  - Jornada validada: abertura do app → Home → Biblioteca → Preparar → Detalhe do Jogo → ABRIR JOGO → retorno → Histórico → troca de abas.
  - Sem crash. Sem tela vermelha. Sem overflow relevante. Sem engasgos relevantes.
  - Biblioteca preservada visualmente. Lazy load aprovado. PrepararTab aprovada. Home fluida.
  - Produto com jornada principal funcional e validada end-to-end.
  - Nenhum arquivo Dart, Kotlin, AndroidManifest ou pubspec alterado.

Fase 2-T — InicioTab funcional (concluída):
- Fase 2-T.1: InicioTab refresh on tab focus.
  - Contagem de jogos atualiza ao retornar para a aba Início após mudanças na Biblioteca.
  - Contagem de sessões e dados da última sessão atualizam após uso do fluxo principal.
  - Pré-seleção por histórico preservada: dados refletem estado real sem reinicialização desnecessária.
  - Sem novo atraso perceptível ao trocar de aba.
  - BibliotecaTab e lazy load da PERF-G1.5 preservados intactos.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando com baseline atual.
  - Aprovado no Samsung S24 Ultra.
- Fase 2-T.2A: InicioTab — chips de métricas reais na última sessão.
  - Chips de métricas reais exibidos no card de última sessão.
  - Dados reais apenas (SessionRecord existente): sem nova query, sem novo MethodChannel, sem getInstalledApps.
  - Nenhum dado inventado ou simulado.
  - Cache de ícone aprovado preservado. Layout estrutural da InicioTab preservado.
  - BibliotecaTab e lazy load da PERF-G1.5 preservados intactos.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (177/177).
  - Commit: 33fb6c2 — ux: exibir metricas reais na ultima sessao da inicio.
  - Aprovado no Samsung S24 Ultra.

Fase GFX-U — GFX Profile Expandido (GFX-U2 concluída end-to-end):
- Fase GFX-U1.1: tela dedicada de GFX Profile criada e aprovada no Samsung S24 Ultra.
  - GfxProfileScreen com cards selecionáveis (Equilibrado, Desempenho, Qualidade, Economia, Nenhum).
  - Seleção persiste por jogo via localProfileName.
  - Retorno ao Detalhe do Jogo atualiza valor exibido.
  - Bottom sheet legado removido (código morto).
  - flutter analyze passando. flutter test passando (177/177).
- Fase GFX-U1.1A: acesso ao GFX Profile no Detalhe do Jogo com visual premium aprovado.
  - Item Perfil GFX deixou de parecer linha secundária.
  - Visual de card/botão premium aprovado no Samsung S24 Ultra.
  - flutter analyze passando. flutter test passando (177/177).
- Fase GFX-U2.A+B concluída: GFX Profile influenciando PrepararTab e Apex Scan local.
  - Fase GFX-U2.A: PrepararTab exibe Perfil GFX com cor e semântica por perfil selecionado.
    - Cor e label vinculados ao localProfileName real do jogo (sem dado inventado).
    - Sem promessa de FPS, GPU, resolução, textura ou gráficos internos de jogos terceiros.
  - Fase GFX-U2.B: Apex Scan local (_PrepScanCard) usa mensagem contextual por perfil.
    - Check de Perfil GFX exibe mensagem específica ao perfil ativo.
    - Score e status do Apex Scan preservados sem alteração.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (190/190).
  - Aprovado no Samsung S24 Ultra.
- Fase GFX-U2.C concluída: Histórico exibindo o Perfil GFX usado na sessão.
  - Chip "GFX: [Perfil]" exibido nos cards da HistoricoTab quando session.gfxProfile está presente.
  - Chip usa GfxProfile.fromLabel(session.gfxProfile): cor e label semânticos por perfil.
  - Desempenho → verde; Equilibrado → azul; Qualidade → laranja; Economia → cinza.
  - Fallback seguro para nulos e valores desconhecidos. Sessões sem perfil não exibem chip.
  - Nenhum arquivo Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (190/190).
  - Aprovado no Samsung S24 Ultra.
- Fase GFX-U2.D concluída: InicioTab exibindo Perfil GFX semântico da última sessão.
  - Chip "GFX: [Perfil]" exibido no card de última sessão da InicioTab quando session.gfxProfile está presente.
  - Chip usa GfxProfile.fromLabel(session.gfxProfile): cor e label semânticos por perfil.
  - Perfil nulo, vazio ou desconhecido não exibe chip — fallback seguro.
  - Chips de RAM e latência preservados visualmente.
  - _loadData, cache de ícone e navegação permaneceram intactos.
  - BibliotecaTab, PrepararTab, HistoricoTab, GameDetailScreen, GfxProfileScreen, ApexScanService, SessionRecord, repositories, services, Kotlin, AndroidManifest e pubspec não alterados.
  - flutter analyze passando. flutter test passando (190/190).
  - Aprovado no Samsung S24 Ultra.
- Fase GFX-U2 — validação end-to-end física concluída no Samsung S24 Ultra.
  - Ciclo completo validado: Detalhe do Jogo → GFX Profile → Preparar → Apex Scan → Abrir Jogo → Histórico → Início.
  - Todos os perfis validados fisicamente: Desempenho, Qualidade, Economia, Equilibrado e Nenhum.
  - Detalhe do Jogo: perfil selecionado exibido corretamente para cada perfil.
  - PrepararTab: cor, label e mensagem contextual corretos por perfil.
  - Apex Scan local: contextualiza o perfil sem alterar score nem status.
  - Abrir Jogo: registra sessão normalmente independente do perfil ativo.
  - Histórico: chip GFX exibido com perfil correto para cada sessão registrada.
  - Início: chip GFX da última sessão exibido com semântica correta.
  - Perfil "Nenhum": não gera chip falso, "GFX: null" ou chip vazio em nenhuma tela.
  - Sessões antigas: preservam o perfil registrado no momento da abertura.
  - Sem crash. Sem tela vermelha. Sem overflow relevante. Sem engasgos relevantes.
  - flutter analyze passando. flutter test passando (190/190).
  - GFX-U2 marcada como concluída end-to-end.
- Fase GFX-U2.E.1 concluída: recomendações locais por Perfil GFX na PrepararTab.
  - Seção "Sugestões" exibida no _PrepScanCard quando há Perfil GFX selecionado.
  - Sugestões locais, baseadas no perfil — sem promessa de FPS, GPU, resolução ou alteração real.
  - Perfil "Nenhum" não exibe seção de sugestões.
  - Refresh correto ao mudar perfil no Detalhe/GfxProfile e retornar à PrepararTab.
  - Score/status do Apex Scan e CTA preservados.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão ou dependência.
  - flutter analyze passando. flutter test passando (226/226).
  - Commit: 3fc4a7a — feat: adicionar recomendacoes gfx na preparacao.
  - Aprovado no Samsung S24 Ultra. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo relevante.
- Fases futuras GFX-U: perfis avançados (Fluidez, Competitivo, Ultra Visual, Personalizado) e recomendações mais granulares — pendentes, aguardam aprovação de escopo.

Fase SET-U — Configurações reais mínimas:
- Fase SET-U1.1: Limpar histórico de sessões (concluída).
  - Ação real adicionada à ConfiguraçõesTab com diálogo de confirmação.
  - CANCELAR preserva sessões. LIMPAR apaga apenas apex_sessions.
  - Biblioteca, jogos, perfis GFX, modo foco e demais dados intactos.
  - SharedPreferencesSessionRepository.clearAll() utilizado.
  - HistoricoTab: refresh imediato ao ganhar foco via isActive.
  - HomeScreen: isActive passado corretamente para HistoricoTab.
  - InicioTab: não mantém última sessão antiga após limpeza.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão ou dependência.
  - flutter analyze passando. flutter test passando (233/233).
  - Commit: 6fc286f. Aprovado no Samsung S24 Ultra.
  - Fecha a primeira configuração real mínima do app.
- Fase SET-U1.2: Sobre / versão do app (concluída).
  - Card "Sobre" adicionado à ConfiguraçõesTab.
  - Exibe nome do app: Apex Booster+.
  - Exibe versão: 1.0.0 (valor fixo, sem package_info_plus).
  - Exibe tagline: "Prepare. Analise. Jogue."
  - Exibe modelo comercial: "Instalação gratuita · Desbloqueio único".
  - Exibe disclaimer: "Não altera jogos de terceiros automaticamente."
  - Placeholder APP removido. CTA morta "ABRIR AJUSTES" removida.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão ou dependência.
  - flutter analyze passando. flutter test passando (239/239).
  - Commit: 5a614b7 — feat: adicionar sobre do app nas configuracoes.
  - Aprovado no Samsung S24 Ultra.
- Fase SET-U1.3: Limpeza dos placeholders restantes (concluída).
  - Card "Preferências em preparação" removido da ConfiguraçõesTab.
  - Card "Idioma do app" placeholder removido.
  - Import órfão de apex_feature_card.dart removido.
  - Aba exibe apenas itens reais: Modo Foco Gamer, Limpar histórico, Sobre.
  - Observação estratégica: idioma retorna futuramente como LANG-U1 — funcionalidade real, não placeholder.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão ou dependência.
  - flutter analyze passando. flutter test passando (241/241).
  - Commit: ad75f54 — ux: remover placeholders das configuracoes.
  - Aprovado no Samsung S24 Ultra.

Fase LANG-U — Idioma real:
- Fase LANG-U1.1: infraestrutura de idioma criada (concluída).
  - Enum AppLanguage (ptBr, en, es) com code, label, nativeLabel e fromName/fallback seguro.
  - languageNotifier global para rebuild da UI ao trocar idioma.
  - LanguageService com persistência via shared_preferences (chave: apex_app_language).
  - AppStrings com getters e métodos iniciais para as telas principais.
  - main.dart carrega idioma salvo antes do runApp. ApexBoosterApp usa ListenableBuilder.
  - Nenhuma tela migrada. Nenhum card de idioma adicionado. Nenhuma nova dependência.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando (316/316).
  - Commit: a5d9310 — feat: adicionar infraestrutura de idioma.
- Fase LANG-U1.2: seletor de idioma real nas Configurações + migração de BottomNav e ConfiguraçõesTab (concluída).
  - Card "Idioma do app" real adicionado à ConfiguraçõesTab.
  - Card exibe idioma atual. Ao tocar, abre seletor bottom sheet com Português (BR), English e Español.
  - Opção atual marcada. Seleção salva via LanguageService. languageNotifier atualiza UI imediatamente.
  - Idioma persiste ao fechar e reabrir o app.
  - BottomNav migrada para AppStrings. ConfiguraçõesTab migrada para AppStrings.
  - Troca de idioma sem reinicialização do app.
  - Sem flutter_localizations, intl ou nova dependência.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando com baseline atual.
  - Commit: 4ad1c0f — feat: adicionar seletor de idioma nas configuracoes.
  - Aprovado no Samsung S24 Ultra.
- Fase LANG-U1.2A: ajuste visual do seletor de idioma (concluída).
  - Opção "Español" deixou de ficar cortada ou colada na borda inferior.
  - Bottom sheet com respiro inferior adequado.
  - Lógica de idioma, persistência e atualização imediata preservadas sem alteração.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão.
  - flutter analyze passando. flutter test passando com baseline atual.
  - Commit: 10f9559 — ux: ajustar seletor de idioma nas configuracoes.
  - Aprovado no Samsung S24 Ultra.
- Fase LANG-U1.3A: InicioTab + HistoricoTab + SplashScreen migradas (concluída).
  - InicioTab migrada para AppStrings/languageNotifier.
  - HistoricoTab migrada para AppStrings/languageNotifier.
  - SplashScreen Flutter passa a usar tagline via AppStrings.
  - Splash nativa Android não alterada. Onboarding (Welcome, HowItWorks, Permissions) não alterado.
  - AppStrings recebeu getters/métodos para Início, Histórico, Splash e tempo relativo centralizado.
  - Chip de memória do Histórico corrigido com variante por idioma:
    PT-BR: "GB livre · normal" / EN: "GB free · stable" / ES: "GB libres · estable"
  - Chip GFX no Histórico e na Início permanece traduzido conforme perfil.
  - Nenhum Kotlin, AndroidManifest ou pubspec alterado. Nenhuma nova permissão ou dependência.
  - flutter analyze passando. flutter test passando (361/361).
  - Commit: f6bfa02 — feat: traduzir inicio historico e splash.
  - Aprovado no Samsung S24 Ultra em English, Español e Português (BR). Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo.
- Fase LANG-U1.3B concluída: Welcome + HowItWorks + Permissions migradas para AppStrings.
  - WelcomeScreen migrada para AppStrings/languageNotifier.
  - HowItWorksScreen migrada para AppStrings/languageNotifier.
  - PermissionsScreen migrada para AppStrings/languageNotifier.
  - Textos do onboarding traduzidos para PT-BR, English e Español.
  - Tagline consistente por idioma: PT-BR "Prepare. Analise. Jogue." / EN "Prepare. Scan. Play." / ES "Prepara. Analiza. Juega."
  - Splash nativa Android não alterada.
  - InicioTab, HistoricoTab e SplashScreen Flutter não alteradas.
  - ConfiguracoesTab, HomeScreen, BibliotecaTab, PrepararTab, GameDetailScreen e GfxProfileScreen não alteradas.
  - ApexScanService, repositories, services, Kotlin, AndroidManifest e pubspec não alterados.
  - Nenhuma dependência nova adicionada.
  - flutter analyze passando. flutter test passando (397/397).
  - Commit: a0308a1 — feat: traduzir onboarding.
  - Aprovado no Samsung S24 Ultra em Português, English e Español. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo.
- Fase LANG-U1.4A concluída: GfxProfileScreen migrada para AppStrings (concluída).
  - GfxProfileScreen migrada para AppStrings/languageNotifier.
  - Título, prefixo "Atual/Current/Actual", nomes dos perfis, descrições e disclaimer migrados.
  - Tela Perfil GFX responde à troca de idioma sem reinicialização do app.
  - Seleção de perfil, retorno ao Detalhe do Jogo e persistência em localProfileName preservados.
  - Layout, ícones, cores, destaque do perfil selecionado e SingleChildScrollView preservados.
  - PrepararTab, BibliotecaTab, GameDetailScreen e demais telas não alteradas.
  - ApexScanService, repositories, services, Kotlin, AndroidManifest e pubspec não alterados.
  - Nenhuma dependência nova adicionada.
  - flutter analyze passando. flutter test passando (417/417).
  - Commit: b4a1d2e — feat: traduzir tela de perfil gfx.
  - Aprovado no Samsung S24 Ultra em Português (BR), English e Español. Sem crash. Sem tela vermelha. Sem overflow. Sem atraso novo.
- Fases LANG-U1.4B a LANG-U1.6: pendentes, aguardam aprovação de escopo.
  - LANG-U1.4B: PrepararTab.
  - LANG-U1.5: Biblioteca + Detalhe do Jogo.
  - LANG-U1.6: validação final PT-BR / EN / ES.

Próximo passo imediato:
- LANG-U1.4A concluída: GfxProfileScreen migrada para AppStrings e validada no Samsung S24 Ultra em PT-BR, EN e ES. flutter test passando (417/417). Commit b4a1d2e.
- Próxima fase sugerida: LANG-U1.4B — migrar PrepararTab para AppStrings.
  - Cobertura crescente: cada fase migra um bloco de telas sem quebrar as anteriores.
  - Sem nova dependência (AppStrings e languageNotifier já disponíveis).
  - Candidatos alternativos: refinamento visual, Boost Engine (Fase 3), ou outro a definir.

Nota estratégica:
- Fase 2M.4B (integração do ApexScanService completo na aba Preparar): continua adiada. PrepararTab já tem _PrepScanCard com checks locais — integração com ApexScanService é refinamento futuro, não bloqueador.
- BibliotecaTab visual: congelada. Não alterar sem solicitação explícita.

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
- avançar para Fase 3 sem Fase 2 funcional aprovada;
- implementar classificação automática de categoria de app (game detection) sem aprovação explícita.

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

Perfis implementados (Fases 2E.1 e GFX-U1.1):

- Equilibrado
- Desempenho
- Qualidade
- Economia
- Nenhum (remoção do perfil — ausência de localProfileName)

Seleção via GfxProfileScreen (tela dedicada criada na Fase GFX-U1.1).
Bottom sheet legado removido na Fase GFX-U1.1 (código morto).
Acesso no Detalhe do Jogo com visual de card/botão premium (Fase GFX-U1.1A).
Influência na jornada implementada (Fases GFX-U2.A+B, GFX-U2.C e GFX-U2.D):
- PrepararTab exibe o perfil com cor e semântica por tipo (GFX-U2.A).
- Apex Scan local usa mensagem contextual por perfil — score e status preservados (GFX-U2.B).
- Histórico: implementado (Fase GFX-U2.C — chip GFX nos cards do Histórico).
- InicioTab: implementado (Fase GFX-U2.D — chip GFX semântico no card de última sessão).
- Recomendações locais: implementadas (Fase GFX-U2.E.1 — seção "Sugestões" no _PrepScanCard da PrepararTab).

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
- PrepararTab possui _PrepScanCard com checks locais (app vinculado, GFX, prioridade) — não usa ApexScanService. Integração com ApexScanService completo na aba Preparar: pendente (Fase 2M.4B adiada).
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

---

## 30. SKILLS AUXILIARES DE DESENVOLVIMENTO

O projeto utiliza dois sistemas auxiliares de metodologia e design, além do CLAUDE.md como fonte soberana.

CLAUDE.md — Fonte soberana:

Este arquivo é o contrato técnico, visual e estratégico do projeto.
Em caso de conflito entre skills, conversa ou suposição, o CLAUDE.md vence.

Superpowers — Metodologia de desenvolvimento:

Plugin global instalado no Claude Code.
Responsável por:
- metodologia de trabalho (fluxo de sessão, planejamento);
- TDD (test-driven development);
- revisão de código;
- debugging sistemático;
- brainstorming de features;
- execução de planos.

UI/UX Pro Max — Design e experiência:

Skill instalada localmente no projeto (.claude/skills/ui-ux-pro-max).
Responsável por:
- UX/UI gamer premium;
- hierarquia visual;
- layout e tipografia;
- padrão de componentes;
- revisão de telas antes da validação no celular físico.

Regra de uso:

As skills são ferramentas auxiliares que apoiam a execução.
Não substituem o CLAUDE.md.
Não alteram regras do produto.
Não liberam implementações proibidas.
Não autorizam features novas.

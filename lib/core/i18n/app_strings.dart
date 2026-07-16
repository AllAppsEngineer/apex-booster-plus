import 'package:apex_booster_plus/domain/entities/apex_scan_result.dart';
import 'package:apex_booster_plus/domain/entities/gfx_profile.dart';
import 'app_language.dart';

/// All user-facing strings for the active language.
///
/// Usage (in any widget):
///   final s = AppStrings(languageNotifier.value);
///   Text(s.settingsTitle)
///
/// Dynamic strings (with parameters) are methods:
///   Text(s.gameCountStat(3))
///
/// Strings are organised by screen/section matching the LANG-U1 microfases:
///   - App-level, Shared actions, Status chips
///   - Navigation (LANG-U1.2)
///   - Language selection (LANG-U1.2)
///   - Settings / Configurações (LANG-U1.2)
///   - Home / Início (LANG-U1.3)
///   - History / Histórico (LANG-U1.3)
///   - Prepare / Preparar (LANG-U1.4)
///   - GFX Profile (LANG-U1.4)
///   - Library / Biblioteca (LANG-U1.5)
///   - Game Detail (LANG-U1.5)
class AppStrings {
  final AppLanguage lang;

  const AppStrings(this.lang);

  // ─── App-level ───────────────────────────────────────────────────────────────

  /// Brand name — intentionally not translated.
  String get appName => 'Apex Booster+';

  String get appTagline => switch (lang) {
    AppLanguage.ptBr => 'Prepare. Analise. Jogue.',
    AppLanguage.en   => 'Prepare. Scan. Play.',
    AppLanguage.es   => 'Prepara. Analiza. Juega.',
  };

  String get appModel => switch (lang) {
    AppLanguage.ptBr => 'Instalação gratuita · Desbloqueio único',
    AppLanguage.en   => 'Free install · One-time unlock',
    AppLanguage.es   => 'Instalación gratuita · Desbloqueo único',
  };

  String get appDisclaimer => switch (lang) {
    AppLanguage.ptBr => 'Não altera jogos de terceiros automaticamente.',
    AppLanguage.en   => 'Does not alter third-party games automatically.',
    AppLanguage.es   => 'No altera juegos de terceros automáticamente.',
  };

  String get appVersion => switch (lang) {
    AppLanguage.ptBr => 'Versão 1.0.0',
    AppLanguage.en   => 'Version 1.0.0',
    AppLanguage.es   => 'Versión 1.0.0',
  };

  // ─── Shared actions ──────────────────────────────────────────────────────────

  String get actionCancel => switch (lang) {
    AppLanguage.ptBr => 'CANCELAR',
    AppLanguage.en   => 'CANCEL',
    AppLanguage.es   => 'CANCELAR',
  };

  String get actionBack => switch (lang) {
    AppLanguage.ptBr => 'Voltar',
    AppLanguage.en   => 'Back',
    AppLanguage.es   => 'Volver',
  };

  String get actionBackButton => switch (lang) {
    AppLanguage.ptBr => 'VOLTAR',
    AppLanguage.en   => 'BACK',
    AppLanguage.es   => 'VOLVER',
  };

  String get actionSave => switch (lang) {
    AppLanguage.ptBr => 'SALVAR',
    AppLanguage.en   => 'SAVE',
    AppLanguage.es   => 'GUARDAR',
  };

  String get actionAdd => switch (lang) {
    AppLanguage.ptBr => 'ADICIONAR',
    AppLanguage.en   => 'ADD',
    AppLanguage.es   => 'AGREGAR',
  };

  String get actionOpen => switch (lang) {
    AppLanguage.ptBr => 'ABRIR',
    AppLanguage.en   => 'OPEN',
    AppLanguage.es   => 'ABRIR',
  };

  String get actionConfirm => switch (lang) {
    AppLanguage.ptBr => 'CONFIRMAR',
    AppLanguage.en   => 'CONFIRM',
    AppLanguage.es   => 'CONFIRMAR',
  };

  String get actionEdit => switch (lang) {
    AppLanguage.ptBr => 'EDITAR',
    AppLanguage.en   => 'EDIT',
    AppLanguage.es   => 'EDITAR',
  };

  String get actionClose => switch (lang) {
    AppLanguage.ptBr => 'FECHAR',
    AppLanguage.en   => 'CLOSE',
    AppLanguage.es   => 'CERRAR',
  };

  // ─── Status chips ─────────────────────────────────────────────────────────────

  String get statusOpened => switch (lang) {
    AppLanguage.ptBr => 'aberto',
    AppLanguage.en   => 'opened',
    AppLanguage.es   => 'abierto',
  };

  String get statusFailed => switch (lang) {
    AppLanguage.ptBr => 'falhou',
    AppLanguage.en   => 'failed',
    AppLanguage.es   => 'falló',
  };

  String get statusAttempted => switch (lang) {
    AppLanguage.ptBr => 'tentado',
    AppLanguage.en   => 'attempted',
    AppLanguage.es   => 'intentado',
  };

  // ─── Navigation — LANG-U1.2 ──────────────────────────────────────────────────

  String get navHome => switch (lang) {
    AppLanguage.ptBr => 'Início',
    AppLanguage.en   => 'Home',
    AppLanguage.es   => 'Inicio',
  };

  String get navLibrary => switch (lang) {
    AppLanguage.ptBr => 'Biblioteca',
    AppLanguage.en   => 'Library',
    AppLanguage.es   => 'Biblioteca',
  };

  String get navPrepare => switch (lang) {
    AppLanguage.ptBr => 'Preparar',
    AppLanguage.en   => 'Prepare',
    AppLanguage.es   => 'Preparar',
  };

  String get navHistory => switch (lang) {
    AppLanguage.ptBr => 'Histórico',
    AppLanguage.en   => 'History',
    AppLanguage.es   => 'Historial',
  };

  String get navSettings => switch (lang) {
    AppLanguage.ptBr => 'Config.',
    AppLanguage.en   => 'Settings',
    AppLanguage.es   => 'Config.',
  };

  String get navSocial => switch (lang) {
    AppLanguage.ptBr => 'Studio',
    AppLanguage.en   => 'Studio',
    AppLanguage.es   => 'Studio',
  };

  String get navExitSnackBar => switch (lang) {
    AppLanguage.ptBr => 'Pressione voltar novamente para sair.',
    AppLanguage.en   => 'Press back again to exit.',
    AppLanguage.es   => 'Presiona atrás de nuevo para salir.',
  };

  // ─── Language selection — LANG-U1.2 ──────────────────────────────────────────

  String get languageBadge => switch (lang) {
    AppLanguage.ptBr => 'IDIOMA',
    AppLanguage.en   => 'LANGUAGE',
    AppLanguage.es   => 'IDIOMA',
  };

  String get languageTitle => switch (lang) {
    AppLanguage.ptBr => 'Idioma do app',
    AppLanguage.en   => 'App language',
    AppLanguage.es   => 'Idioma de la app',
  };

  String get languageSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Escolha o idioma preferido.',
    AppLanguage.en   => 'Choose your preferred language.',
    AppLanguage.es   => 'Elige tu idioma preferido.',
  };

  String get languageSheetTitle => switch (lang) {
    AppLanguage.ptBr => 'Selecionar idioma',
    AppLanguage.en   => 'Select language',
    AppLanguage.es   => 'Seleccionar idioma',
  };

  // ─── Settings / Configurações — LANG-U1.2 ────────────────────────────────────

  String get settingsTitle => switch (lang) {
    AppLanguage.ptBr => 'Configurações',
    AppLanguage.en   => 'Settings',
    AppLanguage.es   => 'Configuración',
  };

  String get settingsSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Organize preferências do app em um só lugar.',
    AppLanguage.en   => 'Organize app preferences in one place.',
    AppLanguage.es   => 'Organiza las preferencias de la app en un lugar.',
  };

  // Focus mode
  String get focusBadge => switch (lang) {
    AppLanguage.ptBr => 'FOCO',
    AppLanguage.en   => 'FOCUS',
    AppLanguage.es   => 'FOCO',
  };

  String get focusTitle => switch (lang) {
    AppLanguage.ptBr => 'Modo Foco Gamer',
    AppLanguage.en   => 'Gamer Focus Mode',
    AppLanguage.es   => 'Modo Foco Gamer',
  };

  String get focusDescription => switch (lang) {
    AppLanguage.ptBr =>
      'Reduz interrupções durante sua sessão usando o Não Perturbe do Android. '
      'Requer permissão manual. Não melhora FPS, RAM, GPU ou Ping.',
    AppLanguage.en =>
      "Reduces interruptions during your session using Android's Do Not Disturb. "
      'Requires manual permission. Does not improve FPS, RAM, GPU or Ping.',
    AppLanguage.es =>
      'Reduce interrupciones durante tu sesión usando No Molestar de Android. '
      'Requiere permiso manual. No mejora FPS, RAM, GPU ni Ping.',
  };

  String get focusChecking => switch (lang) {
    AppLanguage.ptBr => 'Verificando permissão...',
    AppLanguage.en   => 'Checking permission...',
    AppLanguage.es   => 'Verificando permiso...',
  };

  String get focusStatusActive => switch (lang) {
    AppLanguage.ptBr => 'Ativo',
    AppLanguage.en   => 'Active',
    AppLanguage.es   => 'Activo',
  };

  String get focusStatusRequired => switch (lang) {
    AppLanguage.ptBr => 'Necessário',
    AppLanguage.en   => 'Required',
    AppLanguage.es   => 'Requerido',
  };

  String get focusGrantedLabel => switch (lang) {
    AppLanguage.ptBr => 'Permissão concedida',
    AppLanguage.en   => 'Permission granted',
    AppLanguage.es   => 'Permiso concedido',
  };

  String get focusRequiredLabel => switch (lang) {
    AppLanguage.ptBr => 'Permissão necessária',
    AppLanguage.en   => 'Permission required',
    AppLanguage.es   => 'Permiso requerido',
  };

  String get focusGrantedDesc => switch (lang) {
    AppLanguage.ptBr =>
      'Modo Foco disponível. Será ativado ao iniciar uma sessão.',
    AppLanguage.en   =>
      'Focus Mode available. Will be activated when starting a session.',
    AppLanguage.es   =>
      'Modo Foco disponible. Se activará al iniciar una sesión.',
  };

  String get focusRequiredDesc => switch (lang) {
    AppLanguage.ptBr => 'Conceda acesso para ativar o Modo Foco.',
    AppLanguage.en   => 'Grant access to activate Focus Mode.',
    AppLanguage.es   => 'Concede acceso para activar el Modo Foco.',
  };

  String get focusOpenSettingsError => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível abrir as configurações do Android.',
    AppLanguage.en   => 'Could not open Android settings.',
    AppLanguage.es   => 'No se pudieron abrir los ajustes de Android.',
  };

  String get focusAllowButton => switch (lang) {
    AppLanguage.ptBr => 'PERMITIR MODO FOCO',
    AppLanguage.en   => 'ALLOW FOCUS MODE',
    AppLanguage.es   => 'PERMITIR MODO FOCO',
  };

  // Clear history
  String get clearHistoryTitle => switch (lang) {
    AppLanguage.ptBr => 'Limpar histórico de sessões',
    AppLanguage.en   => 'Clear session history',
    AppLanguage.es   => 'Borrar historial de sesiones',
  };

  String get clearHistorySubtitle => switch (lang) {
    AppLanguage.ptBr => 'Apaga todas as sessões salvas localmente.',
    AppLanguage.en   => 'Deletes all locally saved sessions.',
    AppLanguage.es   => 'Borra todas las sesiones guardadas localmente.',
  };

  String get clearHistoryDialogTitle => switch (lang) {
    AppLanguage.ptBr => 'Limpar histórico?',
    AppLanguage.en   => 'Clear history?',
    AppLanguage.es   => '¿Borrar historial?',
  };

  String get clearHistoryDialogContent => switch (lang) {
    AppLanguage.ptBr =>
      'Todas as sessões serão apagadas. Esta ação não pode ser desfeita.',
    AppLanguage.en   =>
      'All sessions will be deleted. This action cannot be undone.',
    AppLanguage.es   =>
      'Todas las sesiones serán borradas. Esta acción no se puede deshacer.',
  };

  String get clearHistoryActionClear => switch (lang) {
    AppLanguage.ptBr => 'LIMPAR',
    AppLanguage.en   => 'CLEAR',
    AppLanguage.es   => 'BORRAR',
  };

  String get clearHistorySuccess => switch (lang) {
    AppLanguage.ptBr => 'Histórico apagado com sucesso.',
    AppLanguage.en   => 'History cleared successfully.',
    AppLanguage.es   => 'Historial borrado con éxito.',
  };

  // About
  String get aboutBadge => switch (lang) {
    AppLanguage.ptBr => 'SOBRE',
    AppLanguage.en   => 'ABOUT',
    AppLanguage.es   => 'SOBRE',
  };

  String get aboutPrivacyLabel => switch (lang) {
    AppLanguage.ptBr => 'Política de Privacidade',
    AppLanguage.en   => 'Privacy Policy',
    AppLanguage.es   => 'Política de Privacidad',
  };

  String get aboutPrivacyAction => switch (lang) {
    AppLanguage.ptBr => 'Ver política',
    AppLanguage.en   => 'View policy',
    AppLanguage.es   => 'Ver política',
  };

  String get aboutPrivacyOpenError => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível abrir a Política de Privacidade.',
    AppLanguage.en   => 'Could not open the Privacy Policy.',
    AppLanguage.es   => 'No se pudo abrir la Política de Privacidad.',
  };

  String get privacyPolicyUrl => switch (lang) {
    AppLanguage.ptBr => 'https://allappsengineer.github.io/apex-booster-plus/privacy/',
    AppLanguage.en   => 'https://allappsengineer.github.io/apex-booster-plus/privacy/en/',
    AppLanguage.es   => 'https://allappsengineer.github.io/apex-booster-plus/privacy/es/',
  };

  // ─── Honest Booster Mode — TRUST-U1 ─────────────────────────────────────────

  // Card em ConfiguracoesTab
  String get honestBoosterCardBadge => switch (lang) {
    AppLanguage.ptBr => 'CONFIANÇA',
    AppLanguage.en   => 'TRUST',
    AppLanguage.es   => 'CONFIANZA',
  };

  String get honestBoosterCardTitle => switch (lang) {
    AppLanguage.ptBr => 'Modo Booster Honesto',
    AppLanguage.en   => 'Honest Booster Mode',
    AppLanguage.es   => 'Modo Booster Honesto',
  };

  String get honestBoosterCardSubtitle => switch (lang) {
    AppLanguage.ptBr => 'O que o Apex faz — e o que ele não promete.',
    AppLanguage.en   => "What Apex does — and what it doesn't promise.",
    AppLanguage.es   => 'Lo que Apex hace — y lo que no promete.',
  };

  String get honestBoosterCardAction => switch (lang) {
    AppLanguage.ptBr => 'Ver detalhes',
    AppLanguage.en   => 'See details',
    AppLanguage.es   => 'Ver detalles',
  };

  // HonestBoosterModeScreen
  String get honestBoosterScreenTitle => switch (lang) {
    AppLanguage.ptBr => 'Modo Booster Honesto',
    AppLanguage.en   => 'Honest Booster Mode',
    AppLanguage.es   => 'Modo Booster Honesto',
  };

  String get honestBoosterIntro => switch (lang) {
    AppLanguage.ptBr =>
      'O Apex Booster+ é uma ferramenta de preparação gamer. '
      'Aqui está o que ele faz — e o que ele não promete.',
    AppLanguage.en =>
      'Apex Booster+ is a gaming preparation tool. '
      "Here's what it does — and what it doesn't promise.",
    AppLanguage.es =>
      'Apex Booster+ es una herramienta de preparación gamer. '
      'Esto es lo que hace — y lo que no promete.',
  };

  String get honestBoosterQ1 => switch (lang) {
    AppLanguage.ptBr => 'O app aumenta FPS?',
    AppLanguage.en   => 'Does the app boost FPS?',
    AppLanguage.es   => '¿La app aumenta los FPS?',
  };

  String get honestBoosterA1 => switch (lang) {
    AppLanguage.ptBr =>
      'O Apex Booster+ não promete aumento real de FPS. Ele prepara sua sessão '
      'com organização, perfis, foco, leitura local e experiência visual.',
    AppLanguage.en =>
      "Apex Booster+ doesn't promise a real FPS boost. It prepares your session "
      'with organization, profiles, focus, local readings, and visual experience.',
    AppLanguage.es =>
      'Apex Booster+ no promete un aumento real de FPS. Prepara tu sesión con '
      'organización, perfiles, enfoque, lecturas locales y experiencia visual.',
  };

  String get honestBoosterQ2 => switch (lang) {
    AppLanguage.ptBr => 'O app reduz ping?',
    AppLanguage.en   => 'Does the app reduce ping?',
    AppLanguage.es   => '¿La app reduce el ping?',
  };

  String get honestBoosterA2 => switch (lang) {
    AppLanguage.ptBr =>
      'Ping depende de rede, rota, servidor e operadora. O app pode exibir '
      'Latência Apex própria, mas não promete reduzir ping de jogos terceiros.',
    AppLanguage.en =>
      'Ping depends on network, routing, server, and carrier. The app can display '
      "its own Apex Latency reading, but doesn't promise to reduce ping in third-party games.",
    AppLanguage.es =>
      'El ping depende de la red, la ruta, el servidor y el operador. La app puede '
      'mostrar su propia Latencia Apex, pero no promete reducir el ping en juegos de terceros.',
  };

  String get honestBoosterQ3 => switch (lang) {
    AppLanguage.ptBr => 'O app limpa RAM?',
    AppLanguage.en   => 'Does the app clean RAM?',
    AppLanguage.es   => '¿La app limpia la RAM?',
  };

  String get honestBoosterA3 => switch (lang) {
    AppLanguage.ptBr =>
      'O app pode exibir snapshot de memória quando disponível, '
      'mas não promete limpeza automática de RAM.',
    AppLanguage.en =>
      "The app can display a memory snapshot when available, but doesn't promise "
      'automatic RAM cleanup.',
    AppLanguage.es =>
      'La app puede mostrar un snapshot de memoria cuando está disponible, '
      'pero no promete limpieza automática de RAM.',
  };

  String get honestBoosterQ4 => switch (lang) {
    AppLanguage.ptBr => 'O que o app realmente faz?',
    AppLanguage.en   => 'What does the app actually do?',
    AppLanguage.es   => '¿Qué hace realmente la app?',
  };

  String get honestBoosterA4 => switch (lang) {
    AppLanguage.ptBr =>
      'O Apex Booster+ organiza seus jogos, salva preferências locais, exibe '
      'dados locais, cria um ritual visual de preparação e abre o jogo selecionado.',
    AppLanguage.en =>
      'Apex Booster+ organizes your games, saves local preferences, displays local '
      'data, creates a visual preparation ritual, and launches your selected game.',
    AppLanguage.es =>
      'Apex Booster+ organiza tus juegos, guarda preferencias locales, muestra datos '
      'locales, crea un ritual visual de preparación y abre el juego seleccionado.',
  };

  String get honestBoosterQ5 => switch (lang) {
    AppLanguage.ptBr => 'O que o unlock libera?',
    AppLanguage.en   => 'What does the unlock include?',
    AppLanguage.es   => '¿Qué incluye el desbloqueo?',
  };

  String get honestBoosterA5 => switch (lang) {
    AppLanguage.ptBr =>
      'O unlock libera a experiência premium: temas, ritual completo, perfis '
      'avançados, histórico enriquecido, badges, widget, Quick Actions e cards, '
      'conforme forem implementados.',
    AppLanguage.en =>
      'The unlock includes the full premium experience: themes, complete ritual, '
      'advanced profiles, enriched history, badges, widget, Quick Actions, and cards '
      '— as they become available.',
    AppLanguage.es =>
      'El desbloqueo incluye la experiencia premium completa: temas, ritual completo, '
      'perfiles avanzados, historial enriquecido, insignias, widget, Quick Actions y '
      'tarjetas — según se implementen.',
  };

  String get honestBoosterQ6 => switch (lang) {
    AppLanguage.ptBr => 'Por que usar antes de jogar?',
    AppLanguage.en   => 'Why use it before playing?',
    AppLanguage.es   => '¿Por qué usarla antes de jugar?',
  };

  String get honestBoosterA6 => switch (lang) {
    AppLanguage.ptBr =>
      'Para entrar com biblioteca organizada, perfil carregado, checklist de foco '
      'e preparação visual.',
    AppLanguage.en =>
      'To enter with an organized library, loaded profile, focus checklist, and '
      'visual preparation.',
    AppLanguage.es =>
      'Para entrar con biblioteca organizada, perfil cargado, checklist de enfoque '
      'y preparación visual.',
  };

  // ─── Low Distraction Mode — ACCESS-U1A ──────────────────────────────────────

  String get lowDistractionBadge => switch (lang) {
    AppLanguage.ptBr => 'FOCO',
    AppLanguage.en   => 'FOCUS',
    AppLanguage.es   => 'FOCO',
  };

  String get lowDistractionTitle => switch (lang) {
    AppLanguage.ptBr => 'Modo Baixa Distração',
    AppLanguage.en   => 'Low Distraction Mode',
    AppLanguage.es   => 'Modo de Baja Distracción',
  };

  String get lowDistractionSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Reduz animações, vibrações e intensidade visual quando disponível.',
    AppLanguage.en   => 'Reduces animations, haptics, and visual intensity when available.',
    AppLanguage.es   => 'Reduce animaciones, vibraciones e intensidad visual cuando esté disponible.',
  };

  // ─── Home / Início — LANG-U1.3 ───────────────────────────────────────────────

  String get homeTitle => switch (lang) {
    AppLanguage.ptBr => 'Pronto para jogar?',
    AppLanguage.en   => 'Ready to play?',
    AppLanguage.es   => '¿Listo para jugar?',
  };

  String get homeSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Configure sua sessão antes de abrir o jogo.',
    AppLanguage.en   => 'Set up your session before opening the game.',
    AppLanguage.es   => 'Configura tu sesión antes de abrir el juego.',
  };

  String get homeLastGameBadge => switch (lang) {
    AppLanguage.ptBr => 'ÚLTIMO JOGO',
    AppLanguage.en   => 'LAST GAME',
    AppLanguage.es   => 'ÚLTIMO JUEGO',
  };

  String get homeViewDetails => switch (lang) {
    AppLanguage.ptBr => 'VER DETALHES',
    AppLanguage.en   => 'VIEW DETAILS',
    AppLanguage.es   => 'VER DETALLES',
  };

  String get homeGamesLabel => switch (lang) {
    AppLanguage.ptBr => 'JOGOS',
    AppLanguage.en   => 'GAMES',
    AppLanguage.es   => 'JUEGOS',
  };

  String get homeSessionsLabel => switch (lang) {
    AppLanguage.ptBr => 'SESSÕES',
    AppLanguage.en   => 'SESSIONS',
    AppLanguage.es   => 'SESIONES',
  };

  String get homeLibraryBadge => switch (lang) {
    AppLanguage.ptBr => 'BIB',
    AppLanguage.en   => 'LIB',
    AppLanguage.es   => 'BIB',
  };

  String get homeLibraryTitle => switch (lang) {
    AppLanguage.ptBr => 'Biblioteca gamer',
    AppLanguage.en   => 'Game library',
    AppLanguage.es   => 'Biblioteca gamer',
  };

  String get homeHistoryBadge => switch (lang) {
    AppLanguage.ptBr => 'HIST',
    AppLanguage.en   => 'HIST',
    AppLanguage.es   => 'HIST',
  };

  String get homeHistoryFeatureTitle => switch (lang) {
    AppLanguage.ptBr => 'Histórico de sessões',
    AppLanguage.en   => 'Session history',
    AppLanguage.es   => 'Historial de sesiones',
  };

  String get homeFocusSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Ativo antes de abrir o jogo, se permitido.',
    AppLanguage.en   => 'Active before opening the game, if allowed.',
    AppLanguage.es   => 'Activo antes de abrir el juego, si está permitido.',
  };

  String get homeScanTitle => 'Apex Scan';

  String get homeScanSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Diagnóstico no detalhe de cada jogo.',
    AppLanguage.en   => 'Diagnostic in each game detail.',
    AppLanguage.es   => 'Diagnóstico en el detalle de cada juego.',
  };

  String get homeGameBadge => switch (lang) {
    AppLanguage.ptBr => 'GAME',
    AppLanguage.en   => 'GAME',
    AppLanguage.es   => 'JUEGO',
  };

  String get homeClassTitle => switch (lang) {
    AppLanguage.ptBr => 'Classificação gamer',
    AppLanguage.en   => 'Gamer classification',
    AppLanguage.es   => 'Clasificación gamer',
  };

  String get homeClassSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Apps verificados identificados na biblioteca.',
    AppLanguage.en   => 'Verified apps identified in the library.',
    AppLanguage.es   => 'Apps verificados identificados en la biblioteca.',
  };

  String get homeEmptyHint => switch (lang) {
    AppLanguage.ptBr => 'Adicione jogos na aba Biblioteca para começar.',
    AppLanguage.en   => 'Add games in the Library tab to get started.',
    AppLanguage.es   => 'Agrega juegos en la pestaña Biblioteca para comenzar.',
  };

  /// Loading-state subtitle for the Library feature card (while data loads).
  String get homeLibraryLoadingSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Biblioteca organizada',
    AppLanguage.en   => 'Library organized',
    AppLanguage.es   => 'Biblioteca organizada',
  };

  /// Loading-state subtitle for the History feature card (while data loads).
  String get homeHistoryLoadingSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Histórico registrado localmente',
    AppLanguage.en   => 'History recorded locally',
    AppLanguage.es   => 'Historial registrado localmente',
  };

  // Dynamic — relative time
  String get timeJustNow => switch (lang) {
    AppLanguage.ptBr => 'agora mesmo',
    AppLanguage.en   => 'just now',
    AppLanguage.es   => 'ahora mismo',
  };

  String timeMinutesAgo(int n) => switch (lang) {
    AppLanguage.ptBr => 'há $n min',
    AppLanguage.en   => '${n}m ago',
    AppLanguage.es   => 'hace $n min',
  };

  String timeHoursAgo(int n) => switch (lang) {
    AppLanguage.ptBr => 'há ${n}h',
    AppLanguage.en   => '${n}h ago',
    AppLanguage.es   => 'hace ${n}h',
  };

  String get timeYesterday => switch (lang) {
    AppLanguage.ptBr => 'ontem',
    AppLanguage.en   => 'yesterday',
    AppLanguage.es   => 'ayer',
  };

  String timeDaysAgo(int n) => switch (lang) {
    AppLanguage.ptBr => 'há $n dias',
    AppLanguage.en   => '$n days ago',
    AppLanguage.es   => 'hace $n días',
  };

  /// Returns a locale-aware relative time string for [dt].
  ///
  /// Pass [now] in tests to avoid depending on the real clock.
  String relativeTime(DateTime dt, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(dt);
    if (diff.inMinutes < 1) return timeJustNow;
    if (diff.inMinutes < 60) return timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return timeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return timeYesterday;
    if (diff.inDays < 7) return timeDaysAgo(diff.inDays);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  // Dynamic — counts
  String gameCountStat(int n) => switch (lang) {
    AppLanguage.ptBr =>
      '$n ${n == 1 ? 'jogo adicionado' : 'jogos adicionados'}',
    AppLanguage.en =>
      '$n ${n == 1 ? 'game added' : 'games added'}',
    AppLanguage.es =>
      '$n ${n == 1 ? 'juego agregado' : 'juegos agregados'}',
  };

  String sessionCountStat(int n) => switch (lang) {
    AppLanguage.ptBr =>
      '$n ${n == 1 ? 'sessão registrada' : 'sessões registradas'}',
    AppLanguage.en =>
      '$n ${n == 1 ? 'session recorded' : 'sessions recorded'}',
    AppLanguage.es =>
      '$n ${n == 1 ? 'sesión registrada' : 'sesiones registradas'}',
  };

  // ─── History / Histórico — LANG-U1.3 ─────────────────────────────────────────

  String get historyHeaderLabel => switch (lang) {
    AppLanguage.ptBr => 'HISTÓRICO',
    AppLanguage.en   => 'HISTORY',
    AppLanguage.es   => 'HISTORIAL',
  };

  String get historyTitle => switch (lang) {
    AppLanguage.ptBr => 'Sessões registradas',
    AppLanguage.en   => 'Recorded sessions',
    AppLanguage.es   => 'Sesiones registradas',
  };

  String get historySubtitle => switch (lang) {
    AppLanguage.ptBr => 'Registro local das suas sessões.',
    AppLanguage.en   => 'Local record of your sessions.',
    AppLanguage.es   => 'Registro local de tus sesiones.',
  };

  String get historyLoading => switch (lang) {
    AppLanguage.ptBr => 'Carregando sessões...',
    AppLanguage.en   => 'Loading sessions...',
    AppLanguage.es   => 'Cargando sesiones...',
  };

  String get historyEmptyTitle => switch (lang) {
    AppLanguage.ptBr => 'Nenhuma sessão ainda.',
    AppLanguage.en   => 'No sessions yet.',
    AppLanguage.es   => 'Sin sesiones aún.',
  };

  String get historyEmptyDesc => switch (lang) {
    AppLanguage.ptBr =>
      'Abra um jogo pela Biblioteca para começar seu histórico.',
    AppLanguage.en   =>
      'Open a game from the Library to start your history.',
    AppLanguage.es   =>
      'Abre un juego desde la Biblioteca para comenzar tu historial.',
  };

  String get historyStatusSuccess => switch (lang) {
    AppLanguage.ptBr => 'Abertura registrada',
    AppLanguage.en   => 'Opening recorded',
    AppLanguage.es   => 'Apertura registrada',
  };

  String get historyStatusAttempted => switch (lang) {
    AppLanguage.ptBr => 'Tentativa registrada',
    AppLanguage.en   => 'Attempt recorded',
    AppLanguage.es   => 'Intento registrado',
  };

  String get historyStatusFailed => switch (lang) {
    AppLanguage.ptBr => 'Falha ao abrir',
    AppLanguage.en   => 'Failed to open',
    AppLanguage.es   => 'Falla al abrir',
  };

  String get historyFocusEnabled => switch (lang) {
    AppLanguage.ptBr => 'Foco ativo',
    AppLanguage.en   => 'Focus active',
    AppLanguage.es   => 'Foco activo',
  };

  String get historyFocusNoPermission => switch (lang) {
    AppLanguage.ptBr => 'Sem permissão de foco',
    AppLanguage.en   => 'No focus permission',
    AppLanguage.es   => 'Sin permiso de foco',
  };

  String get historyFocusError => switch (lang) {
    AppLanguage.ptBr => 'Erro no foco',
    AppLanguage.en   => 'Focus error',
    AppLanguage.es   => 'Error de foco',
  };

  /// Translates a raw memory state key (e.g. "normal", "low") to the active language.
  /// Unknown keys fall back to the original value so old sessions don't break.
  String memoryStateLabel(String state) => switch (state) {
    'normal' => switch (lang) {
      AppLanguage.ptBr => 'normal',
      AppLanguage.en   => 'stable',
      AppLanguage.es   => 'estable',
    },
    'low' => switch (lang) {
      AppLanguage.ptBr => 'baixa',
      AppLanguage.en   => 'low',
      AppLanguage.es   => 'baja',
    },
    _ => state,
  };

  /// RAM chip text shown in session history cards.
  /// [availGb] is already formatted (e.g. "3.2"), [state] is the raw device key (e.g. "normal").
  String historyRamChip(String availGb, String state) {
    final localizedState = memoryStateLabel(state);
    return switch (lang) {
      AppLanguage.ptBr => '$availGb GB livre • $localizedState',
      AppLanguage.en   => '$availGb GB free • $localizedState',
      AppLanguage.es   => '$availGb GB libres • $localizedState',
    };
  }

  // ─── Prepare / Preparar — LANG-U1.4 ──────────────────────────────────────────

  String get prepTitle => switch (lang) {
    AppLanguage.ptBr => 'Preparar sessão',
    AppLanguage.en   => 'Prepare session',
    AppLanguage.es   => 'Preparar sesión',
  };

  String get prepSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Selecione um jogo e verifique os dados antes de jogar.',
    AppLanguage.en   => 'Select a game and check data before playing.',
    AppLanguage.es   => 'Selecciona un juego y verifica los datos antes de jugar.',
  };

  String get prepEmptyTitle => switch (lang) {
    AppLanguage.ptBr => 'Nenhum jogo na biblioteca',
    AppLanguage.en   => 'No games in library',
    AppLanguage.es   => 'Sin juegos en la biblioteca',
  };

  String get prepEmptyDesc => switch (lang) {
    AppLanguage.ptBr =>
      'Adicione jogos na aba Biblioteca para preparar sua sessão.',
    AppLanguage.en   =>
      'Add games in the Library tab to prepare your session.',
    AppLanguage.es   =>
      'Agrega juegos en la pestaña Biblioteca para preparar tu sesión.',
  };

  String get prepChangeGame => switch (lang) {
    AppLanguage.ptBr => 'TROCAR',
    AppLanguage.en   => 'CHANGE',
    AppLanguage.es   => 'CAMBIAR',
  };

  String get prepContinue => switch (lang) {
    AppLanguage.ptBr => 'CONTINUAR PARA DETALHES',
    AppLanguage.en   => 'CONTINUE TO DETAILS',
    AppLanguage.es   => 'CONTINUAR A DETALLES',
  };

  // Apex Scan section
  String get prepScanBadge => 'SCAN';

  String get prepScanTitle => 'Apex Scan';

  String get prepScanLabelApp => switch (lang) {
    AppLanguage.ptBr => 'App vinculado',
    AppLanguage.en   => 'App linked',
    AppLanguage.es   => 'App vinculado',
  };

  String get prepScanMsgAppOk => switch (lang) {
    AppLanguage.ptBr => 'PackageName registrado no cadastro',
    AppLanguage.en   => 'PackageName registered in profile',
    AppLanguage.es   => 'PackageName registrado en el perfil',
  };

  String get prepScanMsgAppWarn => switch (lang) {
    AppLanguage.ptBr => 'Sem vínculo — packageName não cadastrado',
    AppLanguage.en   => 'No link — packageName not registered',
    AppLanguage.es   => 'Sin vínculo — packageName no registrado',
  };

  String get prepScanLabelGfx => switch (lang) {
    AppLanguage.ptBr => 'Perfil GFX',
    AppLanguage.en   => 'GFX Profile',
    AppLanguage.es   => 'Perfil GFX',
  };

  String get prepScanLabelPriority => switch (lang) {
    AppLanguage.ptBr => 'Prioridade',
    AppLanguage.en   => 'Priority',
    AppLanguage.es   => 'Prioridad',
  };

  String get prepScanMsgPriorityOk => switch (lang) {
    AppLanguage.ptBr => 'Marcado como prioritário',
    AppLanguage.en   => 'Marked as priority',
    AppLanguage.es   => 'Marcado como prioritario',
  };

  String get prepScanMsgPriorityInfo => switch (lang) {
    AppLanguage.ptBr => 'Jogo padrão na biblioteca',
    AppLanguage.en   => 'Default game in library',
    AppLanguage.es   => 'Juego predeterminado en la biblioteca',
  };

  String get prepSuggestionsTitle => switch (lang) {
    AppLanguage.ptBr => 'Sugestões',
    AppLanguage.en   => 'Suggestions',
    AppLanguage.es   => 'Sugerencias',
  };

  // GFX scan messages — used in buildGfxScanMessage (migrated to AppStrings in LANG-U1.4)
  String get prepGfxMsgNone => switch (lang) {
    AppLanguage.ptBr => 'Perfil padrão será usado',
    AppLanguage.en   => 'Default profile will be used',
    AppLanguage.es   => 'Se usará el perfil predeterminado',
  };

  String get prepGfxMsgBalanced => switch (lang) {
    AppLanguage.ptBr => 'Equilibrado — balanço entre visual e fluidez',
    AppLanguage.en   => 'Balanced — balance between visuals and fluidity',
    AppLanguage.es   => 'Equilibrado — balance entre visual y fluidez',
  };

  String get prepGfxMsgPerformance => switch (lang) {
    AppLanguage.ptBr => 'Desempenho — priorizando fluidez local',
    AppLanguage.en   => 'Performance — prioritizing local fluidity',
    AppLanguage.es   => 'Rendimiento — priorizando fluidez local',
  };

  String get prepGfxMsgQuality => switch (lang) {
    AppLanguage.ptBr => 'Qualidade — priorizando visual local',
    AppLanguage.en   => 'Quality — prioritizing local visuals',
    AppLanguage.es   => 'Calidad — priorizando visual local',
  };

  String get prepGfxMsgEconomy => switch (lang) {
    AppLanguage.ptBr => 'Economia — priorizando autonomia da bateria',
    AppLanguage.en   => 'Economy — prioritizing battery life',
    AppLanguage.es   => 'Economía — priorizando la autonomía de la batería',
  };

  // GFX recommendations — used in buildGfxRecommendations (migrated in LANG-U1.4)
  String get recPerfCloseBackground => switch (lang) {
    AppLanguage.ptBr => 'Feche apps em segundo plano antes de iniciar',
    AppLanguage.en   => 'Close background apps before starting',
    AppLanguage.es   => 'Cierra apps en segundo plano antes de iniciar',
  };

  String get recPerfFocus => switch (lang) {
    AppLanguage.ptBr => 'Ative o Modo Foco para reduzir interrupções',
    AppLanguage.en   => 'Activate Focus Mode to reduce interruptions',
    AppLanguage.es   => 'Activa el Modo Foco para reducir interrupciones',
  };

  String get recPerfLowMemory => switch (lang) {
    AppLanguage.ptBr => 'RAM limitada — feche apps pesados antes de jogar',
    AppLanguage.en   => 'Limited RAM — close heavy apps before playing',
    AppLanguage.es   => 'RAM limitada — cierra apps pesadas antes de jugar',
  };

  String get recPerfWifi => switch (lang) {
    AppLanguage.ptBr => 'Prefira conexão Wi-Fi estável',
    AppLanguage.en   => 'Prefer stable Wi-Fi connection',
    AppLanguage.es   => 'Prefiere conexión Wi-Fi estable',
  };

  String get recQualCharge => switch (lang) {
    AppLanguage.ptBr => 'Mantenha o dispositivo carregado durante a sessão',
    AppLanguage.en   => 'Keep the device charged during the session',
    AppLanguage.es   => 'Mantén el dispositivo cargado durante la sesión',
  };

  String get recQualLatency => switch (lang) {
    AppLanguage.ptBr => 'Conexão estável favorece uma sessão mais consistente',
    AppLanguage.en   => 'Stable connection favors a more consistent session',
    AppLanguage.es   => 'Una conexión estable favorece una sesión más consistente',
  };

  String get recQualFocus => switch (lang) {
    AppLanguage.ptBr => 'Ative o Modo Foco para reduzir interrupções visuais',
    AppLanguage.en   => 'Activate Focus Mode to reduce visual interruptions',
    AppLanguage.es   => 'Activa el Modo Foco para reducir interrupciones visuales',
  };

  String get recEcoBrightness => switch (lang) {
    AppLanguage.ptBr => 'Reduza o brilho da tela para preservar bateria',
    AppLanguage.en   => 'Reduce screen brightness to preserve battery',
    AppLanguage.es   => 'Reduce el brillo de pantalla para preservar la batería',
  };

  String get recEcoShortSessions => switch (lang) {
    AppLanguage.ptBr =>
      'Prefira sessões mais curtas ou jogue com carga suficiente',
    AppLanguage.en   =>
      'Prefer shorter sessions or play with sufficient charge',
    AppLanguage.es   =>
      'Prefiere sesiones más cortas o juega con carga suficiente',
  };

  String get recEcoFocus => switch (lang) {
    AppLanguage.ptBr => 'Modo Foco ajuda a reduzir interrupções na sessão',
    AppLanguage.en   => 'Focus Mode helps reduce interruptions in the session',
    AppLanguage.es   => 'El Modo Foco ayuda a reducir interrupciones en la sesión',
  };

  String get recBalStable => switch (lang) {
    AppLanguage.ptBr => 'Prepare a sessão com conexão estável',
    AppLanguage.en   => 'Prepare the session with a stable connection',
    AppLanguage.es   => 'Prepara la sesión con una conexión estable',
  };

  String get recBalCloseUnused => switch (lang) {
    AppLanguage.ptBr => 'Feche apps que não usa antes de iniciar',
    AppLanguage.en   => 'Close unused apps before starting',
    AppLanguage.es   => 'Cierra las apps que no usas antes de iniciar',
  };

  // Device snapshot
  String get snapshotBadge => 'SNAPSHOT';

  String get snapshotTitle => switch (lang) {
    AppLanguage.ptBr => 'Snapshot do Dispositivo',
    AppLanguage.en   => 'Device Snapshot',
    AppLanguage.es   => 'Snapshot del Dispositivo',
  };

  String get snapshotRamAvail => switch (lang) {
    AppLanguage.ptBr => 'RAM Disponível',
    AppLanguage.en   => 'Available RAM',
    AppLanguage.es   => 'RAM Disponible',
  };

  String get snapshotRamTotal => switch (lang) {
    AppLanguage.ptBr => 'RAM Total',
    AppLanguage.en   => 'Total RAM',
    AppLanguage.es   => 'RAM Total',
  };

  String get snapshotRamState => switch (lang) {
    AppLanguage.ptBr => 'Estado de Memória',
    AppLanguage.en   => 'Memory State',
    AppLanguage.es   => 'Estado de Memoria',
  };

  String get snapshotLatency => switch (lang) {
    AppLanguage.ptBr => 'Latência Apex',
    AppLanguage.en   => 'Apex Latency',
    AppLanguage.es   => 'Latencia Apex',
  };

  String get snapshotFocusMode => switch (lang) {
    AppLanguage.ptBr => 'Modo Foco',
    AppLanguage.en   => 'Focus Mode',
    AppLanguage.es   => 'Modo Foco',
  };

  String get snapshotUnavailable => switch (lang) {
    AppLanguage.ptBr => 'Indisponível',
    AppLanguage.en   => 'Unavailable',
    AppLanguage.es   => 'No disponible',
  };

  String get snapshotFocusActive => switch (lang) {
    AppLanguage.ptBr => 'Ativo',
    AppLanguage.en   => 'Active',
    AppLanguage.es   => 'Activo',
  };

  String get snapshotFocusNoPermission => switch (lang) {
    AppLanguage.ptBr => 'Sem permissão',
    AppLanguage.en   => 'No permission',
    AppLanguage.es   => 'Sin permiso',
  };

  String get snapshotLocalReading => switch (lang) {
    AppLanguage.ptBr => 'Leitura local do dispositivo',
    AppLanguage.en   => 'Local device reading',
    AppLanguage.es   => 'Lectura local del dispositivo',
  };

  String get snapshotMemoryCritical => switch (lang) {
    AppLanguage.ptBr => 'Crítico',
    AppLanguage.en   => 'Critical',
    AppLanguage.es   => 'Crítico',
  };

  String get snapshotMemoryNormal => switch (lang) {
    AppLanguage.ptBr => 'Normal',
    AppLanguage.en   => 'Normal',
    AppLanguage.es   => 'Normal',
  };

  String get snapshotLatencyTimeout => switch (lang) {
    AppLanguage.ptBr => 'Tempo esgotado',
    AppLanguage.en   => 'Timeout',
    AppLanguage.es   => 'Tiempo agotado',
  };

  String get snapshotLatencyNoNetwork => switch (lang) {
    AppLanguage.ptBr => 'Sem rede',
    AppLanguage.en   => 'No network',
    AppLanguage.es   => 'Sin red',
  };

  /// Focus Mode permission is granted — feature is available in snapshot context.
  String get snapshotFocusAvailable => switch (lang) {
    AppLanguage.ptBr => 'Disponível',
    AppLanguage.en   => 'Available',
    AppLanguage.es   => 'Disponible',
  };

  /// Focus Mode permission not granted — shown in snapshot card.
  String get snapshotFocusPermissionRequired => switch (lang) {
    AppLanguage.ptBr => 'Permissão necessária',
    AppLanguage.en   => 'Permission required',
    AppLanguage.es   => 'Permiso requerido',
  };

  // Prepare card — additional strings for LANG-U1.4B
  String get prepGameBadge => switch (lang) {
    AppLanguage.ptBr => 'JOGO',
    AppLanguage.en   => 'GAME',
    AppLanguage.es   => 'JUEGO',
  };

  String get prepGfxDefault => switch (lang) {
    AppLanguage.ptBr => 'Padrão',
    AppLanguage.en   => 'Default',
    AppLanguage.es   => 'Predeterminado',
  };

  String get prepFavoriteLabel => switch (lang) {
    AppLanguage.ptBr => '★ Favorito',
    AppLanguage.en   => '★ Favorite',
    AppLanguage.es   => '★ Favorito',
  };

  String get prepScanStatusReady => switch (lang) {
    AppLanguage.ptBr => '● PRONTO',
    AppLanguage.en   => '● READY',
    AppLanguage.es   => '● LISTO',
  };

  String get prepScanStatusIncomplete => switch (lang) {
    AppLanguage.ptBr => '● INCOMPLETO',
    AppLanguage.en   => '● INCOMPLETE',
    AppLanguage.es   => '● INCOMPLETO',
  };

  String get prepScanSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Verificação local do jogo',
    AppLanguage.en   => 'Local game check',
    AppLanguage.es   => 'Verificación local del juego',
  };

  String get prepSelectGame => switch (lang) {
    AppLanguage.ptBr => 'Selecionar jogo',
    AppLanguage.en   => 'Select game',
    AppLanguage.es   => 'Seleccionar juego',
  };

  // ─── GFX Profile screen — LANG-U1.4 ──────────────────────────────────────────

  String get gfxTitle => switch (lang) {
    AppLanguage.ptBr => 'Perfil GFX',
    AppLanguage.en   => 'GFX Profile',
    AppLanguage.es   => 'Perfil GFX',
  };

  String get gfxBackTooltip => switch (lang) {
    AppLanguage.ptBr => 'Voltar',
    AppLanguage.en   => 'Back',
    AppLanguage.es   => 'Volver',
  };

  String get gfxNotFoundTitle => switch (lang) {
    AppLanguage.ptBr => 'Jogo não encontrado',
    AppLanguage.en   => 'Game not found',
    AppLanguage.es   => 'Juego no encontrado',
  };

  String get gfxNotFoundDesc => switch (lang) {
    AppLanguage.ptBr => 'Este jogo pode ter sido removido da biblioteca.',
    AppLanguage.en   => 'This game may have been removed from the library.',
    AppLanguage.es   => 'Este juego puede haber sido eliminado de la biblioteca.',
  };

  String get gfxInstruction => switch (lang) {
    AppLanguage.ptBr => 'Ajuste a preferência gráfica de preparação deste jogo.',
    AppLanguage.en   => 'Adjust the graphic preparation preference for this game.',
    AppLanguage.es   =>
      'Ajusta la preferencia gráfica de preparación de este juego.',
  };

  String get gfxFootnote => switch (lang) {
    AppLanguage.ptBr => 'Perfil aplicado à preparação local do jogo.',
    AppLanguage.en   => 'Profile applied to the local game preparation.',
    AppLanguage.es   => 'Perfil aplicado a la preparación local del juego.',
  };

  String get gfxCurrentPrefix => switch (lang) {
    AppLanguage.ptBr => 'Atual: ',
    AppLanguage.en   => 'Current: ',
    AppLanguage.es   => 'Actual: ',
  };

  String get gfxNoneLabel => switch (lang) {
    AppLanguage.ptBr => 'Nenhum',
    AppLanguage.en   => 'None',
    AppLanguage.es   => 'Ninguno',
  };

  String get gfxNoneDesc => switch (lang) {
    AppLanguage.ptBr => 'Sem preferência definida para este jogo.',
    AppLanguage.en   => 'No preference defined for this game.',
    AppLanguage.es   => 'Sin preferencia definida para este juego.',
  };

  /// Display label for a [GfxProfile] value.
  ///
  /// The stored label ([GfxProfile.label]) is the canonical DB key and remains
  /// unchanged. This method provides the UI translation for each language.
  String gfxProfileLabel(GfxProfile profile) => switch (lang) {
    AppLanguage.ptBr => profile.label,
    AppLanguage.en => switch (profile) {
      GfxProfile.balanced   => 'Balanced',
      GfxProfile.performance => 'Performance',
      GfxProfile.quality    => 'Quality',
      GfxProfile.economy    => 'Economy',
    },
    AppLanguage.es => switch (profile) {
      GfxProfile.balanced   => 'Equilibrado',
      GfxProfile.performance => 'Rendimiento',
      GfxProfile.quality    => 'Calidad',
      GfxProfile.economy    => 'Economía',
    },
  };

  /// Card description for a [GfxProfile] value shown in [GfxProfileScreen].
  String gfxProfileDescription(GfxProfile profile) => switch (lang) {
    AppLanguage.ptBr => switch (profile) {
      GfxProfile.balanced   => 'Equilibra fluidez e qualidade para sessões longas.',
      GfxProfile.performance => 'Prioriza responsividade na preparação da sessão.',
      GfxProfile.quality    => 'Orientado para uma experiência visual mais rica.',
      GfxProfile.economy    => 'Reduz demanda e preserva bateria durante a sessão.',
    },
    AppLanguage.en => switch (profile) {
      GfxProfile.balanced   => 'Balances fluidity and quality for long sessions.',
      GfxProfile.performance => 'Prioritizes responsiveness in session preparation.',
      GfxProfile.quality    => 'Oriented towards a richer visual experience.',
      GfxProfile.economy    => 'Reduces demand and preserves battery during the session.',
    },
    AppLanguage.es => switch (profile) {
      GfxProfile.balanced   => 'Equilibra fluidez y calidad para sesiones largas.',
      GfxProfile.performance =>
        'Prioriza la capacidad de respuesta en la preparación de la sesión.',
      GfxProfile.quality    => 'Orientado hacia una experiencia visual más rica.',
      GfxProfile.economy    =>
        'Reduce la demanda y preserva la batería durante la sesión.',
    },
  };

  // ─── Onboarding / Welcome — LANG-U1.3B ──────────────────────────────────────

  String get welcomeCardBibTitle => switch (lang) {
    AppLanguage.ptBr => 'Organize seus jogos',
    AppLanguage.en   => 'Organize your games',
    AppLanguage.es   => 'Organiza tus juegos',
  };

  String get welcomeCardBibSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Sua biblioteca pessoal de jogos.',
    AppLanguage.en   => 'Your personal game library.',
    AppLanguage.es   => 'Tu biblioteca personal de juegos.',
  };

  String get welcomeCardScanTitle => switch (lang) {
    AppLanguage.ptBr => 'Analise antes de jogar',
    AppLanguage.en   => 'Analyze before playing',
    AppLanguage.es   => 'Analiza antes de jugar',
  };

  String get welcomeCardScanSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Diagnóstico rápido da sessão.',
    AppLanguage.en   => 'Quick session diagnostic.',
    AppLanguage.es   => 'Diagnóstico rápido de la sesión.',
  };

  String get welcomeCardGoTitle => switch (lang) {
    AppLanguage.ptBr => 'Prepare e abra com estilo',
    AppLanguage.en   => 'Prepare and launch in style',
    AppLanguage.es   => 'Prepara y abre con estilo',
  };

  String get welcomeCardGoSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Lançamento com preparação completa.',
    AppLanguage.en   => 'Launch with full preparation.',
    AppLanguage.es   => 'Lanzamiento con preparación completa.',
  };

  String get welcomeCtaStart => switch (lang) {
    AppLanguage.ptBr => 'COMEÇAR',
    AppLanguage.en   => 'GET STARTED',
    AppLanguage.es   => 'EMPEZAR',
  };

  // ─── Onboarding / HowItWorks — LANG-U1.3B ────────────────────────────────────

  String get howItWorksTitle => switch (lang) {
    AppLanguage.ptBr => 'Como o Apex funciona',
    AppLanguage.en   => 'How Apex works',
    AppLanguage.es   => 'Cómo funciona Apex',
  };

  String get howItWorksCardBibSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Organize seus jogos em um só lugar.',
    AppLanguage.en   => 'Organize your games in one place.',
    AppLanguage.es   => 'Organiza tus juegos en un solo lugar.',
  };

  String get howItWorksCardGfxSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Salve preferências visuais sem alterar jogos de terceiros.',
    AppLanguage.en   => 'Save visual preferences without changing third-party games.',
    AppLanguage.es   => 'Guarda preferencias visuales sin alterar juegos de terceros.',
  };

  String get howItWorksCardScanSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Leia memória, latência e prontidão da sessão.',
    AppLanguage.en   => 'Read memory, latency and session readiness.',
    AppLanguage.es   => 'Lee memoria, latencia y preparación de sesión.',
  };

  String get howItWorksCardGoSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Prepare a sessão e abra o jogo.',
    AppLanguage.en   => 'Prepare the session and open the game.',
    AppLanguage.es   => 'Prepara la sesión y abre el juego.',
  };

  String get howItWorksCta => switch (lang) {
    AppLanguage.ptBr => 'ENTENDI',
    AppLanguage.en   => 'GOT IT',
    AppLanguage.es   => 'ENTENDIDO',
  };

  // ─── Onboarding / Permissions — LANG-U1.3B ───────────────────────────────────

  String get permissionsTitle => switch (lang) {
    AppLanguage.ptBr => 'Permissões com transparência',
    AppLanguage.en   => 'Transparent permissions',
    AppLanguage.es   => 'Permisos con transparencia',
  };

  String get permissionsSubtitle => switch (lang) {
    AppLanguage.ptBr =>
      'O Apex Booster+ só pede o necessário para preparar melhor sua sessão.',
    AppLanguage.en   =>
      "Apex Booster+ only asks for what's needed to better prepare your session.",
    AppLanguage.es   =>
      'Apex Booster+ solo pide lo necesario para preparar mejor tu sesión.',
  };

  String get permissionsCardNotifTitle => switch (lang) {
    AppLanguage.ptBr => 'Notificações',
    AppLanguage.en   => 'Notifications',
    AppLanguage.es   => 'Notificaciones',
  };

  String get permissionsCardNotifSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Não solicitada nesta versão. Sem alertas automáticos.',
    AppLanguage.en   => 'Not requested in this version. No automatic alerts.',
    AppLanguage.es   => 'No solicitada en esta versión. Sin alertas automáticas.',
  };

  String get permissionsCardAppsTitle => switch (lang) {
    AppLanguage.ptBr => 'Apps instalados',
    AppLanguage.en   => 'Installed apps',
    AppLanguage.es   => 'Apps instaladas',
  };

  String get permissionsCardAppsSubtitle => switch (lang) {
    AppLanguage.ptBr =>
      'Usado futuramente para detectar jogos no aparelho. '
      'Você também poderá adicionar jogos manualmente.',
    AppLanguage.en   =>
      'Used in the future to detect games on the device. '
      'You can also add games manually.',
    AppLanguage.es   =>
      'Se usará en el futuro para detectar juegos en el dispositivo. '
      'También puedes agregar juegos manualmente.',
  };

  String get permissionsCardNetBadge => switch (lang) {
    AppLanguage.ptBr => 'REDE',
    AppLanguage.en   => 'NET',
    AppLanguage.es   => 'RED',
  };

  String get permissionsCardNetTitle => switch (lang) {
    AppLanguage.ptBr => 'Rede',
    AppLanguage.en   => 'Network',
    AppLanguage.es   => 'Red',
  };

  String get permissionsCardNetSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Usado para leitura de conexão e diagnóstico do Apex Scan.',
    AppLanguage.en   => 'Used for connection reading and Apex Scan diagnostic.',
    AppLanguage.es   => 'Usado para lectura de conexión y diagnóstico del Apex Scan.',
  };

  String get permissionsCardFocusTitle => switch (lang) {
    AppLanguage.ptBr => 'Foco',
    AppLanguage.en   => 'Focus',
    AppLanguage.es   => 'Foco',
  };

  String get permissionsCardFocusSubtitle => switch (lang) {
    AppLanguage.ptBr =>
      'O app pode orientar você a ativar modos de foco, '
      'mas não altera configurações sensíveis automaticamente.',
    AppLanguage.en   =>
      'The app can guide you to activate focus modes, '
      'but does not change sensitive settings automatically.',
    AppLanguage.es   =>
      'La app puede orientarte a activar modos de foco, '
      'pero no cambia ajustes sensibles automáticamente.',
  };

  String get permissionsTrustMessage => switch (lang) {
    AppLanguage.ptBr => 'Sem anúncios. Sem tracking. Sem promessa falsa de boost real.',
    AppLanguage.en   => 'No ads. No tracking. No false promises of real boost.',
    AppLanguage.es   => 'Sin anuncios. Sin seguimiento. Sin promesas falsas de boost real.',
  };

  String get permissionsCta => switch (lang) {
    AppLanguage.ptBr => 'CONTINUAR',
    AppLanguage.en   => 'CONTINUE',
    AppLanguage.es   => 'CONTINUAR',
  };

  // ─── Library / Biblioteca — LANG-U1.5 ────────────────────────────────────────

  String get libraryTitle => switch (lang) {
    AppLanguage.ptBr => 'Biblioteca',
    AppLanguage.en   => 'Library',
    AppLanguage.es   => 'Biblioteca',
  };

  String get librarySubtitle => switch (lang) {
    AppLanguage.ptBr => 'Seus jogos organizados em um só lugar.',
    AppLanguage.en   => 'Your games organized in one place.',
    AppLanguage.es   => 'Tus juegos organizados en un solo lugar.',
  };

  String get libraryAddGame => switch (lang) {
    AppLanguage.ptBr => 'ADICIONAR JOGO',
    AppLanguage.en   => 'ADD GAME',
    AppLanguage.es   => 'AGREGAR JUEGO',
  };

  String get libraryChooseInstalled => switch (lang) {
    AppLanguage.ptBr => 'ESCOLHER APP INSTALADO',
    AppLanguage.en   => 'CHOOSE INSTALLED APP',
    AppLanguage.es   => 'ELEGIR APP INSTALADO',
  };

  String get libraryEmptyTitle => switch (lang) {
    AppLanguage.ptBr => 'Nenhum jogo adicionado ainda.',
    AppLanguage.en   => 'No games added yet.',
    AppLanguage.es   => 'Ningún juego agregado aún.',
  };

  String get libraryEmptyDesc => switch (lang) {
    AppLanguage.ptBr =>
      'Toque em ADICIONAR JOGO para começar sua biblioteca gamer.',
    AppLanguage.en   =>
      'Tap ADD GAME to start your game library.',
    AppLanguage.es   =>
      'Toca AGREGAR JUEGO para comenzar tu biblioteca gamer.',
  };

  String libraryGameCount(int n) => switch (lang) {
    AppLanguage.ptBr =>
      '$n ${n == 1 ? 'jogo' : 'jogos'} na biblioteca',
    AppLanguage.en =>
      '$n ${n == 1 ? 'game' : 'games'} in library',
    AppLanguage.es =>
      '$n ${n == 1 ? 'juego' : 'juegos'} en la biblioteca',
  };

  String get libraryBadgeVerified => switch (lang) {
    AppLanguage.ptBr => 'JOGO',
    AppLanguage.en   => 'GAME',
    AppLanguage.es   => 'JUEGO',
  };

  String get libraryBadgeNotVerified => switch (lang) {
    AppLanguage.ptBr => 'Não verificado',
    AppLanguage.en   => 'Not verified',
    AppLanguage.es   => 'No verificado',
  };

  String get libraryToggleVerified => switch (lang) {
    AppLanguage.ptBr => 'Apenas jogos verificados',
    AppLanguage.en   => 'Verified games only',
    AppLanguage.es   => 'Solo juegos verificados',
  };

  String get libraryAlreadyAdded => switch (lang) {
    AppLanguage.ptBr => 'Já instalado',
    AppLanguage.en   => 'Already added',
    AppLanguage.es   => 'Ya agregado',
  };

  String get libraryOpenGame => switch (lang) {
    AppLanguage.ptBr => 'ABRIR JOGO',
    AppLanguage.en   => 'OPEN GAME',
    AppLanguage.es   => 'ABRIR JUEGO',
  };

  // Feature cards inside the library tab
  String get libraryFavBadge => 'FAV';

  String get libraryFavTitle => switch (lang) {
    AppLanguage.ptBr => 'Jogos favoritos',
    AppLanguage.en   => 'Favorite games',
    AppLanguage.es   => 'Juegos favoritos',
  };

  String get libraryFavSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Acesso rápido aos jogos que você mais usa.',
    AppLanguage.en   => 'Quick access to your most-used games.',
    AppLanguage.es   => 'Acceso rápido a los juegos que más usas.',
  };

  String get libraryGfxBadge => 'GFX';

  String get libraryLocalProfilesTitle => switch (lang) {
    AppLanguage.ptBr => 'Perfis locais',
    AppLanguage.en   => 'Local profiles',
    AppLanguage.es   => 'Perfiles locales',
  };

  String get libraryLocalProfilesSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Configure preferências GFX locais no detalhe de cada jogo.',
    AppLanguage.en   => "Set local GFX preferences in each game's detail.",
    AppLanguage.es   => 'Configura preferencias GFX locales en el detalle de cada juego.',
  };

  // Add game sheet
  String get libraryAddGameSheetTitle => switch (lang) {
    AppLanguage.ptBr => 'Adicionar jogo',
    AppLanguage.en   => 'Add game',
    AppLanguage.es   => 'Agregar juego',
  };

  String get libraryFieldGameName => switch (lang) {
    AppLanguage.ptBr => 'Nome do jogo',
    AppLanguage.en   => 'Game name',
    AppLanguage.es   => 'Nombre del juego',
  };

  String get libraryFieldPackageName => switch (lang) {
    AppLanguage.ptBr => 'Package name (opcional)',
    AppLanguage.en   => 'Package name (optional)',
    AppLanguage.es   => 'Package name (opcional)',
  };

  // Dialog/sheet action buttons (lowercase form used in dialogs)
  String get libraryCancelLower => switch (lang) {
    AppLanguage.ptBr => 'Cancelar',
    AppLanguage.en   => 'Cancel',
    AppLanguage.es   => 'Cancelar',
  };

  String get libraryActionAddLower => switch (lang) {
    AppLanguage.ptBr => 'Adicionar',
    AppLanguage.en   => 'Add',
    AppLanguage.es   => 'Agregar',
  };

  // Validation errors
  String get libraryValidationNameRequired => switch (lang) {
    AppLanguage.ptBr => 'Nome obrigatório',
    AppLanguage.en   => 'Name required',
    AppLanguage.es   => 'Nombre requerido',
  };

  String get libraryValidationAppNotFound => switch (lang) {
    AppLanguage.ptBr => 'App não encontrado nos instalados',
    AppLanguage.en   => 'App not found in installed apps',
    AppLanguage.es   => 'App no encontrado en apps instaladas',
  };

  // SnackBar when no app could be resolved (uses the label from libraryChooseInstalled)
  String get librarySnackNoApp => switch (lang) {
    AppLanguage.ptBr => "Nenhum app encontrado. Use 'ESCOLHER APP INSTALADO'.",
    AppLanguage.en   => "No app found. Use 'CHOOSE INSTALLED APP'.",
    AppLanguage.es   => "Ninguna app encontrada. Usa 'ELEGIR APP INSTALADO'.",
  };

  // Remove game dialog
  String get libraryRemoveTitle => switch (lang) {
    AppLanguage.ptBr => 'Remover jogo',
    AppLanguage.en   => 'Remove game',
    AppLanguage.es   => 'Eliminar juego',
  };

  String libraryRemoveConfirm(String name) => switch (lang) {
    AppLanguage.ptBr => 'Remover $name da biblioteca?',
    AppLanguage.en   => 'Remove $name from the library?',
    AppLanguage.es   => '¿Eliminar $name de la biblioteca?',
  };

  String get libraryActionRemove => switch (lang) {
    AppLanguage.ptBr => 'Remover',
    AppLanguage.en   => 'Remove',
    AppLanguage.es   => 'Eliminar',
  };

  // Not-verified game dialog
  String get libraryNotVerifiedTitle => switch (lang) {
    AppLanguage.ptBr => 'App não verificado como jogo',
    AppLanguage.en   => 'App not verified as game',
    AppLanguage.es   => 'App no verificado como juego',
  };

  String get libraryNotVerifiedContent => switch (lang) {
    AppLanguage.ptBr =>
      'Este app não foi identificado pelo Android como um jogo.\n'
      'Você ainda pode adicioná-lo à sua biblioteca.\n'
      'Adicionar mesmo assim?',
    AppLanguage.en =>
      'This app was not identified by Android as a game.\n'
      'You can still add it to your library.\n'
      'Add anyway?',
    AppLanguage.es =>
      'Esta app no fue identificada por Android como un juego.\n'
      'Aún puedes agregarla a tu biblioteca.\n'
      '¿Agregar de todos modos?',
  };

  String get libraryActionAddAnyway => switch (lang) {
    AppLanguage.ptBr => 'Adicionar mesmo assim',
    AppLanguage.en   => 'Add anyway',
    AppLanguage.es   => 'Agregar de todos modos',
  };

  // Multiple matches sheet (auto-link disambiguation)
  String get libraryMultiMatchTitle => switch (lang) {
    AppLanguage.ptBr => 'Mais de um app encontrado',
    AppLanguage.en   => 'Multiple apps found',
    AppLanguage.es   => 'Más de una app encontrada',
  };

  String get libraryMultiMatchSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Escolha qual app vincular ou continue como manual.',
    AppLanguage.en   => 'Choose which app to link or continue manually.',
    AppLanguage.es   => 'Elige qué app vincular o continúa manualmente.',
  };

  String get libraryContinueManual => switch (lang) {
    AppLanguage.ptBr => 'Continuar como manual',
    AppLanguage.en   => 'Continue manually',
    AppLanguage.es   => 'Continuar manualmente',
  };

  // ─── App Picker — LANG-U1.5A ─────────────────────────────────────────────────

  String get pickerTitle => switch (lang) {
    AppLanguage.ptBr => 'Escolher app instalado',
    AppLanguage.en   => 'Choose installed app',
    AppLanguage.es   => 'Elegir app instalado',
  };

  String get pickerSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Selecione o jogo instalado no seu dispositivo.',
    AppLanguage.en   => 'Select the game installed on your device.',
    AppLanguage.es   => 'Selecciona el juego instalado en tu dispositivo.',
  };

  String get pickerSearchHint => switch (lang) {
    AppLanguage.ptBr => 'Buscar por nome ou pacote',
    AppLanguage.en   => 'Search by name or package',
    AppLanguage.es   => 'Buscar por nombre o paquete',
  };

  String get pickerClearSearch => switch (lang) {
    AppLanguage.ptBr => 'Limpar busca',
    AppLanguage.en   => 'Clear search',
    AppLanguage.es   => 'Limpiar búsqueda',
  };

  String pickerNoResults(String query) => switch (lang) {
    AppLanguage.ptBr => 'Nenhum resultado para "$query".',
    AppLanguage.en   => 'No results for "$query".',
    AppLanguage.es   => 'Sin resultados para "$query".',
  };

  String get pickerNoResultsHint => switch (lang) {
    AppLanguage.ptBr => 'Tente outro nome ou use a entrada manual.',
    AppLanguage.en   => 'Try another name or use manual input.',
    AppLanguage.es   => 'Prueba otro nombre o usa la entrada manual.',
  };

  String get pickerNoApps => switch (lang) {
    AppLanguage.ptBr => 'Nenhum app instalado encontrado.',
    AppLanguage.en   => 'No installed apps found.',
    AppLanguage.es   => 'Ninguna app instalada encontrada.',
  };

  String get pickerNoAppsHint => switch (lang) {
    AppLanguage.ptBr => 'Use a entrada manual para adicionar o jogo.',
    AppLanguage.en   => 'Use manual input to add the game.',
    AppLanguage.es   => 'Usa la entrada manual para agregar el juego.',
  };

  String get pickerLoadError => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível carregar os apps instalados.',
    AppLanguage.en   => 'Could not load installed apps.',
    AppLanguage.es   => 'No se pudieron cargar las apps instaladas.',
  };

  String get pickerRetry => switch (lang) {
    AppLanguage.ptBr => 'Tentar novamente',
    AppLanguage.en   => 'Try again',
    AppLanguage.es   => 'Intentar de nuevo',
  };

  String get pickerUseManual => switch (lang) {
    AppLanguage.ptBr => 'Usar entrada manual',
    AppLanguage.en   => 'Use manual input',
    AppLanguage.es   => 'Usar entrada manual',
  };

  String get pickerNoGames => switch (lang) {
    AppLanguage.ptBr => 'Nenhum jogo verificado encontrado.',
    AppLanguage.en   => 'No verified games found.',
    AppLanguage.es   => 'No se encontraron juegos verificados.',
  };

  String get pickerNoGamesHint => switch (lang) {
    AppLanguage.ptBr => 'Desative o filtro para ver todos os apps instalados.',
    AppLanguage.en   => 'Disable the filter to see all installed apps.',
    AppLanguage.es   => 'Desactiva el filtro para ver todas las apps instaladas.',
  };

  // ─── Game Detail — LANG-U1.5 ─────────────────────────────────────────────────

  String get detailTitle => switch (lang) {
    AppLanguage.ptBr => 'Detalhe do Jogo',
    AppLanguage.en   => 'Game Detail',
    AppLanguage.es   => 'Detalle del Juego',
  };

  String get detailGfxProfileLabel => switch (lang) {
    AppLanguage.ptBr => 'Perfil GFX',
    AppLanguage.en   => 'GFX Profile',
    AppLanguage.es   => 'Perfil GFX',
  };

  String get detailNoProfile => switch (lang) {
    AppLanguage.ptBr => 'Nenhum perfil',
    AppLanguage.en   => 'No profile',
    AppLanguage.es   => 'Sin perfil',
  };

  String get detailOpenGame => switch (lang) {
    AppLanguage.ptBr => 'ABRIR JOGO',
    AppLanguage.en   => 'OPEN GAME',
    AppLanguage.es   => 'ABRIR JUEGO',
  };

  String get detailNotFoundTitle => switch (lang) {
    AppLanguage.ptBr => 'Jogo não encontrado',
    AppLanguage.en   => 'Game not found',
    AppLanguage.es   => 'Juego no encontrado',
  };

  String get detailNotFoundDesc => switch (lang) {
    AppLanguage.ptBr => 'Este jogo pode ter sido removido da biblioteca.',
    AppLanguage.en   => 'This game may have been removed from the library.',
    AppLanguage.es   => 'Este juego puede haber sido eliminado de la biblioteca.',
  };

  // Detail header & info rows
  String get detailPackageLabel => 'Package';

  String get detailNotConfigured => switch (lang) {
    AppLanguage.ptBr => 'Não configurado',
    AppLanguage.en   => 'Not configured',
    AppLanguage.es   => 'No configurado',
  };

  String get detailAddedAt => switch (lang) {
    AppLanguage.ptBr => 'Adicionado em',
    AppLanguage.en   => 'Added on',
    AppLanguage.es   => 'Agregado el',
  };

  String get detailUpdatedAt => switch (lang) {
    AppLanguage.ptBr => 'Atualizado em',
    AppLanguage.en   => 'Updated on',
    AppLanguage.es   => 'Actualizado el',
  };

  String get detailFavoriteBadge => switch (lang) {
    AppLanguage.ptBr => 'FAVORITO',
    AppLanguage.en   => 'FAVORITE',
    AppLanguage.es   => 'FAVORITO',
  };

  // GFX Profile action card
  String get detailGfxNoProfileDefined => switch (lang) {
    AppLanguage.ptBr => 'Nenhum perfil definido',
    AppLanguage.en   => 'No profile defined',
    AppLanguage.es   => 'Sin perfil definido',
  };

  String get detailGfxHint => switch (lang) {
    AppLanguage.ptBr => 'Toque para ajustar a preparação local',
    AppLanguage.en   => 'Tap to adjust local preparation',
    AppLanguage.es   => 'Toca para ajustar la preparación local',
  };

  String get detailGfxAdjust => switch (lang) {
    AppLanguage.ptBr => 'AJUSTAR',
    AppLanguage.en   => 'ADJUST',
    AppLanguage.es   => 'AJUSTAR',
  };

  // Edit dialog
  String get detailEditTitle => switch (lang) {
    AppLanguage.ptBr => 'Editar jogo',
    AppLanguage.en   => 'Edit game',
    AppLanguage.es   => 'Editar juego',
  };

  String get detailEditSave => switch (lang) {
    AppLanguage.ptBr => 'Salvar',
    AppLanguage.en   => 'Save',
    AppLanguage.es   => 'Guardar',
  };

  // Launch button
  String get detailNoAppLinked => switch (lang) {
    AppLanguage.ptBr => 'SEM APP VINCULADO',
    AppLanguage.en   => 'NO APP LINKED',
    AppLanguage.es   => 'SIN APP VINCULADO',
  };

  // Launch error messages
  String get detailAppNotFound => switch (lang) {
    AppLanguage.ptBr => 'App não encontrado. Verifique se ainda está instalado.',
    AppLanguage.en   => 'App not found. Check if it is still installed.',
    AppLanguage.es   => 'App no encontrado. Verifica si aún está instalado.',
  };

  String get detailOpenFailed => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível abrir o jogo.',
    AppLanguage.en   => 'Could not open the game.',
    AppLanguage.es   => 'No se pudo abrir el juego.',
  };

  // Apex Boost Mode steps
  String get detailProfileDefault => switch (lang) {
    AppLanguage.ptBr => 'padrão',
    AppLanguage.en   => 'default',
    AppLanguage.es   => 'predeterminado',
  };

  String get detailBoostStepGame => switch (lang) {
    AppLanguage.ptBr => 'Jogo localizado: OK',
    AppLanguage.en   => 'Game found: OK',
    AppLanguage.es   => 'Juego localizado: OK',
  };

  String detailBoostStepProfile(String label) => switch (lang) {
    AppLanguage.ptBr => 'Perfil $label: OK',
    AppLanguage.en   => 'Profile $label: OK',
    AppLanguage.es   => 'Perfil $label: OK',
  };

  String get detailBoostStepRoute => switch (lang) {
    AppLanguage.ptBr => 'Rota validada: OK',
    AppLanguage.en   => 'Route validated: OK',
    AppLanguage.es   => 'Ruta validada: OK',
  };

  String get detailBoostStepSession => switch (lang) {
    AppLanguage.ptBr => 'Sessão armada: OK',
    AppLanguage.en   => 'Session ready: OK',
    AppLanguage.es   => 'Sesión armada: OK',
  };

  String get detailBoostStepOpening => switch (lang) {
    AppLanguage.ptBr => 'Abrindo jogo...',
    AppLanguage.en   => 'Opening game...',
    AppLanguage.es   => 'Abriendo juego...',
  };

  // Apex Boost Mode — readiness chips (UX-P1.5)
  String get boostChipSessionReady => switch (lang) {
    AppLanguage.ptBr => 'Sessão preparada',
    AppLanguage.en   => 'Session ready',
    AppLanguage.es   => 'Sesión preparada',
  };

  // Apex Ritual Cinematográfico — subtitle and chips (PREMIUM-U2)
  String get boostSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Preparando sessão Apex.',
    AppLanguage.en   => 'Preparing Apex session.',
    AppLanguage.es   => 'Preparando sesión Apex.',
  };

  String get boostChipProfileLoaded => switch (lang) {
    AppLanguage.ptBr => 'Perfil carregado',
    AppLanguage.en   => 'Profile loaded',
    AppLanguage.es   => 'Perfil cargado',
  };

  // Apex Ritual Cinematográfico — step labels (PREMIUM-U2)
  String get ritualStepGameLock => switch (lang) {
    AppLanguage.ptBr => 'Jogo no alvo',
    AppLanguage.en   => 'Game on target',
    AppLanguage.es   => 'Juego en objetivo',
  };

  String ritualStepProfileLoad(String label) => switch (lang) {
    AppLanguage.ptBr => 'Perfil $label carregado',
    AppLanguage.en   => 'Profile $label loaded',
    AppLanguage.es   => 'Perfil $label cargado',
  };

  String get ritualStepProfileReady => switch (lang) {
    AppLanguage.ptBr => 'Preferências prontas',
    AppLanguage.en   => 'Preferences ready',
    AppLanguage.es   => 'Preferencias listas',
  };

  String get ritualStepFocusPrep => switch (lang) {
    AppLanguage.ptBr => 'Foco de sessão pronto',
    AppLanguage.en   => 'Session focus ready',
    AppLanguage.es   => 'Foco de sesión listo',
  };

  String get ritualStepApexScan => switch (lang) {
    AppLanguage.ptBr => 'Apex Scan: OK',
    AppLanguage.en   => 'Apex Scan: OK',
    AppLanguage.es   => 'Apex Scan: OK',
  };

  String get ritualStepVisualSync => switch (lang) {
    AppLanguage.ptBr => 'Sequência sincronizada',
    AppLanguage.en   => 'Sequence synced',
    AppLanguage.es   => 'Secuencia sincronizada',
  };

  String get ritualStepReadyState => switch (lang) {
    AppLanguage.ptBr => 'Abrindo com estilo...',
    AppLanguage.en   => 'Opening in style...',
    AppLanguage.es   => 'Abriendo con estilo...',
  };

  // Apex Scan card
  String get detailScanSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Status local da preparação',
    AppLanguage.en   => 'Local preparation status',
    AppLanguage.es   => 'Estado local de la preparación',
  };

  String get detailScanStatusReady => switch (lang) {
    AppLanguage.ptBr => 'Pronto para iniciar',
    AppLanguage.en   => 'Ready to start',
    AppLanguage.es   => 'Listo para iniciar',
  };

  String get detailScanStatusAppNotFound => switch (lang) {
    AppLanguage.ptBr => 'App não encontrado',
    AppLanguage.en   => 'App not found',
    AppLanguage.es   => 'App no encontrado',
  };

  String get detailScanStatusIncomplete => switch (lang) {
    AppLanguage.ptBr => 'Cadastro incompleto',
    AppLanguage.en   => 'Incomplete profile',
    AppLanguage.es   => 'Perfil incompleto',
  };

  String get detailScanStatusUnverified => switch (lang) {
    AppLanguage.ptBr => 'Não verificado',
    AppLanguage.en   => 'Not verified',
    AppLanguage.es   => 'No verificado',
  };

  // Preparation panel section (UX-P1.1 — honest visual prep indicators)
  String get detailModulesTitle => switch (lang) {
    AppLanguage.ptBr => 'PAINEL DE PREPARAÇÃO',
    AppLanguage.en   => 'PREPARATION PANEL',
    AppLanguage.es   => 'PANEL DE PREPARACIÓN',
  };

  String get detailModuleFps => 'FPS: OK';

  String get detailModuleRam => 'RAM: OK';

  String get detailModuleGpu => 'GPU: OK';

  String get detailModulePing => 'Ping: OK';

  String get detailModuleOptimization => switch (lang) {
    AppLanguage.ptBr => 'Otimização: OK',
    AppLanguage.en   => 'Optimization: OK',
    AppLanguage.es   => 'Optimización: OK',
  };

  String get detailModuleBoostApplied => switch (lang) {
    AppLanguage.ptBr => 'Boost aplicado',
    AppLanguage.en   => 'Boost applied',
    AppLanguage.es   => 'Boost aplicado',
  };

  String get detailModulePerfImproved => switch (lang) {
    AppLanguage.ptBr => 'Performance melhorada',
    AppLanguage.en   => 'Performance improved',
    AppLanguage.es   => 'Rendimiento mejorado',
  };

  // Real metrics section
  String get detailMetricsTitle => switch (lang) {
    AppLanguage.ptBr => 'MÉTRICAS REAIS',
    AppLanguage.en   => 'REAL METRICS',
    AppLanguage.es   => 'MÉTRICAS REALES',
  };

  String get detailMetricsSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Snapshot atual do dispositivo',
    AppLanguage.en   => 'Current device snapshot',
    AppLanguage.es   => 'Snapshot actual del dispositivo',
  };

  String get detailMetricsLoading => switch (lang) {
    AppLanguage.ptBr => 'Lendo métricas...',
    AppLanguage.en   => 'Reading metrics...',
    AppLanguage.es   => 'Leyendo métricas...',
  };

  String get detailMetricsUnavailable => switch (lang) {
    AppLanguage.ptBr => 'Métricas indisponíveis',
    AppLanguage.en   => 'Metrics unavailable',
    AppLanguage.es   => 'Métricas no disponibles',
  };

  String get detailLatencySubtitle => switch (lang) {
    AppLanguage.ptBr => 'Teste de rede',
    AppLanguage.en   => 'Network test',
    AppLanguage.es   => 'Prueba de red',
  };

  String get detailMemoryLow => switch (lang) {
    AppLanguage.ptBr => 'Memória baixa',
    AppLanguage.en   => 'Low memory',
    AppLanguage.es   => 'Memoria baja',
  };

  // Apex Scan check messages — GameDetailScreen (LANG-U1.5B)

  String get detailScanVinculoOk => switch (lang) {
    AppLanguage.ptBr => 'App vinculado ao cadastro',
    AppLanguage.en   => 'App linked to profile',
    AppLanguage.es   => 'App vinculado al perfil',
  };

  String get detailScanVinculoWarn => switch (lang) {
    AppLanguage.ptBr => 'Sem packageName — vínculo não confirmado',
    AppLanguage.en   => 'No packageName — link not confirmed',
    AppLanguage.es   => 'Sin packageName — vínculo no confirmado',
  };

  String get detailScanAcessoOk => switch (lang) {
    AppLanguage.ptBr => 'App instalado e acessível',
    AppLanguage.en   => 'App installed and accessible',
    AppLanguage.es   => 'App instalado y accesible',
  };

  String get detailScanAcessoWarn => switch (lang) {
    AppLanguage.ptBr => 'Acesso não verificado — sem packageName',
    AppLanguage.en   => 'Access not verified — no packageName',
    AppLanguage.es   => 'Acceso no verificado — sin packageName',
  };

  String get detailScanAcessoFail => switch (lang) {
    AppLanguage.ptBr => 'App não encontrado nos instalados',
    AppLanguage.en   => 'App not found in installed apps',
    AppLanguage.es   => 'App no encontrado en apps instaladas',
  };

  String get detailScanConsistenciaOk => switch (lang) {
    AppLanguage.ptBr => 'Cadastro consistente',
    AppLanguage.en   => 'Profile consistent',
    AppLanguage.es   => 'Perfil consistente',
  };

  String get detailScanConsistenciaInfo => switch (lang) {
    AppLanguage.ptBr => 'Configuração inicial',
    AppLanguage.en   => 'Initial setup',
    AppLanguage.es   => 'Configuración inicial',
  };

  /// Returns the translated message for a [ScanCheck] from [ApexScanService].
  ///
  /// Pass [profileLabel] (i.e. game.localProfileName) so the GFX profile check
  /// message is resolved correctly for the active language.
  String detailScanCheckMessage(ScanCheck check, {String? profileLabel}) {
    switch (check.id) {
      case 'vinculo':
        return check.status == ScanCheckStatus.ok
            ? detailScanVinculoOk
            : detailScanVinculoWarn;
      case 'acesso':
        return switch (check.status) {
          ScanCheckStatus.ok   => detailScanAcessoOk,
          ScanCheckStatus.warn => detailScanAcessoWarn,
          ScanCheckStatus.fail => detailScanAcessoFail,
          _                    => check.message,
        };
      case 'perfil':
        if (check.status == ScanCheckStatus.ok) {
          final profile = GfxProfile.fromLabel(profileLabel);
          if (profile != null) {
            return switch (profile) {
              GfxProfile.balanced    => prepGfxMsgBalanced,
              GfxProfile.performance => prepGfxMsgPerformance,
              GfxProfile.quality     => prepGfxMsgQuality,
              GfxProfile.economy     => prepGfxMsgEconomy,
            };
          }
        }
        return prepGfxMsgNone;
      case 'prioridade':
        return check.status == ScanCheckStatus.ok
            ? prepScanMsgPriorityOk
            : prepScanMsgPriorityInfo;
      case 'consistencia':
        return check.status == ScanCheckStatus.ok
            ? detailScanConsistenciaOk
            : detailScanConsistenciaInfo;
      default:
        return check.message;
    }
  }

  // ─── Social — Share Studio (SOCIAL-U1) ──────────────────────────────────────

  String get socialStudioTitle => 'Apex Studio';

  String get socialStudioSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Crie seu card gamer',
    AppLanguage.en   => 'Create your gamer card',
    AppLanguage.es   => 'Crea tu tarjeta gamer',
  };

  String get socialStudioCaption => switch (lang) {
    AppLanguage.ptBr => 'Legenda',
    AppLanguage.en   => 'Caption',
    AppLanguage.es   => 'Leyenda',
  };

  String get socialStudioCaptionHint => switch (lang) {
    AppLanguage.ptBr => 'Escreva sobre sua sessão...',
    AppLanguage.en   => 'Write about your session...',
    AppLanguage.es   => 'Escribe sobre tu sesión...',
  };

  String get socialStudioTemplate => switch (lang) {
    AppLanguage.ptBr => 'Tema',
    AppLanguage.en   => 'Theme',
    AppLanguage.es   => 'Tema',
  };

  String get socialStudioExport => switch (lang) {
    AppLanguage.ptBr => 'Exportar',
    AppLanguage.en   => 'Export',
    AppLanguage.es   => 'Exportar',
  };

  String get socialStudioPreview => switch (lang) {
    AppLanguage.ptBr => 'Prévia',
    AppLanguage.en   => 'Preview',
    AppLanguage.es   => 'Vista previa',
  };

  String get socialStudioWatermark => 'Prepared with Apex Booster+';

  String get socialStudioBadgeSection => switch (lang) {
    AppLanguage.ptBr => 'Badges',
    AppLanguage.en   => 'Badges',
    AppLanguage.es   => 'Insignias',
  };

  String get socialStudioNoBadge => switch (lang) {
    AppLanguage.ptBr => 'Sem badge',
    AppLanguage.en   => 'No badge',
    AppLanguage.es   => 'Sin insignia',
  };

  String get socialStudioCreateCard => switch (lang) {
    AppLanguage.ptBr => 'Criar card',
    AppLanguage.en   => 'Create card',
    AppLanguage.es   => 'Crear tarjeta',
  };

  String get socialStudioCreateCardHint => switch (lang) {
    AppLanguage.ptBr => 'Compartilhe sua evolução gamer',
    AppLanguage.en   => 'Share your gamer evolution',
    AppLanguage.es   => 'Comparte tu evolución gamer',
  };

  String get socialStudioSessionReady => switch (lang) {
    AppLanguage.ptBr => 'Sessão preparada',
    AppLanguage.en   => 'Session ready',
    AppLanguage.es   => 'Sesión lista',
  };

  String get socialTabTitle => switch (lang) {
    AppLanguage.ptBr => 'Apex Studio',
    AppLanguage.en   => 'Apex Studio',
    AppLanguage.es   => 'Apex Studio',
  };

  String get socialTabSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Capture, crie e compartilhe sua evolução gamer.',
    AppLanguage.en   => 'Capture, create, and share your gamer progress.',
    AppLanguage.es   => 'Captura, crea y comparte tu evolución gamer.',
  };

  String get socialTabCreateBadge => 'STUDIO';

  String get socialTabPickGameEmpty => switch (lang) {
    AppLanguage.ptBr => 'Adicione um jogo na Biblioteca para criar um card.',
    AppLanguage.en   => 'Add a game in Library to create a card.',
    AppLanguage.es   => 'Agrega un juego en la Biblioteca para crear una tarjeta.',
  };

  String get socialTabCreateNewCardCta => switch (lang) {
    AppLanguage.ptBr => 'Criar novo card',
    AppLanguage.en   => 'Create new card',
    AppLanguage.es   => 'Crear nueva tarjeta',
  };

  String get socialTabQuickAccessLabel => switch (lang) {
    AppLanguage.ptBr => 'Acesso rápido',
    AppLanguage.en   => 'Quick access',
    AppLanguage.es   => 'Acceso rápido',
  };

  String get socialTabChooseGameSheetTitle => switch (lang) {
    AppLanguage.ptBr => 'Escolher jogo',
    AppLanguage.en   => 'Choose game',
    AppLanguage.es   => 'Elegir juego',
  };

  String get socialTabChooseGameSheetSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Selecione o jogo para criar o card.',
    AppLanguage.en   => 'Select the game to create the card.',
    AppLanguage.es   => 'Selecciona el juego para crear la tarjeta.',
  };

  // ─── Social — Apex Studio media (SOCIAL-U1B) ─────────────────────────────────

  String get apexStudioMediaSection => switch (lang) {
    AppLanguage.ptBr => 'Mídia',
    AppLanguage.en   => 'Media',
    AppLanguage.es   => 'Media',
  };

  String get apexStudioAddMedia => switch (lang) {
    AppLanguage.ptBr => 'Adicionar print ou vídeo',
    AppLanguage.en   => 'Add screenshot or video',
    AppLanguage.es   => 'Agregar captura o video',
  };

  String get apexStudioAddMediaSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Foto ou vídeo da galeria',
    AppLanguage.en   => 'Photo or video from gallery',
    AppLanguage.es   => 'Foto o video de la galería',
  };

  String get apexStudioPickImage => switch (lang) {
    AppLanguage.ptBr => 'Selecionar imagem',
    AppLanguage.en   => 'Select image',
    AppLanguage.es   => 'Seleccionar imagen',
  };

  String get apexStudioPickVideo => switch (lang) {
    AppLanguage.ptBr => 'Selecionar vídeo',
    AppLanguage.en   => 'Select video',
    AppLanguage.es   => 'Seleccionar video',
  };

  String get apexStudioVideoLabel => switch (lang) {
    AppLanguage.ptBr => 'VÍDEO',
    AppLanguage.en   => 'VIDEO',
    AppLanguage.es   => 'VIDEO',
  };

  String get apexStudioImageSelected => switch (lang) {
    AppLanguage.ptBr => 'Imagem selecionada',
    AppLanguage.en   => 'Image selected',
    AppLanguage.es   => 'Imagen seleccionada',
  };

  String get apexStudioVideoSelected => switch (lang) {
    AppLanguage.ptBr => 'Vídeo selecionado',
    AppLanguage.en   => 'Video selected',
    AppLanguage.es   => 'Video seleccionado',
  };

  String get apexStudioChangeMedia => switch (lang) {
    AppLanguage.ptBr => 'Trocar mídia',
    AppLanguage.en   => 'Change media',
    AppLanguage.es   => 'Cambiar media',
  };

  String get apexStudioRemoveMedia => switch (lang) {
    AppLanguage.ptBr => 'Remover',
    AppLanguage.en   => 'Remove',
    AppLanguage.es   => 'Quitar',
  };

  String get apexStudioNoMediaHint => switch (lang) {
    AppLanguage.ptBr => 'Adicione um print ou vídeo para exportar',
    AppLanguage.en   => 'Add a screenshot or video to export',
    AppLanguage.es   => 'Agrega una imagen o video para exportar',
  };

  String get apexStudioVideoExportNotice => switch (lang) {
    AppLanguage.ptBr => 'O card usa a imagem do vídeo. Vídeo com moldura animada será fase futura.',
    AppLanguage.en   => 'The card uses a still from your video. Animated video framing will be a future phase.',
    AppLanguage.es   => 'La tarjeta usa una imagen del video. El video con marco animado será una fase futura.',
  };

  String get apexStudioGenerateCardLabel => switch (lang) {
    AppLanguage.ptBr => 'Gerar card',
    AppLanguage.en   => 'Generate card',
    AppLanguage.es   => 'Generar tarjeta',
  };

  String get apexStudioShareOriginalClipLabel => switch (lang) {
    AppLanguage.ptBr => 'Compartilhar clipe original',
    AppLanguage.en   => 'Share original clip',
    AppLanguage.es   => 'Compartir clip original',
  };

  String get apexStudioVideoMissingError => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível encontrar o vídeo capturado.',
    AppLanguage.en   => 'Could not find the captured video.',
    AppLanguage.es   => 'No se pudo encontrar el video capturado.',
  };

  String get apexStudioMediaError => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível acessar a galeria neste dispositivo.',
    AppLanguage.en   => 'Could not access the gallery on this device.',
    AppLanguage.es   => 'No se pudo acceder a la galería en este dispositivo.',
  };

  String get apexStudioFitFill => switch (lang) {
    AppLanguage.ptBr => 'Preencher',
    AppLanguage.en   => 'Fill',
    AppLanguage.es   => 'Rellenar',
  };

  String get apexStudioFitContain => switch (lang) {
    AppLanguage.ptBr => 'Encaixar',
    AppLanguage.en   => 'Fit',
    AppLanguage.es   => 'Ajustar',
  };

  String get apexStudioVideoPreviewLabel => switch (lang) {
    AppLanguage.ptBr => 'Prévia de vídeo',
    AppLanguage.en   => 'Video preview',
    AppLanguage.es   => 'Vista previa de video',
  };

  String get apexStudioPickApexCapture => switch (lang) {
    AppLanguage.ptBr => 'Capturas do Apex',
    AppLanguage.en   => 'Apex captures',
    AppLanguage.es   => 'Capturas de Apex',
  };

  String get apexStudioCapturesSheetTitle => switch (lang) {
    AppLanguage.ptBr => 'Selecionar captura',
    AppLanguage.en   => 'Select capture',
    AppLanguage.es   => 'Seleccionar captura',
  };

  String get apexStudioCapturesEmpty => switch (lang) {
    AppLanguage.ptBr =>
        'Nenhuma captura disponível ainda. Capture pela tela do jogo com o botão flutuante A+.',
    AppLanguage.en   =>
        'No captures available yet. Capture from the game screen using the floating A+ button.',
    AppLanguage.es   =>
        'Aún no hay capturas disponibles. Captura desde la pantalla del juego con el botón flotante A+.',
  };

  String get apexStudioCapturesSheetSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Capturas feitas com o botão A+',
    AppLanguage.en   => 'Captures taken with the A+ button',
    AppLanguage.es   => 'Capturas hechas con el botón A+',
  };

  String get apexStudioCaptureMostRecent => switch (lang) {
    AppLanguage.ptBr => 'MAIS RECENTE',
    AppLanguage.en   => 'MOST RECENT',
    AppLanguage.es   => 'MÁS RECIENTE',
  };

  String get apexStudioDeleteCaptureTitle => switch (lang) {
    AppLanguage.ptBr => 'Excluir captura?',
    AppLanguage.en   => 'Delete screenshot?',
    AppLanguage.es   => '¿Eliminar captura?',
  };

  String get apexStudioDeleteVideoTitle => switch (lang) {
    AppLanguage.ptBr => 'Excluir vídeo?',
    AppLanguage.en   => 'Delete video?',
    AppLanguage.es   => '¿Eliminar video?',
  };

  String get apexStudioDeleteDialogContent => switch (lang) {
    AppLanguage.ptBr => 'Esta ação não pode ser desfeita.',
    AppLanguage.en   => 'This action cannot be undone.',
    AppLanguage.es   => 'Esta acción no se puede deshacer.',
  };

  String get apexStudioDeleteConfirm => switch (lang) {
    AppLanguage.ptBr => 'EXCLUIR',
    AppLanguage.en   => 'DELETE',
    AppLanguage.es   => 'ELIMINAR',
  };

  String get apexStudioDeleteTooltip => switch (lang) {
    AppLanguage.ptBr => 'Excluir',
    AppLanguage.en   => 'Delete',
    AppLanguage.es   => 'Eliminar',
  };

  String get apexStudioDeleteError => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível excluir. Tente novamente.',
    AppLanguage.en   => 'Could not delete. Please try again.',
    AppLanguage.es   => 'No se pudo eliminar. Inténtalo de nuevo.',
  };

  String get apexStudioSessionNameSection => switch (lang) {
    AppLanguage.ptBr => 'Nome',
    AppLanguage.en   => 'Name',
    AppLanguage.es   => 'Nombre',
  };

  String get apexStudioSessionNameHint => switch (lang) {
    AppLanguage.ptBr => 'Nome do jogo ou da sessão',
    AppLanguage.en   => 'Game or session name',
    AppLanguage.es   => 'Nombre del juego o de la sesión',
  };

  String get apexStudioSessionNameFallback => switch (lang) {
    AppLanguage.ptBr => 'Sessão gamer',
    AppLanguage.en   => 'Gamer session',
    AppLanguage.es   => 'Sesión gamer',
  };

  // ─── Social — Export Presets ─────────────────────────────────────────────────

  String get socialPresetPortrait => switch (lang) {
    AppLanguage.ptBr => '9:16 · TikTok / Reels',
    AppLanguage.en   => '9:16 · TikTok / Reels',
    AppLanguage.es   => '9:16 · TikTok / Reels',
  };

  String get socialPresetSquare => switch (lang) {
    AppLanguage.ptBr => '1:1 · Feed',
    AppLanguage.en   => '1:1 · Feed',
    AppLanguage.es   => '1:1 · Feed',
  };

  String get socialPresetLandscape => switch (lang) {
    AppLanguage.ptBr => '16:9 · YouTube',
    AppLanguage.en   => '16:9 · YouTube',
    AppLanguage.es   => '16:9 · YouTube',
  };

  // ─── Social — Privacy Guard ──────────────────────────────────────────────────

  String get privacyGuardTitle => switch (lang) {
    AppLanguage.ptBr => 'Revisar antes de compartilhar',
    AppLanguage.en   => 'Review before sharing',
    AppLanguage.es   => 'Revisar antes de compartir',
  };

  String get privacyGuardBody => switch (lang) {
    AppLanguage.ptBr => 'A mídia selecionada fica apenas no seu dispositivo. Você revisa e escolhe onde compartilhar.',
    AppLanguage.en   => 'Selected media stays on your device only. You review and choose where to share.',
    AppLanguage.es   => 'El contenido seleccionado queda solo en tu dispositivo. Revisas y eliges dónde compartir.',
  };

  String get privacyGuardNoAutoPost => switch (lang) {
    AppLanguage.ptBr => 'O Apex nunca posta por você.',
    AppLanguage.en   => 'Apex never posts for you.',
    AppLanguage.es   => 'Apex nunca publica por ti.',
  };

  String get privacyGuardConfirm => switch (lang) {
    AppLanguage.ptBr => 'Exportar',
    AppLanguage.en   => 'Export',
    AppLanguage.es   => 'Exportar',
  };

  String get privacyGuardCancel => switch (lang) {
    AppLanguage.ptBr => 'Cancelar',
    AppLanguage.en   => 'Cancel',
    AppLanguage.es   => 'Cancelar',
  };

  // ─── Social — Evolution Card (SOCIAL-U2) ────────────────────────────────────

  String get evolutionCardTitle => switch (lang) {
    AppLanguage.ptBr => 'Sua jornada no Apex',
    AppLanguage.en   => 'Your Apex Journey',
    AppLanguage.es   => 'Tu camino en Apex',
  };

  String get evolutionCardSessions => switch (lang) {
    AppLanguage.ptBr => 'sessões preparadas',
    AppLanguage.en   => 'sessions prepared',
    AppLanguage.es   => 'sesiones preparadas',
  };

  String get evolutionCardFavorite => switch (lang) {
    AppLanguage.ptBr => 'Jogo favorito',
    AppLanguage.en   => 'Favorite game',
    AppLanguage.es   => 'Juego favorito',
  };

  String get evolutionCardStreak => switch (lang) {
    AppLanguage.ptBr => 'sequência atual',
    AppLanguage.en   => 'current streak',
    AppLanguage.es   => 'racha actual',
  };

  String get evolutionCardShare => switch (lang) {
    AppLanguage.ptBr => 'Compartilhar evolução',
    AppLanguage.en   => 'Share evolution',
    AppLanguage.es   => 'Compartir evolución',
  };

  // ─── Social — Floating Capture Button (SOCIAL-U6) ───────────────────────────

  String get floatingCaptureEnable => switch (lang) {
    AppLanguage.ptBr => 'Ativar botão de captura',
    AppLanguage.en   => 'Enable capture button',
    AppLanguage.es   => 'Activar botón de captura',
  };

  String get floatingCaptureTitle => switch (lang) {
    AppLanguage.ptBr => 'Capturar momento',
    AppLanguage.en   => 'Capture moment',
    AppLanguage.es   => 'Capturar momento',
  };

  String get floatingCaptureClip => switch (lang) {
    AppLanguage.ptBr => 'Marcar clipe',
    AppLanguage.en   => 'Mark clip',
    AppLanguage.es   => 'Marcar clip',
  };

  String get floatingCaptureDisable => switch (lang) {
    AppLanguage.ptBr => 'Desativar botão',
    AppLanguage.en   => 'Disable button',
    AppLanguage.es   => 'Desactivar botón',
  };

  String get floatingCaptureOptInTitle => switch (lang) {
    AppLanguage.ptBr => 'Botão flutuante de captura',
    AppLanguage.en   => 'Floating capture button',
    AppLanguage.es   => 'Botón flotante de captura',
  };

  String get floatingCaptureOptInBody => switch (lang) {
    AppLanguage.ptBr =>
      'Este botão aparece sobre outros apps quando ativado. '
      'Você pode desativar a qualquer momento.',
    AppLanguage.en =>
      'This button appears over other apps when enabled. '
      'You can disable it at any time.',
    AppLanguage.es =>
      'Este botón aparece sobre otras apps cuando está activado. '
      'Puedes desactivarlo en cualquier momento.',
  };

  String get floatingCapturePermission => switch (lang) {
    AppLanguage.ptBr =>
      'Para mostrar o botão durante jogos, é preciso permissão de sobreposição.',
    AppLanguage.en =>
      'To show the button during games, overlay permission is required.',
    AppLanguage.es =>
      'Para mostrar el botón durante juegos, se requiere permiso de superposición.',
  };

  // ─── Social — Floating Capture (SOCIAL-U2A) ──────────────────────────────────

  // Card em Configurações
  String get captureFloatBadge => 'STUDIO';

  String get captureFloatCardTitle => switch (lang) {
    AppLanguage.ptBr => 'Modo Captura da Sessão',
    AppLanguage.en   => 'Session Capture Mode',
    AppLanguage.es   => 'Modo de Captura de Sesión',
  };

  String get captureFloatCardSubtitle => switch (lang) {
    AppLanguage.ptBr =>
        'Ative antes de abrir o jogo. O botão A+ aparece sobre a tela para '
        'você capturar quando quiser.',
    AppLanguage.en =>
        'Turn it on before opening the game. The A+ button appears over the '
        'screen so you can capture anytime.',
    AppLanguage.es =>
        'Actívalo antes de abrir el juego. El botón A+ aparece sobre la '
        'pantalla para que captures cuando quieras.',
  };

  String get captureFloatCardEnabled => switch (lang) {
    AppLanguage.ptBr => 'Ativo',
    AppLanguage.en   => 'Active',
    AppLanguage.es   => 'Activo',
  };

  String get captureFloatCardDisabled => switch (lang) {
    AppLanguage.ptBr => 'Inativo',
    AppLanguage.en   => 'Inactive',
    AppLanguage.es   => 'Inactivo',
  };

  String get captureFloatCardPermRequired => switch (lang) {
    AppLanguage.ptBr => 'Permissão de sobreposição necessária',
    AppLanguage.en   => 'Overlay permission required',
    AppLanguage.es   => 'Permiso de superposición necesario',
  };

  String get captureFloatCardOpenSettings => switch (lang) {
    AppLanguage.ptBr => 'Abrir configurações',
    AppLanguage.en   => 'Open settings',
    AppLanguage.es   => 'Abrir configuración',
  };

  String get captureFloatCardFooterNote => switch (lang) {
    AppLanguage.ptBr =>
        'Ao capturar, a sessão encerra e a imagem vai para o Apex Studio.',
    AppLanguage.en =>
        'After you capture, the session ends and the image goes to Apex '
        'Studio.',
    AppLanguage.es =>
        'Al capturar, la sesión termina y la imagen va al Apex Studio.',
  };

  // SOCIAL-U7A (Opção B): seletor de modo antes de armar a sessão.
  String get captureModeDialogTitle => switch (lang) {
    AppLanguage.ptBr => 'Escolha o modo de captura',
    AppLanguage.en   => 'Choose capture mode',
    AppLanguage.es   => 'Elige el modo de captura',
  };

  String get captureModeScreenshotOption => switch (lang) {
    AppLanguage.ptBr => 'Print da tela',
    AppLanguage.en   => 'Screenshot',
    AppLanguage.es   => 'Captura de pantalla',
  };

  String get captureModeScreenshotSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Captura uma imagem por toque.',
    AppLanguage.en   => 'Captures one image per tap.',
    AppLanguage.es   => 'Captura una imagen por toque.',
  };

  String get captureModeVideoOption => switch (lang) {
    AppLanguage.ptBr => 'Vídeo curto',
    AppLanguage.en   => 'Short video',
    AppLanguage.es   => 'Video corto',
  };

  String get captureModeVideoSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Escolha a duração e grave sem áudio.',
    AppLanguage.en   => 'Choose the duration and record without audio.',
    AppLanguage.es   => 'Elige la duración y graba sin audio.',
  };

  // SOCIAL-U7B: duração configurável do vídeo curto.
  String get videoDurationDialogTitle => switch (lang) {
    AppLanguage.ptBr => 'Escolha a duração do vídeo',
    AppLanguage.en   => 'Choose the video duration',
    AppLanguage.es   => 'Elige la duración del video',
  };

  String videoDurationOptionLabel(int seconds) => switch (lang) {
    AppLanguage.ptBr => '$seconds segundos',
    AppLanguage.en   => '$seconds seconds',
    AppLanguage.es   => '$seconds segundos',
  };

  // Consent sheet
  String get captureConsentTitle => switch (lang) {
    AppLanguage.ptBr => 'Captura Flutuante Apex',
    AppLanguage.en   => 'Apex Floating Capture',
    AppLanguage.es   => 'Captura Flotante Apex',
  };

  String get captureConsentBody => switch (lang) {
    AppLanguage.ptBr =>
        'Use o botão flutuante para acessar rapidamente suas mídias durante '
        'a sessão gamer. Você escolhe o print ou vídeo que deseja usar no '
        'Apex Studio. Nada é capturado ou compartilhado automaticamente.',
    AppLanguage.en =>
        'Use the floating button to quickly access your media during gaming '
        'sessions. You choose the screenshot or video to use in Apex Studio. '
        'Nothing is captured or shared automatically.',
    AppLanguage.es =>
        'Usa el botón flotante para acceder rápidamente a tus medios durante '
        'la sesión gamer. Tú eliges la captura o el video que quieres usar en '
        'Apex Studio. Nada se captura ni comparte automáticamente.',
  };

  String get captureConsentPermNote => switch (lang) {
    AppLanguage.ptBr =>
        'Este recurso precisa de permissão para exibir sobre outros apps.',
    AppLanguage.en =>
        'This feature needs permission to display over other apps.',
    AppLanguage.es =>
        'Esta función necesita permiso para mostrarse sobre otras apps.',
  };

  String get captureConsentActivate => switch (lang) {
    AppLanguage.ptBr => 'Ativar',
    AppLanguage.en   => 'Activate',
    AppLanguage.es   => 'Activar',
  };

  String get captureConsentPermDenied => switch (lang) {
    AppLanguage.ptBr =>
        'Permissão necessária. Ative em Configurações › Apps › Aparência na tela.',
    AppLanguage.en =>
        'Permission required. Enable it in Settings › Apps › Appear on screen.',
    AppLanguage.es =>
        'Permiso necesario. Actívalo en Configuración › Apps › Aparecer en pantalla.',
  };

  // Mini-overlay (cópia espelho; overlay engine usa strings hardcoded por engine separada)
  String get captureOverlayOpenGallery => switch (lang) {
    AppLanguage.ptBr => 'Adicionar print ou vídeo',
    AppLanguage.en   => 'Add screenshot or video',
    AppLanguage.es   => 'Agregar captura o video',
  };

  String get captureOverlayOpenStudio => switch (lang) {
    AppLanguage.ptBr => 'Voltar ao Apex Studio',
    AppLanguage.en   => 'Back to Apex Studio',
    AppLanguage.es   => 'Volver a Apex Studio',
  };

  // ─── Screen capture (SOCIAL-U2B) ─────────────────────────────────────────────

  String get captureScreenTitle => switch (lang) {
    AppLanguage.ptBr => 'Capturar tela agora?',
    AppLanguage.en   => 'Capture screen now?',
    AppLanguage.es   => '¿Capturar pantalla ahora?',
  };

  String get captureScreenSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Um print será salvo localmente. Nada é enviado automaticamente.',
    AppLanguage.en   => 'A screenshot will be saved locally. Nothing is sent automatically.',
    AppLanguage.es   => 'Se guardará una captura localmente. Nada se envía automáticamente.',
  };

  String get captureScreenButton => switch (lang) {
    AppLanguage.ptBr => 'CAPTURAR',
    AppLanguage.en   => 'CAPTURE',
    AppLanguage.es   => 'CAPTURAR',
  };

  String get captureScreenResultTitle => switch (lang) {
    AppLanguage.ptBr => 'Print capturado',
    AppLanguage.en   => 'Screenshot captured',
    AppLanguage.es   => 'Captura guardada',
  };

  String get captureScreenShareButton => switch (lang) {
    AppLanguage.ptBr => 'COMPARTILHAR',
    AppLanguage.en   => 'SHARE',
    AppLanguage.es   => 'COMPARTIR',
  };

  String get captureScreenDiscardButton => switch (lang) {
    AppLanguage.ptBr => 'DESCARTAR',
    AppLanguage.en   => 'DISCARD',
    AppLanguage.es   => 'DESCARTAR',
  };

  String get captureScreenDenied => switch (lang) {
    AppLanguage.ptBr => 'Permissão de captura negada.',
    AppLanguage.en   => 'Capture permission denied.',
    AppLanguage.es   => 'Permiso de captura denegado.',
  };

  String get captureScreenError => switch (lang) {
    AppLanguage.ptBr => 'Erro ao capturar tela.',
    AppLanguage.en   => 'Error capturing screen.',
    AppLanguage.es   => 'Error al capturar pantalla.',
  };

  String get captureScreenSystemNote => switch (lang) {
    AppLanguage.ptBr =>
        'O sistema Android solicitará sua confirmação antes de capturar.',
    AppLanguage.en   =>
        'Android will ask for your confirmation before capturing.',
    AppLanguage.es   =>
        'Android solicitará tu confirmación antes de capturar.',
  };

  // ─── Apex Result Card (PREMIUM-U3A) ───────────────────────────────────────

  String get resultCardHeaderLabel => switch (lang) {
    AppLanguage.ptBr => 'RESULTADO DA SESSÃO',
    AppLanguage.en   => 'SESSION RESULT',
    AppLanguage.es   => 'RESULTADO DE LA SESIÓN',
  };

  String get resultCardSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Sessão preparada localmente.',
    AppLanguage.en   => 'Session prepared locally.',
    AppLanguage.es   => 'Sesión preparada localmente.',
  };

  String get resultCardSectionPreparation => switch (lang) {
    AppLanguage.ptBr => 'PREPARAÇÃO APEX',
    AppLanguage.en   => 'APEX PREPARATION',
    AppLanguage.es   => 'PREPARACIÓN APEX',
  };

  String get resultCardProfileLabel => switch (lang) {
    AppLanguage.ptBr => 'Perfil aplicado',
    AppLanguage.en   => 'Profile applied',
    AppLanguage.es   => 'Perfil aplicado',
  };

  String get resultCardMetricsUnavailable => switch (lang) {
    AppLanguage.ptBr => 'Métricas não disponíveis nesta sessão.',
    AppLanguage.en   => 'Metrics not available for this session.',
    AppLanguage.es   => 'Métricas no disponibles en esta sesión.',
  };

  String get resultCardTimestampPrefix => switch (lang) {
    AppLanguage.ptBr => 'Preparado em',
    AppLanguage.en   => 'Prepared on',
    AppLanguage.es   => 'Preparado el',
  };

  String get resultCardCtaReopen => switch (lang) {
    AppLanguage.ptBr => 'Abrir jogo novamente',
    AppLanguage.en   => 'Open game again',
    AppLanguage.es   => 'Abrir juego de nuevo',
  };

  String get resultCardCtaShare => switch (lang) {
    AppLanguage.ptBr => 'Criar card social',
    AppLanguage.en   => 'Create social card',
    AppLanguage.es   => 'Crear card social',
  };

  String get resultCardErrorTitle => switch (lang) {
    AppLanguage.ptBr => 'Sessão não encontrada',
    AppLanguage.en   => 'Session not found',
    AppLanguage.es   => 'Sesión no encontrada',
  };

  String get resultCardErrorDesc => switch (lang) {
    AppLanguage.ptBr => 'Não encontramos os dados dessa sessão.',
    AppLanguage.en   => 'We could not find data for this session.',
    AppLanguage.es   => 'No encontramos los datos de esta sesión.',
  };

  String get sessionReadySnackMessage => switch (lang) {
    AppLanguage.ptBr => 'Sessão preparada.',
    AppLanguage.en   => 'Session prepared.',
    AppLanguage.es   => 'Sesión preparada.',
  };

  String get sessionReadySnackAction => switch (lang) {
    AppLanguage.ptBr => 'Ver card',
    AppLanguage.en   => 'View card',
    AppLanguage.es   => 'Ver tarjeta',
  };

  // ─── Unlock / Desbloqueio único (BILL-U1B) ────────────────────────────────────

  String get unlockCardTitle => switch (lang) {
    AppLanguage.ptBr => 'Desbloqueio único',
    AppLanguage.en   => 'One-time unlock',
    AppLanguage.es   => 'Desbloqueo único',
  };

  String get unlockCardSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Compra única, sem assinatura',
    AppLanguage.en   => 'One-time purchase, no subscription',
    AppLanguage.es   => 'Compra única, sin suscripción',
  };

  String get unlockCardAction => switch (lang) {
    AppLanguage.ptBr => 'Ver desbloqueio',
    AppLanguage.en   => 'View unlock',
    AppLanguage.es   => 'Ver desbloqueo',
  };

  String get unlockScreenTitle => switch (lang) {
    AppLanguage.ptBr => 'Desbloqueio Apex Booster+',
    AppLanguage.en   => 'Apex Booster+ Unlock',
    AppLanguage.es   => 'Desbloqueo Apex Booster+',
  };

  String get unlockBenefitsLabel => switch (lang) {
    AppLanguage.ptBr => 'O que você desbloqueia',
    AppLanguage.en   => 'What you unlock',
    AppLanguage.es   => 'Qué desbloqueas',
  };

  String get unlockBenefit1 => switch (lang) {
    AppLanguage.ptBr => 'Acesso completo ao Apex Studio e captura de momentos',
    AppLanguage.en   => 'Full access to Apex Studio and moment capture',
    AppLanguage.es   => 'Acceso completo a Apex Studio y captura de momentos',
  };

  String get unlockBenefit2 => switch (lang) {
    AppLanguage.ptBr => 'Perfis GFX ilimitados por jogo',
    AppLanguage.en   => 'Unlimited GFX profiles per game',
    AppLanguage.es   => 'Perfiles GFX ilimitados por juego',
  };

  String get unlockBenefit3 => switch (lang) {
    AppLanguage.ptBr => 'Apoia o desenvolvimento contínuo do app',
    AppLanguage.en   => 'Supports the app\'s ongoing development',
    AppLanguage.es   => 'Apoya el desarrollo continuo de la app',
  };

  String get unlockPriceLabel => switch (lang) {
    AppLanguage.ptBr => 'R\$ 2,99 (preço informativo)',
    AppLanguage.en   => 'US\$ 2.99 (informational price)',
    AppLanguage.es   => 'US\$ 2.99 (precio informativo)',
  };

  String get unlockPriceNote => switch (lang) {
    AppLanguage.ptBr => 'Valor final definido pela loja no momento da compra.',
    AppLanguage.en   => 'Final price is set by the store at purchase time.',
    AppLanguage.es   => 'El precio final lo define la tienda al momento de la compra.',
  };

  String get unlockBuyButton => switch (lang) {
    AppLanguage.ptBr => 'Desbloquear agora',
    AppLanguage.en   => 'Unlock now',
    AppLanguage.es   => 'Desbloquear ahora',
  };

  String get unlockRestoreButton => switch (lang) {
    AppLanguage.ptBr => 'Restaurar compra',
    AppLanguage.en   => 'Restore purchase',
    AppLanguage.es   => 'Restaurar compra',
  };

  String get unlockUnlockedTitle => switch (lang) {
    AppLanguage.ptBr => 'Desbloqueado',
    AppLanguage.en   => 'Unlocked',
    AppLanguage.es   => 'Desbloqueado',
  };

  String get unlockUnlockedDesc => switch (lang) {
    AppLanguage.ptBr => 'Obrigado por apoiar o Apex Booster+. Todos os recursos premium estão liberados.',
    AppLanguage.en   => 'Thank you for supporting Apex Booster+. All premium features are unlocked.',
    AppLanguage.es   => 'Gracias por apoyar Apex Booster+. Todas las funciones premium están desbloqueadas.',
  };

  String get unlockUnavailableTitle => switch (lang) {
    AppLanguage.ptBr => 'Loja indisponível',
    AppLanguage.en   => 'Store unavailable',
    AppLanguage.es   => 'Tienda no disponible',
  };

  String get unlockUnavailableDesc => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível conectar à loja agora. Tente novamente mais tarde.',
    AppLanguage.en   => 'We could not reach the store right now. Please try again later.',
    AppLanguage.es   => 'No pudimos conectar con la tienda ahora. Inténtalo de nuevo más tarde.',
  };

  String get unlockErrorTitle => switch (lang) {
    AppLanguage.ptBr => 'Algo deu errado',
    AppLanguage.en   => 'Something went wrong',
    AppLanguage.es   => 'Algo salió mal',
  };

  String get unlockErrorDesc => switch (lang) {
    AppLanguage.ptBr => 'Não foi possível concluir a compra. Tente novamente.',
    AppLanguage.en   => 'We could not complete the purchase. Please try again.',
    AppLanguage.es   => 'No pudimos completar la compra. Inténtalo de nuevo.',
  };

  String get unlockRestoreSuccess => switch (lang) {
    AppLanguage.ptBr => 'Compra restaurada com sucesso.',
    AppLanguage.en   => 'Purchase restored successfully.',
    AppLanguage.es   => 'Compra restaurada con éxito.',
  };

  String get unlockRestoreNotFound => switch (lang) {
    AppLanguage.ptBr => 'Nenhuma compra encontrada para restaurar.',
    AppLanguage.en   => 'No previous purchase found to restore.',
    AppLanguage.es   => 'No se encontró ninguna compra para restaurar.',
  };

  String get unlockDisclaimer => switch (lang) {
    AppLanguage.ptBr => 'Desbloqueio único de recursos do app. Não altera desempenho de jogos de terceiros.',
    AppLanguage.en   => 'One-time unlock of app features. Does not alter third-party game performance.',
    AppLanguage.es   => 'Desbloqueo único de funciones de la app. No altera el rendimiento de juegos de terceros.',
  };
}

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

  String get prepDisclaimer1 => switch (lang) {
    AppLanguage.ptBr => 'Snapshot local. Sem alteração automática de desempenho.',
    AppLanguage.en   => 'Local snapshot. No automatic performance change.',
    AppLanguage.es   => 'Snapshot local. Sin cambio automático de rendimiento.',
  };

  String get prepDisclaimer2 => switch (lang) {
    AppLanguage.ptBr =>
      'Snapshot local. Não representa alteração automática no jogo.',
    AppLanguage.en   =>
      'Local snapshot. Does not represent automatic in-game change.',
    AppLanguage.es   =>
      'Snapshot local. No representa cambio automático en el juego.',
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

  String get snapshotDisclaimer => switch (lang) {
    AppLanguage.ptBr =>
      'Snapshot do dispositivo. Não representa alteração de jogos.',
    AppLanguage.en   =>
      'Device snapshot. Does not represent any game changes.',
    AppLanguage.es   =>
      'Snapshot del dispositivo. No representa cambios en juegos.',
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

  // ─── Game Detail — LANG-U1.5 ─────────────────────────────────────────────────

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
}

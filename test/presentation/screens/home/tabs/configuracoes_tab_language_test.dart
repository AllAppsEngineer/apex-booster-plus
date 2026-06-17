import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/configuracoes_tab.dart';


// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _wrapConfig() => ListenableBuilder(
      listenable: languageNotifier,
      builder: (_, __) =>
          const MaterialApp(home: Scaffold(body: ConfiguracoesTab())),
    );

/// Minimal widget that renders ONLY a BottomNav with AppStrings labels,
/// isolated from HomeScreen's complex tab initialization (network calls, etc.).
/// Tests that AppStrings.navXxx returns correct translations per language
/// and that ListenableBuilder rebuilds on languageNotifier changes.
Widget _wrapBottomNavLabels() => ListenableBuilder(
      listenable: languageNotifier,
      builder: (_, __) {
        final s = AppStrings(languageNotifier.value);
        return MaterialApp(
          home: Scaffold(
            body: const SizedBox.shrink(),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              onTap: (_) {},
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  label: s.navHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.sports_esports_outlined),
                  label: s.navLibrary,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.flash_on_outlined),
                  label: s.navPrepare,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.history_outlined),
                  label: s.navHistory,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  label: s.navSettings,
                ),
              ],
            ),
          ),
        );
      },
    );

void _mockFocusChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.allappsengineer.apex_booster_plus/focus_mode'),
    (call) async {
      if (call.method == 'isPermissionGranted') return false;
      return null;
    },
  );
}

void _mockAppsChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.allappsengineer.apex_booster_plus/apps'),
    (call) async {
      if (call.method == 'getInstalledApps') return <dynamic>[];
      if (call.method == 'getAppIcon') return null;
      if (call.method == 'launchApp') return false;
      return null;
    },
  );
}

void _mockMetricsChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.allappsengineer.apex_booster_plus/metrics'),
    (call) async {
      if (call.method == 'getMemoryInfo') {
        return <String, dynamic>{
          'availableBytes': 2000000000,
          'totalBytes': 8000000000,
          'lowMemory': false,
          'thresholdBytes': 150000000,
        };
      }
      return null;
    },
  );
}

void _mockOverlayChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('apex/overlay'),
    (call) async {
      switch (call.method) {
        case 'isOverlayPermissionGranted': return false;
        case 'isFloatingShowing': return false;
        case 'hideFloating': return null;
        case 'openOverlayPermissionSettings': return null;
        default: return null;
      }
    },
  );
}

void _clearAllChannels() {
  for (final name in const [
    'com.allappsengineer.apex_booster_plus/focus_mode',
    'com.allappsengineer.apex_booster_plus/apps',
    'com.allappsengineer.apex_booster_plus/metrics',
    'apex/overlay',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), null);
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    languageNotifier.value = AppLanguage.ptBr;
    _mockFocusChannel();
    _mockAppsChannel();
    _mockMetricsChannel();
    _mockOverlayChannel();
  });

  tearDown(() {
    _clearAllChannels();
    languageNotifier.value = AppLanguage.ptBr;
  });

  // ── 1. Card Idioma aparece ────────────────────────────────────────────────

  testWidgets('card Idioma aparece na ConfiguracoesTab', (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('Idioma do app'), findsOneWidget);
  });

  // ── 2. Idioma atual exibido no card ───────────────────────────────────────

  testWidgets('card Idioma exibe idioma atual em Portugues', (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('Português'), findsOneWidget);
  });

  // ── 3. Bottom sheet exibe as 3 opções ────────────────────────────────────

  testWidgets('bottom sheet de idioma exibe Portugues BR English e Espanol',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idioma do app'));
    await tester.pumpAndSettle();

    expect(find.text('Português (BR)'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
  });

  // ── 4. Selecionar English atualiza languageNotifier ───────────────────────

  testWidgets('selecionar English atualiza languageNotifier para en',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idioma do app'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(languageNotifier.value, AppLanguage.en);
  });

  // ── 5. Selecionar Español atualiza languageNotifier ───────────────────────

  testWidgets('selecionar Espanol atualiza languageNotifier para es',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idioma do app'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(languageNotifier.value, AppLanguage.es);
  });

  // ── 6. Selecionar English persiste no SharedPreferences ──────────────────

  testWidgets('selecionar English persiste idioma no SharedPreferences',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idioma do app'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(prefs.getString('apex_app_language'), 'en');
  });

  // ── 7. Selecionar Español persiste no SharedPreferences ──────────────────

  testWidgets('selecionar Espanol persiste idioma no SharedPreferences',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idioma do app'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(prefs.getString('apex_app_language'), 'es');
  });

  // ── 8. Opção atual marcada com checkmark no sheet ─────────────────────────

  testWidgets('opcao atual exibe checkmark no sheet de idioma', (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idioma do app'));
    await tester.pumpAndSettle();

    // PT-BR is current — should have a check icon next to it
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  // ── 9. Textos da aba mudam ao trocar idioma ───────────────────────────────

  testWidgets('titulo da ConfiguracoesTab muda para Settings ao trocar para English',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    expect(find.text('Configurações'), findsOneWidget);

    await tester.tap(find.text('Idioma do app'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Configurações'), findsNothing);
  });

  testWidgets('titulo da ConfiguracoesTab muda para Configuracion ao trocar para Espanol',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idioma do app'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Configuración'), findsOneWidget);
  });

  // ── 10. Limpar histórico continua funcionando ─────────────────────────────

  testWidgets('limpar historico continua funcionando apos migracao de strings',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    expect(find.text('Limpar histórico de sessões'), findsOneWidget);
    await tester.tap(find.text('Limpar histórico de sessões'));
    await tester.pumpAndSettle();

    expect(find.text('Limpar histórico?'), findsOneWidget);
    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  // ── 11. Modo Foco continua aparecendo ─────────────────────────────────────

  testWidgets('modo foco continua aparecendo apos migracao de strings',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    expect(find.text('Modo Foco Gamer'), findsOneWidget);
  });

  // ── 12. Sobre continua visível ────────────────────────────────────────────

  testWidgets('card Sobre continua visivel apos migracao de strings',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();

    expect(find.text('Apex Booster+'), findsOneWidget);
    expect(find.text('Prepare. Analise. Jogue.'), findsOneWidget);
    expect(
      find.text('Não altera jogos de terceiros automaticamente.'),
      findsOneWidget,
    );
  });

  // ── 13. BottomNav PT-BR ───────────────────────────────────────────────────

  testWidgets('BottomNav exibe Inicio Biblioteca Preparar Historico Config em PT-BR',
      (tester) async {
    await tester.pumpWidget(_wrapBottomNavLabels());
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Preparar'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Config.'), findsOneWidget);
  });

  // ── 14. BottomNav EN ──────────────────────────────────────────────────────

  testWidgets('BottomNav exibe Home Library Prepare History Settings em EN',
      (tester) async {
    languageNotifier.value = AppLanguage.en;
    await tester.pumpWidget(_wrapBottomNavLabels());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Prepare'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  // ── 15. BottomNav ES ──────────────────────────────────────────────────────

  testWidgets('BottomNav exibe Inicio Preparar Historial Config em ES',
      (tester) async {
    languageNotifier.value = AppLanguage.es;
    await tester.pumpWidget(_wrapBottomNavLabels());
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Preparar'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);
  });

  // ── 16. BottomNav atualiza sem reiniciar ──────────────────────────────────

  testWidgets('BottomNav atualiza para EN ao trocar idioma sem reiniciar',
      (tester) async {
    await tester.pumpWidget(_wrapBottomNavLabels());
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget); // PT-BR

    languageNotifier.value = AppLanguage.en;
    await tester.pumpAndSettle(); // rebuild via ListenableBuilder

    expect(find.text('Home'), findsOneWidget); // EN
  });
}

// GAME-DETAIL-MOTION-U1 — entrance/decorative animations on Game Detail must
// respect Baixa Distração (lowDistractionNotifier) and the system
// `disableAnimations` accessibility flag, mirroring the pattern already
// established in PreparationPanel. Normal mode must stay pixel-for-pixel
// unchanged: the Abrir Jogo shimmer keeps its infinite repeat() loop, and
// every section keeps its existing entrance fade/slide/scale.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/presentation/screens/game_detail/game_detail_screen.dart';

const _appsChannel =
    MethodChannel('com.allappsengineer.apex_booster_plus/apps');
const _metricsChannel =
    MethodChannel('com.allappsengineer.apex_booster_plus/metrics');

const _gameId = 'g1';
const _packageName = 'com.test.game';

final _game = ApexGame(
  id: _gameId,
  name: 'Test Game',
  packageName: _packageName,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

const _memoryPayload = {
  'availableBytes': 2048 * 1024 * 1024,
  'totalBytes': 8192 * 1024 * 1024,
  'lowMemory': false,
  'thresholdBytes': 500000000,
};

Future<void> _primeLibrary() async {
  SharedPreferences.setMockInitialValues({
    'apex_game_library': jsonEncode([_game.toJson()]),
  });
}

void _installMockChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_appsChannel, (call) async {
    switch (call.method) {
      case 'getInstalledApps':
        return [
          {
            'appName': 'Test Game',
            'packageName': _packageName,
            'isGame': true,
          },
        ];
      default:
        return null;
    }
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_metricsChannel, (call) async {
    if (call.method == 'getMemoryInfo') return _memoryPayload;
    return null;
  });
}

// The Abrir Jogo shimmer uses flutter_animate's non-cancellable repeat() in
// normal mode, so pumpAndSettle() never returns there — advance the fake
// clock in fixed steps instead, exactly like game_detail_screen_metrics_test
// and game_detail_screen_guard_test already do.
Future<void> _pumpFor(
  WidgetTester tester,
  Duration total, {
  Duration step = const Duration(milliseconds: 50),
}) async {
  var remaining = total;
  while (remaining > Duration.zero) {
    final thisStep = remaining < step ? remaining : step;
    await tester.pump(thisStep);
    remaining -= thisStep;
  }
}

const _kMetricsTimeoutMs = 4300;

/// Builds a router with a `/home` stub in front of Game Detail, so tests can
/// exercise a real push/pop cycle (needed for the dispose-while-animating
/// coverage) instead of Game Detail being the lone root route.
/// [disableAnimations] is injected via a `MediaQuery` override placed below
/// MaterialApp's own MediaQuery — the same technique already used by
/// preparation_panel_test.dart.
Widget _buildApp({bool disableAnimations = false}) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push('/game-detail/$_gameId'),
              child: const Text('OPEN_DETAIL'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/game-detail/:id',
        builder: (context, state) => Builder(
          builder: (innerContext) => MediaQuery(
            data: MediaQuery.of(innerContext)
                .copyWith(disableAnimations: disableAnimations),
            child: GameDetailScreen(
              gameId: state.pathParameters['id'] ?? '',
              initialGame: _game,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/gfx-profile/:id',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          ),
          body: const Center(child: Text('GFX_STUB')),
        ),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

// ElevatedButton.icon() returns the private _ElevatedButtonWithIcon subclass,
// so find.byType(ElevatedButton) (exact runtimeType match) never matches it —
// byWidgetPredicate with `is` covers the subclass instead.
Finder _launchButtonFinder() => find.ancestor(
      of: find.byIcon(Icons.sports_esports_rounded),
      matching: find.byWidgetPredicate((w) => w is ElevatedButton),
    );

Finder _shimmerAnimateFinder() => find.ancestor(
      of: find.byIcon(Icons.sports_esports_rounded),
      matching: find.byType(Animate),
    );

void main() {
  setUp(() async {
    await _primeLibrary();
    _installMockChannels();
    lowDistractionNotifier.value = false;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_appsChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_metricsChannel, null);
    lowDistractionNotifier.value = false;
  });

  testWidgets(
      'normal mode keeps the Abrir Jogo shimmer looping forever '
      '(onPlay still requests repeat())', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.tap(find.text('OPEN_DETAIL'));
    await _pumpFor(tester, const Duration(milliseconds: _kMetricsTimeoutMs));

    expect(_launchButtonFinder(), findsOneWidget);
    final animate = tester.widget<Animate>(_shimmerAnimateFinder());
    // PreparationPanel's own idle-button pulse also runs continuously and
    // is intentionally out of scope here, so pumpAndSettle() can't be used
    // to tell normal mode apart from Baixa Distração on this screen — the
    // repeat() request itself is the reliable, deterministic signal.
    expect(animate.onPlay, isNotNull,
        reason:
            'normal mode must still request an infinite repeat() shimmer');
  });

  testWidgets(
      'Baixa Distração reduces the shimmer to a single discreet pass '
      '(no repeat() requested)', (tester) async {
    lowDistractionNotifier.value = true;
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.tap(find.text('OPEN_DETAIL'));
    await _pumpFor(tester, const Duration(milliseconds: _kMetricsTimeoutMs));

    expect(_launchButtonFinder(), findsOneWidget);
    // Still a decorative Animate wrapper (a single pass), just not infinite.
    final animate = tester.widget<Animate>(_shimmerAnimateFinder());
    expect(animate.onPlay, isNull,
        reason: 'Baixa Distração must not request an infinite repeat()');
    expect(tester.takeException(), isNull);
  });

  testWidgets('disableAnimations leaves the Abrir Jogo button fully static',
      (tester) async {
    await tester.pumpWidget(_buildApp(disableAnimations: true));
    await tester.pump();
    await tester.tap(find.text('OPEN_DETAIL'));
    await _pumpFor(tester, const Duration(milliseconds: _kMetricsTimeoutMs));

    final buttonFinder = _launchButtonFinder();
    expect(buttonFinder, findsOneWidget);
    expect(
      _shimmerAnimateFinder(),
      findsNothing,
      reason: 'disableAnimations must skip the shimmer wrapper entirely',
    );
    // Functionally intact: not disabled, still tappable.
    final button = tester.widget<ElevatedButton>(buttonFinder);
    expect(button.onPressed, isNotNull);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'disableAnimations skips every decorative Animate wrapper on the '
      'screen and renders all sections immediately', (tester) async {
    await tester.pumpWidget(_buildApp(disableAnimations: true));
    await tester.pump();
    await tester.tap(find.text('OPEN_DETAIL'));
    // A single frame is enough — nothing should be waiting on a fade/slide.
    await tester.pump();
    await _pumpFor(tester, const Duration(milliseconds: _kMetricsTimeoutMs));

    expect(find.byType(Animate), findsNothing,
        reason: 'no entrance or decorative animation may run under '
            'disableAnimations');
    expect(find.text('Test Game'), findsOneWidget);
    expect(find.text(_packageName), findsOneWidget);
    expect(find.text('APEX SCAN'), findsOneWidget);
    expect(find.text('2048 MB'), findsOneWidget);
    expect(find.text('8192 MB'), findsOneWidget);
  });

  for (final mode in ['normal', 'baixaDistracao', 'disableAnimations']) {
    testWidgets(
        'no section disappears and the Abrir Jogo CTA stays functional — '
        '$mode', (tester) async {
      if (mode == 'baixaDistracao') lowDistractionNotifier.value = true;
      await tester.pumpWidget(
        _buildApp(disableAnimations: mode == 'disableAnimations'),
      );
      await tester.pump();
      await tester.tap(find.text('OPEN_DETAIL'));
      await _pumpFor(tester, const Duration(milliseconds: _kMetricsTimeoutMs));

      expect(find.text('Test Game'), findsOneWidget);
      expect(find.text(_packageName), findsOneWidget);
      expect(find.text('APEX SCAN'), findsOneWidget);
      expect(find.text('2048 MB'), findsOneWidget);
      expect(find.text('8192 MB'), findsOneWidget);

      final button = tester.widget<ElevatedButton>(_launchButtonFinder());
      expect(button.onPressed, isNotNull,
          reason: 'Abrir Jogo must remain tappable in every motion mode');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'toggling Baixa Distração across a GFX Profile round trip causes no '
      'overflow, crash or broken navigation', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.tap(find.text('OPEN_DETAIL'));
    await _pumpFor(tester, const Duration(milliseconds: _kMetricsTimeoutMs));
    expect(find.text('Test Game'), findsOneWidget);

    // Flip the setting mid-flow, then trigger a natural rebuild via a
    // GFX Profile round trip (the same mechanism already used elsewhere in
    // this screen — no live ValueListenableBuilder is expected here).
    lowDistractionNotifier.value = true;
    final gfxInkWell = tester.widget<InkWell>(
      find.ancestor(
        of: find.byIcon(Icons.tune_rounded),
        matching: find.byType(InkWell),
      ),
    );
    gfxInkWell.onTap!();
    await _pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.text('GFX_STUB'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await _pumpFor(tester, const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Test Game'), findsOneWidget);
    expect(find.text(_packageName), findsOneWidget);
  });

  for (final mode in ['normal', 'baixaDistracao', 'disableAnimations']) {
    testWidgets(
        'disposing Game Detail while animations are in flight leaves no '
        'pending ticker, timer or callback — $mode', (tester) async {
      if (mode == 'baixaDistracao') lowDistractionNotifier.value = true;
      await tester.pumpWidget(
        _buildApp(disableAnimations: mode == 'disableAnimations'),
      );
      await tester.pump();
      await tester.tap(find.text('OPEN_DETAIL'));
      await _pumpFor(tester, const Duration(milliseconds: 800));

      // Pop back to /home while the shimmer (normal/reduced) may still be
      // mid-cycle — dispose must not throw or leave a dangling ticker.
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('OPEN_DETAIL'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

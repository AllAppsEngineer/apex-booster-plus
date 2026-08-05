// GAME-DETAIL-METRICS-U1 — returning from GFX Profile must not re-measure
// Real Metrics (RAM + Apex Latency). Only the initial Game Detail load (and
// any future flow that genuinely needs a full refresh) should trigger
// _loadMetrics(); _openProfileSelector()'s post-push _loadGame() call must
// update the game/profile without repeating the measurement.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/domain/entities/gfx_profile.dart';
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

// Round MiB values (not MB) — _formatMb divides by 1024*1024, so byte counts
// must be exact multiples of 1 MiB to render without rounding artifacts.
const _memoryPayload = {
  'availableBytes': 2048 * 1024 * 1024, // 2048 MB
  'totalBytes': 8192 * 1024 * 1024, // 8192 MB
  'lowMemory': false,
  'thresholdBytes': 500000000,
};

int _getMemoryInfoCalls = 0;

Future<void> _primeLibrary() async {
  SharedPreferences.setMockInitialValues({
    'apex_game_library': jsonEncode([_game.toJson()]),
  });
}

Future<void> _writeLibrary(List<ApexGame> games) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    'apex_game_library',
    jsonEncode(games.map((g) => g.toJson()).toList()),
  );
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
    if (call.method == 'getMemoryInfo') {
      _getMemoryInfoCalls++;
      return _memoryPayload;
    }
    return null;
  });
}

// GameDetailScreen carries non-cancellable flutter_animate/repeat()
// animations (Launch button shimmer), so pumpAndSettle() never returns.
// Advance the fake clock in fixed steps instead, mirroring the pattern
// already used by game_detail_screen_guard_test.dart.
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

Widget _buildApp() {
  final router = GoRouter(
    initialLocation: '/game-detail/$_gameId',
    routes: [
      GoRoute(
        path: '/game-detail/:id',
        builder: (context, state) => GameDetailScreen(
          gameId: state.pathParameters['id'] ?? '',
          initialGame: _game,
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

// _loadMetrics() wraps DeviceMetricsServiceImpl().measure() in its own 4s
// .timeout(); measureLatency() hits a real network endpoint (no MethodChannel
// to mock), so in the sandboxed test environment it runs out that internal
// timeout before _metricsLoading flips back to false. getMemoryInfo (mocked
// above) resolves instantly and is the reliable signal that a measurement
// was attempted, so tests assert on its call count rather than waiting out
// full completion wherever possible.
const _kMetricsTimeoutMs = 4300;

InkWell _gfxProfileInkWell(WidgetTester tester) => tester.widget<InkWell>(
      find.ancestor(
        of: find.byIcon(Icons.tune_rounded),
        matching: find.byType(InkWell),
      ),
    );

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(_buildApp());
  await _pumpFor(tester, const Duration(milliseconds: _kMetricsTimeoutMs));
}

void main() {
  setUp(() async {
    await _primeLibrary();
    _installMockChannels();
    _getMemoryInfoCalls = 0;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_appsChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_metricsChannel, null);
  });

  testWidgets('initial load measures Real Metrics exactly once',
      (tester) async {
    await _pumpApp(tester);

    expect(_getMemoryInfoCalls, 1);
    expect(find.text('2048 MB'), findsOneWidget); // RAM available
    expect(find.text('8192 MB'), findsOneWidget); // RAM total
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
      'returning from GFX Profile does not re-measure Real Metrics',
      (tester) async {
    await _pumpApp(tester);
    expect(_getMemoryInfoCalls, 1);

    _gfxProfileInkWell(tester).onTap!();
    await _pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.text('GFX_STUB'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    // Short pump only: the bug under test synchronously flips
    // _metricsLoading = true and shows a spinner as soon as _loadGame's
    // continuation resumes after pop — no need to wait out any timeout to
    // observe it.
    await _pumpFor(tester, const Duration(milliseconds: 300));

    expect(_getMemoryInfoCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('previous Real Metrics values remain visible after returning '
      'from GFX Profile', (tester) async {
    await _pumpApp(tester);
    expect(find.text('2048 MB'), findsOneWidget);
    expect(find.text('8192 MB'), findsOneWidget);

    _gfxProfileInkWell(tester).onTap!();
    await _pumpFor(tester, const Duration(milliseconds: 300));
    await tester.tap(find.byType(BackButton));
    await _pumpFor(tester, const Duration(milliseconds: 300));

    expect(find.text('2048 MB'), findsOneWidget);
    expect(find.text('8192 MB'), findsOneWidget);
  });

  testWidgets('returning from GFX Profile updates the displayed profile',
      (tester) async {
    await _pumpApp(tester);
    expect(find.text('Desempenho'), findsNothing);

    _gfxProfileInkWell(tester).onTap!();
    await _pumpFor(tester, const Duration(milliseconds: 300));

    // Simulate the GFX Profile screen persisting a new profile choice while
    // pushed on top, the way the real /gfx-profile route does.
    await _writeLibrary([
      _game.copyWith(localProfileName: GfxProfile.performance.label),
    ]);

    await tester.tap(find.byType(BackButton));
    await _pumpFor(tester, const Duration(milliseconds: 300));

    expect(find.text('Desempenho'), findsOneWidget);
  });

  testWidgets(
      'returning from GFX Profile after the persisted game disappears stays '
      'safe and does not re-measure', (tester) async {
    await _pumpApp(tester);
    expect(_getMemoryInfoCalls, 1);

    _gfxProfileInkWell(tester).onTap!();
    await _pumpFor(tester, const Duration(milliseconds: 300));

    // Underlying library corrupted/cleared while the GFX Profile route is on
    // top — getGameById will return null on the way back.
    await _writeLibrary(const []);

    await tester.tap(find.byType(BackButton));
    await _pumpFor(tester, const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(_getMemoryInfoCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
      'editing the game does not trigger any additional metrics '
      'measurement', (tester) async {
    await _pumpApp(tester);
    expect(_getMemoryInfoCalls, 1);

    final editButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.edit_rounded),
        matching: find.byType(IconButton),
      ),
    );
    editButton.onPressed!();
    await _pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await _pumpFor(tester, const Duration(milliseconds: 300));

    expect(_getMemoryInfoCalls, 1);
  });
}

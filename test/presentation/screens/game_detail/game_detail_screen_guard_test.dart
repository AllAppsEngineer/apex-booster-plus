// GAME-DETAIL-GUARD-U1 — exclusive guard against overlapping CTA taps on the
// Game Detail screen (Abrir Jogo, Editar, GFX Profile, Criar Card).
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/presentation/screens/game_detail/game_detail_screen.dart';

const _appsChannel =
    MethodChannel('com.allappsengineer.apex_booster_plus/apps');
const _focusChannel =
    MethodChannel('com.allappsengineer.apex_booster_plus/focus_mode');

const _gameId = 'g1';
const _packageName = 'com.test.game';

final _game = ApexGame(
  id: _gameId,
  name: 'Test Game',
  packageName: _packageName,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

// The 5-step Prep Launch sequence advances one step every 380ms
// (_kStepDelay in game_detail_screen.dart) before invoking launchApp.
const _kLaunchSequenceMs = 380 * 6 + 200;

int _launchAppCalls = 0;
Completer<void>? _launchGate;
Completer<void>? _focusPermissionGate;
bool _launchShouldThrow = false;

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
      case 'launchApp':
        _launchAppCalls++;
        if (_launchGate != null) await _launchGate!.future;
        if (_launchShouldThrow) {
          throw PlatformException(code: 'LAUNCH_ERROR');
        }
        return null;
      default:
        return null;
    }
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_focusChannel, (call) async {
    if (call.method == 'isPermissionGranted') {
      if (_focusPermissionGate != null) await _focusPermissionGate!.future;
      return false;
    }
    return null;
  });
}

// GameDetailScreen and its Launch button carry non-cancellable
// flutter_animate/repeat() animations, so pumpAndSettle() never returns.
// Advance the fake clock in fixed steps instead, mirroring the pattern
// already used by preparation_panel_test.dart.
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

// Invoking each CTA's callback directly (instead of tester.tap, which
// dispatches a real pointer gesture) is what makes "two rapid taps" a
// reliable simulation here: tester.tap() pumps internally between down and
// up, which is enough time for the first tap's modal barrier (bottom sheet /
// dialog) to already be on screen — the second tap would then just land on
// that barrier and never reach the button at all, "protecting" against a
// double-fire for a reason that has nothing to do with the guard under test.
// Calling onPressed/onTap directly, twice, back to back, with no pump in
// between, is what actually exercises _activeAction's synchronous
// check-and-set.
// ElevatedButton.icon() returns a private ElevatedButton subclass, so
// find.byType(ElevatedButton) (exact runtimeType match) misses it — a
// widget predicate with `is` matches the subclass too.
ElevatedButton _launchButton(WidgetTester tester) => tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('ABRIR JOGO'),
        matching: find.byWidgetPredicate((w) => w is ElevatedButton),
      ),
    );

IconButton _editButton(WidgetTester tester) => tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.edit_rounded),
        matching: find.byType(IconButton),
      ),
    );

InkWell _gfxProfileInkWell(WidgetTester tester) => tester.widget<InkWell>(
      find.ancestor(
        of: find.byIcon(Icons.tune_rounded),
        matching: find.byType(InkWell),
      ),
    );

InkWell _createCardInkWell(WidgetTester tester) => tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Criar card'),
        matching: find.byType(InkWell),
      ),
    );

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
      GoRoute(
        path: '/share-studio/:gameId',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          ),
          body: const Center(child: Text('STUDIO_STUB')),
        ),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(_buildApp());
  // Flushes initial async loads (SharedPreferences, getInstalledApps) and
  // lets DeviceMetricsServiceImpl's own 4s internal .timeout() fire and
  // settle (no metrics MethodChannel/HTTP mock is installed here — metrics
  // are irrelevant to the CTA guard under test) — without ever calling
  // pumpAndSettle(), which would hang forever on the Launch button's
  // repeat() shimmer animation.
  await _pumpFor(tester, const Duration(milliseconds: 4300));
}

void main() {
  setUp(() async {
    await _primeLibrary();
    _installMockChannels();
    _launchAppCalls = 0;
    _launchGate = null;
    _focusPermissionGate = null;
    _launchShouldThrow = false;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_appsChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_focusChannel, null);
  });

  group('double tap fires a single action', () {
    testWidgets('Abrir Jogo: two rapid taps call launchApp only once',
        (tester) async {
      await _pumpApp(tester);

      final onPressed = _launchButton(tester).onPressed!;
      onPressed();
      onPressed();

      await _pumpFor(tester, const Duration(milliseconds: _kLaunchSequenceMs));

      expect(_launchAppCalls, 1);
    });

    testWidgets('Editar: two rapid taps open only one dialog',
        (tester) async {
      await _pumpApp(tester);

      final onPressed = _editButton(tester).onPressed!;
      onPressed();
      onPressed();
      await _pumpFor(tester, const Duration(milliseconds: 300));

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('GFX Profile: two rapid taps push only one route',
        (tester) async {
      await _pumpApp(tester);

      final onTap = _gfxProfileInkWell(tester).onTap!;
      onTap();
      onTap();
      await _pumpFor(tester, const Duration(milliseconds: 300));

      expect(find.text('GFX_STUB'), findsOneWidget);

      // A single pop must return straight to the detail screen — proves no
      // second route was stacked underneath. _openProfileSelector reloads
      // the game on return, which re-triggers _loadMetrics and its own 4s
      // internal timeout — pump past both that and the page-transition
      // animation before asserting.
      await tester.tap(find.byType(BackButton));
      await _pumpFor(tester, const Duration(milliseconds: 4300));
      expect(find.text('ABRIR JOGO'), findsOneWidget);
      expect(find.text('GFX_STUB'), findsNothing);
    });

    testWidgets('Criar Card: two rapid taps push only one route',
        (tester) async {
      await _pumpApp(tester);

      final onTap = _createCardInkWell(tester).onTap!;
      onTap();
      onTap();
      await _pumpFor(tester, const Duration(milliseconds: 300));

      expect(find.text('STUDIO_STUB'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await _pumpFor(tester, const Duration(milliseconds: 600));
      expect(find.text('ABRIR JOGO'), findsOneWidget);
      expect(find.text('STUDIO_STUB'), findsNothing);
    });
  });

  testWidgets('guard is released after the action returns, allowing a new one',
      (tester) async {
    await _pumpApp(tester);

    _launchButton(tester).onPressed!();
    await _pumpFor(tester, const Duration(milliseconds: _kLaunchSequenceMs));
    expect(_launchAppCalls, 1);

    _launchButton(tester).onPressed!();
    await _pumpFor(tester, const Duration(milliseconds: _kLaunchSequenceMs));
    expect(_launchAppCalls, 2);
  });

  testWidgets(
      'an exception inside a guarded action still releases the guard '
      '(try/finally)', (tester) async {
    await _pumpApp(tester);

    // _openEditDialog's continuation after the dialog closes runs as a
    // dangling Future (IconButton.onPressed doesn't await it), so the
    // StateError it throws surfaces as an uncaught zone error rather than
    // something tester.takeException() can retrieve. Capture it with our
    // own zone instead of letting it fall through to flutter_test's, which
    // would otherwise report it as an unrelated framework failure.
    Object? caught;
    await runZonedGuarded(() async {
      // Open the edit dialog, then delete the game from the persisted
      // library from underneath it —
      // SharedPreferencesGameLibraryRepository.updateGame throws StateError
      // when the id it's asked to update no longer exists.
      _editButton(tester).onPressed!();
      await _pumpFor(tester, const Duration(milliseconds: 300));
      expect(find.byType(AlertDialog), findsOneWidget);

      await SharedPreferences.getInstance().then(
        (p) => p.setString('apex_game_library', jsonEncode(const [])),
      );

      final saveButton = find.widgetWithText(ElevatedButton, 'Salvar');
      await tester.tap(saveButton);
      await _pumpFor(tester, const Duration(milliseconds: 300));
    }, (error, stack) {
      caught = error;
    });

    expect(caught, isA<StateError>());

    // Restore the library so a *different* action can prove the guard was
    // released rather than left stuck on _GameDetailAction.edit.
    await _primeLibrary();
    _launchButton(tester).onPressed!();
    await _pumpFor(tester, const Duration(milliseconds: _kLaunchSequenceMs));
    expect(_launchAppCalls, 1);
  });

  testWidgets(
      'a different CTA stays blocked while another action is active',
      (tester) async {
    await _pumpApp(tester);

    _launchButton(tester).onPressed!();
    // Still mid-sequence (5 * 380ms steps) — nothing else should open.
    await _pumpFor(tester, const Duration(milliseconds: 200));

    _editButton(tester).onPressed!();
    _gfxProfileInkWell(tester).onTap!();
    _createCardInkWell(tester).onTap!();
    await _pumpFor(tester, const Duration(milliseconds: 100));

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('GFX_STUB'), findsNothing);
    expect(find.text('STUDIO_STUB'), findsNothing);

    // Let the launch sequence finish, then confirm the guard is free again.
    await _pumpFor(tester, const Duration(milliseconds: _kLaunchSequenceMs));
    expect(_launchAppCalls, 1);

    _editButton(tester).onPressed!();
    await _pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets(
      'dispose while an action is pending does not trigger setState after '
      'dispose', (tester) async {
    _focusPermissionGate = Completer<void>();
    await _pumpApp(tester);

    _launchButton(tester).onPressed!();
    // _launchGame is now suspended awaiting isPermissionGranted().
    await _pumpFor(tester, const Duration(milliseconds: 50));

    await tester.pumpWidget(const SizedBox());
    await _pumpFor(tester, const Duration(milliseconds: 50));

    _focusPermissionGate!.complete();
    await _pumpFor(tester, const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });
}

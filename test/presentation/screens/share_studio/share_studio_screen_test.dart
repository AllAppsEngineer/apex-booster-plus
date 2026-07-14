import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/data/services/screen_capture_gallery_service.dart';
import 'package:apex_booster_plus/presentation/screens/share_studio/share_studio_screen.dart';
import 'package:apex_booster_plus/presentation/widgets/social/share_card_portrait.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ApexStudioScreen shows title', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Apex Studio'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen shows export button', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Exportar'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen shows caption hint', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Escreva sobre sua sessão...'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen shows preset chips', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('9:16'), findsOneWidget);
    expect(find.text('1:1'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen shows template selector', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Apex Dark'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen shows add media button', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar print ou vídeo'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen export button is disabled when no media is selected', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    final disabledBtn = find.byWidgetPredicate(
      (w) => w is ButtonStyleButton && w.onPressed == null,
    );
    expect(disabledBtn, findsOneWidget);
  });

  testWidgets('ApexStudioScreen shows no-media microcopy when no media is selected', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Adicione um print ou vídeo para exportar'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen with .png initialMediaPath enables export button',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(
        gameId: 'test-game',
        initialMediaPath: '/fake/path/screenshot.png',
      ),
    ));
    await tester.pumpAndSettle();
    // With a valid image path, no ButtonStyleButton should be disabled.
    final disabledBtn = find.byWidgetPredicate(
      (w) => w is ButtonStyleButton && w.onPressed == null,
    );
    expect(disabledBtn, findsNothing);
  });

  testWidgets('ApexStudioScreen shows fit chips when image is selected', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(
        gameId: 'test-game',
        initialMediaPath: '/fake/path/screenshot.png',
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Preencher'), findsOneWidget);
    expect(find.text('Encaixar'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen does not show fit chips when no media', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Preencher'), findsNothing);
    expect(find.text('Encaixar'), findsNothing);
  });

  testWidgets('ApexStudioScreen shows fit chips for video', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(
        gameId: 'test-game',
        initialMediaPath: '/fake/path/clip.mp4',
      ),
    ));
    // pump instead of pumpAndSettle: scan line animation repeats infinitely
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Preencher'), findsOneWidget);
    expect(find.text('Encaixar'), findsOneWidget);
  });

  testWidgets('ApexStudioScreen shows play overlay icon for video', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(
        gameId: 'test-game',
        initialMediaPath: '/fake/path/clip.mp4',
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byIcon(Icons.play_circle_rounded), findsOneWidget);
  });

  testWidgets('ApexStudioScreen shows video export notice for video', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(
        gameId: 'test-game',
        initialMediaPath: '/fake/path/clip.mp4',
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.textContaining('fase futura'),
      findsOneWidget,
    );
  });

  testWidgets('ApexStudioScreen media sheet shows Apex captures option', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();

    final addMediaButton = find.text('Adicionar print ou vídeo');
    await tester.ensureVisible(addMediaButton);
    await tester.pumpAndSettle();
    await tester.tap(addMediaButton);
    await tester.pumpAndSettle();

    expect(find.text('Capturas do Apex'), findsOneWidget);
  });

  testWidgets(
      'ApexStudioScreen starts with empty session name field and no name on card preview',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('test-game'), findsNothing);
    final field = tester.widget<TextField>(
      find.byKey(const Key('apex_studio_session_name_field')),
    );
    expect(field.controller!.text, isEmpty);
    final card = tester.widget<ShareCardPortrait>(find.byType(ShareCardPortrait));
    expect(card.card.gameName, isEmpty);
  });

  testWidgets('ApexStudioScreen updates card preview when session name is edited',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('apex_studio_session_name_field')),
      'Custom Session',
    );
    await tester.pump();

    expect(find.text('Custom Session'), findsNWidgets(2));
    final card = tester.widget<ShareCardPortrait>(find.byType(ShareCardPortrait));
    expect(card.card.gameName, 'Custom Session');
  });

  testWidgets('ApexStudioScreen removes name from card preview when session name is cleared',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ApexStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('apex_studio_session_name_field')),
      'Custom Session',
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('apex_studio_session_name_field')),
      '',
    );
    await tester.pump();

    expect(find.text('Sessão gamer'), findsNothing);
    expect(find.text('Custom Session'), findsNothing);
    final card = tester.widget<ShareCardPortrait>(find.byType(ShareCardPortrait));
    expect(card.card.gameName, isEmpty);
  });

  testWidgets('ApexStudioScreen shows empty message when no Apex captures exist',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ApexStudioScreen(
        gameId: 'test-game',
        galleryService:
            ScreenCaptureGalleryService(resolveBaseDir: () async => null),
      ),
    ));
    await tester.pumpAndSettle();

    final addMediaButton = find.text('Adicionar print ou vídeo');
    await tester.ensureVisible(addMediaButton);
    await tester.pumpAndSettle();
    await tester.tap(addMediaButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Capturas do Apex'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Nenhuma captura disponível ainda. Capture pela tela do jogo com o botão flutuante A+.',
      ),
      findsOneWidget,
    );
  });

  group('Apex captures deletion', () {
    // Real dart:io file I/O awaited as the continuation of a widget gesture
    // callback never resolves under this project's flutter_test setup
    // (confirmed independently of this feature: tester.runAsync() in every
    // combination, sync I/O, and long real delays all still stall on it).
    // A fake service that resolves via plain Dart Futures — no real file
    // access — sidesteps that entirely and lets the delete UI be exercised
    // for real. Real file/index behavior is covered separately and
    // thoroughly by screen_capture_gallery_service_test.dart.
    late _FakeGalleryService service;

    setUp(() {
      service = _FakeGalleryService();
    });

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> openCapturesSheet(WidgetTester tester) async {
      final addMediaButton = find.text('Adicionar print ou vídeo');
      await tester.ensureVisible(addMediaButton);
      await settle(tester);
      await tester.tap(addMediaButton);
      await settle(tester);
      await tester.tap(find.text('Capturas do Apex'));
      await settle(tester);
    }

    testWidgets(
        'shows delete confirmation with capture title for a screenshot',
        (tester) async {
      service.seed(CapturedScreenshot(
        path: '/fake/apex_cap_1.png',
        capturedAt: _fakeTimestamp,
      ));

      await tester.pumpWidget(MaterialApp(
        home: ApexStudioScreen(gameId: 'test-game', galleryService: service),
      ));
      await settle(tester);
      await openCapturesSheet(tester);

      expect(find.byKey(const Key('apex_capture_delete_0')), findsOneWidget);
      await tester.tap(find.byKey(const Key('apex_capture_delete_0')));
      await settle(tester);

      expect(find.text('Excluir captura?'), findsOneWidget);

      await tester.tap(find.text('CANCELAR'));
      await settle(tester);
      expect(service.deletedPaths, isEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets('shows delete confirmation with video title for a video',
        (tester) async {
      service.seed(CapturedScreenshot(
        path: '/fake/apex_clip_1.mp4',
        capturedAt: _fakeTimestamp,
        isVideo: true,
      ));

      await tester.pumpWidget(MaterialApp(
        home: ApexStudioScreen(gameId: 'test-game', galleryService: service),
      ));
      await settle(tester);
      await openCapturesSheet(tester);

      await tester.tap(find.byKey(const Key('apex_capture_delete_0')));
      await settle(tester);

      expect(find.text('Excluir vídeo?'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets(
        'confirming delete removes the capture from the grid and calls the service',
        (tester) async {
      service.seed(CapturedScreenshot(
        path: '/fake/apex_cap_1.png',
        capturedAt: _fakeTimestamp,
      ));

      await tester.pumpWidget(MaterialApp(
        home: ApexStudioScreen(gameId: 'test-game', galleryService: service),
      ));
      await settle(tester);
      await openCapturesSheet(tester);

      await tester.tap(find.byKey(const Key('apex_capture_delete_0')));
      await settle(tester);
      await tester.tap(find.text('EXCLUIR'));
      await settle(tester);

      expect(service.deletedPaths, ['/fake/apex_cap_1.png']);
      expect(
        find.text(
          'Nenhuma captura disponível ainda. Capture pela tela do jogo com o botão flutuante A+.',
        ),
        findsOneWidget,
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets(
        'deleting the currently selected capture clears selection and disables export',
        (tester) async {
      service.seed(CapturedScreenshot(
        path: '/fake/apex_cap_1.png',
        capturedAt: _fakeTimestamp,
      ));

      await tester.pumpWidget(MaterialApp(
        home: ApexStudioScreen(gameId: 'test-game', galleryService: service),
      ));
      await settle(tester);
      await openCapturesSheet(tester);

      await tester.tap(find.byKey(const Key('apex_capture_tile_0')));
      await settle(tester);

      final disabledExportBtn = find.byWidgetPredicate(
        (w) => w is ButtonStyleButton && w.onPressed == null,
      );
      expect(disabledExportBtn, findsNothing);

      // Re-seed so the reopened sheet still shows the (now selected) capture.
      service.seed(CapturedScreenshot(
        path: '/fake/apex_cap_1.png',
        capturedAt: _fakeTimestamp,
      ));
      await tester.tap(find.byTooltip('Trocar mídia'));
      await settle(tester);
      await tester.tap(find.text('Capturas do Apex'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('apex_capture_delete_0')));
      await settle(tester);
      await tester.tap(find.text('EXCLUIR'));
      await settle(tester);

      expect(service.deletedPaths, ['/fake/apex_cap_1.png']);
      expect(find.text('Adicionar print ou vídeo'), findsOneWidget);
      expect(disabledExportBtn, findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}

final _fakeTimestamp = DateTime.fromMillisecondsSinceEpoch(1000);

/// Resolves via plain Dart Futures only — no real file I/O — so it can be
/// driven through gesture-triggered async gaps in a widget test. Real
/// list/delete file behavior is covered by
/// screen_capture_gallery_service_test.dart.
class _FakeGalleryService extends ScreenCaptureGalleryService {
  _FakeGalleryService() : super(resolveBaseDir: () async => null);

  final List<CapturedScreenshot> _captures = [];
  final List<String> deletedPaths = [];

  void seed(CapturedScreenshot capture) => _captures.add(capture);

  @override
  Future<List<CapturedScreenshot>> listCaptures() async =>
      List.of(_captures);

  @override
  Future<bool> deleteCapture(CapturedScreenshot capture) async {
    deletedPaths.add(capture.path);
    _captures.removeWhere((c) => c.path == capture.path);
    return true;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/presentation/screens/share_studio/share_studio_screen.dart';

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
}

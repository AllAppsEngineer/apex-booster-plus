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
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/presentation/screens/home/home_screen.dart'
    show homeTabNotifier;
import 'package:apex_booster_plus/presentation/screens/home/tabs/inicio_tab.dart';

Future<void> _pumpInicioTab(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: InicioTab(isActive: true))),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => homeTabNotifier.value = null);
  tearDown(() => homeTabNotifier.value = null);

  testWidgets('Card Biblioteca Gamer navega para a aba Biblioteca (index 1)',
      (tester) async {
    await _pumpInicioTab(tester);

    await tester.tap(find.text('Biblioteca Gamer'));
    await tester.pump();

    expect(homeTabNotifier.value, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Card Histórico de Sessão navega para a aba Histórico (index 4)',
      (tester) async {
    await _pumpInicioTab(tester);

    await tester.tap(find.text('Histórico de Sessão'));
    await tester.pump();

    expect(homeTabNotifier.value, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Card Modo Foco Gamer navega para a aba Configurações (index 5)',
      (tester) async {
    await _pumpInicioTab(tester);

    await tester.tap(find.text('Modo Foco Gamer'));
    await tester.pump();

    expect(homeTabNotifier.value, 5);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Card Classificação Gamer navega para a aba Biblioteca (index 1), '
      'pois não há tela dedicada', (tester) async {
    await _pumpInicioTab(tester);

    await tester.tap(find.text('Classificação Gamer'));
    await tester.pump();

    expect(homeTabNotifier.value, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Card Apex Scan exibe animação curta e depois navega para Preparar (index 2)',
      (tester) async {
    await _pumpInicioTab(tester);

    await tester.tap(find.text('Apex Scan'));
    await tester.pump();

    // Overlay de transição visível durante a animação; navegação ainda não ocorreu.
    expect(find.text('Analisando...'), findsOneWidget);
    expect(homeTabNotifier.value, isNull);

    // Aguarda a janela da animação (600–900ms) terminar.
    await tester.pump(const Duration(milliseconds: 800));

    expect(homeTabNotifier.value, 2);
    expect(find.text('Analisando...'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

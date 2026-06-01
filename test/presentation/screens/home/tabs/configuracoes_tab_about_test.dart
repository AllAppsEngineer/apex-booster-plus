import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/configuracoes_tab.dart';

Widget _wrapConfig() => MaterialApp(
      home: Scaffold(body: ConfiguracoesTab()),
    );

void _mockFocusChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(
        'com.allappsengineer.apex_booster_plus/focus_mode'),
    (call) async {
      if (call.method == 'isPermissionGranted') return false;
      return null;
    },
  );
}

void _clearFocusChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(
        'com.allappsengineer.apex_booster_plus/focus_mode'),
    null,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockFocusChannel();
  });

  tearDown(_clearFocusChannel);

  testWidgets('card Sobre renderiza sem crash', (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('card Sobre exibe nome Apex Booster+', (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('Apex Booster+'), findsOneWidget);
  });

  testWidgets('card Sobre exibe Versao 1.0.0', (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('Versão 1.0.0'), findsOneWidget);
  });

  testWidgets('card Sobre exibe tagline Prepare Analise Jogue',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('Prepare. Analise. Jogue.'), findsOneWidget);
  });

  testWidgets('card Sobre exibe disclaimer de nao alteracao de jogos',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(
      find.text('Não altera jogos de terceiros automaticamente.'),
      findsOneWidget,
    );
  });

  testWidgets('CTA ABRIR AJUSTES nao aparece mais na aba Configuracoes',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('ABRIR AJUSTES'), findsNothing);
  });

  testWidgets('placeholder CFG nao aparece na aba Configuracoes',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('Preferências em preparação'), findsNothing);
  });

  testWidgets('card LANG nao aparece na aba Configuracoes', (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('Idioma do app'), findsNothing);
  });
}

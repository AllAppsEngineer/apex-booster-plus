import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/presentation/widgets/social/privacy_guard_sheet.dart';

void main() {
  testWidgets('PrivacyGuardSheet shows title and body', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () => showPrivacyGuardSheet(ctx, AppLanguage.ptBr),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Revisar antes de compartilhar'), findsOneWidget);
    expect(find.text('Você revisa e escolhe onde compartilhar.'), findsOneWidget);
    expect(find.text('O Apex nunca posta por você.'), findsOneWidget);
  });

  testWidgets('PrivacyGuardSheet Cancel button returns false', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () async {
            result = await showPrivacyGuardSheet(ctx, AppLanguage.ptBr);
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(result, false);
  });

  testWidgets('PrivacyGuardSheet Confirm button returns true', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () async {
            result = await showPrivacyGuardSheet(ctx, AppLanguage.ptBr);
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exportar').last);
    await tester.pumpAndSettle();

    expect(result, true);
  });
}

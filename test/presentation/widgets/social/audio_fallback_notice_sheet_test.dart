import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/presentation/widgets/social/audio_fallback_notice_sheet.dart';

void main() {
  testWidgets('AudioFallbackNoticeSheet shows title and body', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () => showAudioFallbackNoticeSheet(
            ctx,
            AppLanguage.ptBr,
            onOpenStudio: () {},
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Áudio interno não disponível nesta gravação'), findsOneWidget);
    expect(
      find.text(
        'O Apex não recebeu áudio interno deste jogo. Isso pode acontecer quando o jogo bloqueia a captura, está sem som ou utiliza uma fonte de áudio incompatível. Para gravar com som, use o gravador de tela do celular. Depois, volte ao Apex Studio, importe o vídeo e compartilhe normalmente.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ENTENDI dismisses without invoking onOpenStudio', (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () => showAudioFallbackNoticeSheet(
            ctx,
            AppLanguage.ptBr,
            onOpenStudio: () => opened = true,
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ENTENDI'));
    await tester.pumpAndSettle();

    expect(opened, isFalse);
    expect(find.text('ENTENDI'), findsNothing);
  });

  testWidgets('ABRIR APEX STUDIO dismisses and invokes onOpenStudio', (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () => showAudioFallbackNoticeSheet(
            ctx,
            AppLanguage.ptBr,
            onOpenStudio: () => opened = true,
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ABRIR APEX STUDIO'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
  });
}

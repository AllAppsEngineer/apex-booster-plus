import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/social_card.dart';
import 'package:apex_booster_plus/domain/entities/social_template.dart';
import 'package:apex_booster_plus/presentation/widgets/social/share_card_portrait.dart';

void main() {
  final template = kSocialTemplates.first;

  testWidgets('ShareCardPortrait renders game name', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(find.text('Free Fire'), findsOneWidget);
  });

  testWidgets('ShareCardPortrait shows watermark by default', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(find.text('Prepared with Apex Booster+'), findsOneWidget);
  });

  testWidgets('ShareCardPortrait hides watermark when includeWatermark=false', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
      includeWatermark: false,
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(find.text('Prepared with Apex Booster+'), findsNothing);
  });

  testWidgets('ShareCardPortrait shows caption when non-empty', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
      caption: 'Sessão preparada!',
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(find.text('Sessão preparada!'), findsOneWidget);
  });

  testWidgets('ShareCardPortrait does not overflow', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Um Jogo Com Nome Muito Longo Mesmo Para Testar Overflow De Layout',
      createdAt: DateTime(2026, 6, 11),
      caption: 'Uma legenda também bem longa para garantir que o layout não quebre.',
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ShareCardPortrait accepts mediaFit contain without overflow', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
      importedMediaPath: '/fake/screenshot.png',
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(
          card: card,
          template: template,
          mediaFit: BoxFit.contain,
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ShareCardPortrait hides name when gameName is empty', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: '',
      createdAt: DateTime(2026, 6, 11),
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == ''),
      findsNothing,
    );
  });

  testWidgets('ShareCardPortrait hides name when gameName is whitespace only', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: '   ',
      createdAt: DateTime(2026, 6, 11),
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == '   '),
      findsNothing,
    );
  });

  testWidgets('ShareCardPortrait with video path shows premium video label', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
      importedMediaPath: '/fake/clip.mp4',
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    await tester.pump();
    expect(find.text('PRÉVIA DE VÍDEO'), findsOneWidget);
  });
}

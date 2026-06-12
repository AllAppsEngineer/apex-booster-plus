import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/social_card.dart';
import 'package:apex_booster_plus/domain/entities/share_preset.dart';
import 'package:apex_booster_plus/domain/entities/social_template.dart';
import 'package:apex_booster_plus/presentation/widgets/social/share_card_square.dart';

void main() {
  final template = kSocialTemplates.first;

  testWidgets('ShareCardSquare renders game name', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Call of Duty',
      createdAt: DateTime(2026, 6, 11),
      preset: SharePreset.square,
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 300,
        height: 300,
        child: ShareCardSquare(card: card, template: template),
      ),
    ));
    expect(find.text('Call of Duty'), findsOneWidget);
  });

  testWidgets('ShareCardSquare shows watermark', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Call of Duty',
      createdAt: DateTime(2026, 6, 11),
      preset: SharePreset.square,
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 300,
        height: 300,
        child: ShareCardSquare(card: card, template: template),
      ),
    ));
    expect(find.text('Prepared with Apex Booster+'), findsOneWidget);
  });

  testWidgets('ShareCardSquare does not overflow with long name', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Um Nome De Jogo Muito Longo Para Testar O Layout Do Card',
      createdAt: DateTime(2026, 6, 11),
      caption: 'Legenda também comprida para garantir robustez visual.',
      preset: SharePreset.square,
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 300,
        height: 300,
        child: ShareCardSquare(card: card, template: template),
      ),
    ));
    expect(tester.takeException(), isNull);
  });
}

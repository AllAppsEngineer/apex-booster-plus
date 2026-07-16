import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_feature_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('ApexFeatureCard sem onTap não reage ao toque',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        ApexFeatureCard(
          badge: 'BIB',
          title: 'Biblioteca Gamer',
          subtitle: 'subtitulo',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ApexFeatureCard), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tapped, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ApexFeatureCard com onTap dispara callback ao toque',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        ApexFeatureCard(
          badge: 'BIB',
          title: 'Biblioteca Gamer',
          subtitle: 'subtitulo',
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ApexFeatureCard), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/domain/entities/social_template.dart';
import 'package:apex_booster_plus/presentation/widgets/social/social_template_selector.dart';

void main() {
  testWidgets('SocialTemplateSelector shows template names', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SocialTemplateSelector(
          templates: kSocialTemplates,
          selectedId: 'default',
          onSelected: (_) {},
          lang: AppLanguage.ptBr,
        ),
      ),
    ));
    expect(find.text('Apex Dark'), findsOneWidget);
    expect(find.text('Cyber Blue'), findsOneWidget);
  });

  testWidgets('SocialTemplateSelector calls onSelected when tapped', (tester) async {
    SocialTemplate? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SocialTemplateSelector(
          templates: kSocialTemplates,
          selectedId: 'default',
          onSelected: (t) => selected = t,
          lang: AppLanguage.ptBr,
        ),
      ),
    ));
    await tester.tap(find.text('Cyber Blue'));
    expect(selected?.id, 'cyber');
  });

  testWidgets('SocialTemplateSelector shows Premium chip for non-free template', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SocialTemplateSelector(
          templates: kSocialTemplates,
          selectedId: 'default',
          onSelected: (_) {},
          lang: AppLanguage.ptBr,
        ),
      ),
    ));
    expect(find.text('Premium'), findsOneWidget);
  });
}

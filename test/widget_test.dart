import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ApexBoosterApp());

    // Verifica elemento estático da SplashScreen antes do timer disparar
    expect(find.text('APEX BOOSTER+'), findsOneWidget);

    // Avança o clock fake além dos 2500ms do Future.delayed da SplashScreen,
    // evitando Timer pendente ao final do teste
    await tester.pump(const Duration(milliseconds: 2600));

    // Drena transição de navegação e animações restantes
    await tester.pumpAndSettle();
  });
}

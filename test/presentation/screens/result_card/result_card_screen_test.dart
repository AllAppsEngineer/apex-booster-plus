import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';
import 'package:apex_booster_plus/presentation/screens/result_card/result_card_screen.dart';

SessionRecord _record({String? packageName = 'com.example.game', String? gameId = 'game-1'}) {
  return SessionRecord(
    id: 'session-1',
    gameId: gameId ?? '',
    gameName: 'Apex Arena',
    packageName: packageName,
    launchedAt: DateTime(2026, 7, 14, 20, 30),
    launchStatus: 'success',
    focusModeAvailable: true,
    focusModeAttempted: false,
    metricsAvailable: false,
  );
}

void main() {
  final s = AppStrings(AppLanguage.ptBr);

  setUp(() => lowDistractionNotifier.value = true);
  tearDown(() => lowDistractionNotifier.value = false);

  testWidgets('renders the Apex Result Card when a session is provided', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ResultCardScreen(session: _record())));
    expect(find.text('Apex Arena'), findsOneWidget);
  });

  testWidgets('shows reopen CTA when packageName is present', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResultCardScreen(session: _record(packageName: 'com.example.game')),
    ));
    expect(find.text(s.resultCardCtaReopen), findsOneWidget);
  });

  testWidgets('hides reopen CTA when packageName is absent', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResultCardScreen(session: _record(packageName: null)),
    ));
    expect(find.text(s.resultCardCtaReopen), findsNothing);
  });

  testWidgets('shows share CTA when gameId is present', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResultCardScreen(session: _record(gameId: 'game-1')),
    ));
    expect(find.text(s.resultCardCtaShare), findsOneWidget);
  });

  testWidgets('hides share CTA when gameId is empty', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResultCardScreen(session: _record(gameId: '')),
    ));
    expect(find.text(s.resultCardCtaShare), findsNothing);
  });

  testWidgets('shows a friendly error state and a back action when session is null', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResultCardScreen(session: null)));
    expect(find.text(s.resultCardErrorTitle), findsOneWidget);
    expect(find.text(s.resultCardErrorDesc), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
  });

  testWidgets('error state does not render the result card content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResultCardScreen(session: null)));
    expect(find.text('Apex Arena'), findsNothing);
  });
}

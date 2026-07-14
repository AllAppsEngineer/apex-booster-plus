import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_result_card.dart';

SessionRecord _record({
  String launchStatus = 'success',
  bool metricsAvailable = false,
  int? memoryAvailableMb,
  int? memoryTotalMb,
  String? memoryState,
  int? apexLatencyMs,
  String? gfxProfile,
  bool focusModeAttempted = false,
  String? focusModeResult,
  String? packageName = 'com.example.game',
}) {
  return SessionRecord(
    id: 'session-1',
    gameId: 'game-1',
    gameName: 'Apex Arena',
    packageName: packageName,
    launchedAt: DateTime(2026, 7, 14, 20, 30),
    launchStatus: launchStatus,
    focusModeAvailable: true,
    focusModeAttempted: focusModeAttempted,
    focusModeResult: focusModeResult,
    metricsAvailable: metricsAvailable,
    memoryAvailableMb: memoryAvailableMb,
    memoryTotalMb: memoryTotalMb,
    memoryState: memoryState,
    apexLatencyMs: apexLatencyMs,
    gfxProfile: gfxProfile,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUp(() => lowDistractionNotifier.value = true);
  tearDown(() => lowDistractionNotifier.value = false);

  testWidgets('shows game name', (tester) async {
    await tester.pumpWidget(_wrap(ApexResultCard(session: _record())));
    expect(find.text('Apex Arena'), findsOneWidget);
  });

  testWidgets('shows RAM chip when metrics are available', (tester) async {
    await tester.pumpWidget(_wrap(ApexResultCard(session: _record(
      metricsAvailable: true,
      memoryAvailableMb: 2048,
      memoryTotalMb: 8192,
      memoryState: 'normal',
    ))));
    expect(find.textContaining('GB'), findsWidgets);
  });

  testWidgets('shows honest unavailable text when metrics are absent — never a fake zero', (tester) async {
    await tester.pumpWidget(_wrap(ApexResultCard(session: _record(metricsAvailable: false))));
    expect(find.text('Métricas não disponíveis nesta sessão.'), findsOneWidget);
    expect(find.textContaining('0 GB'), findsNothing);
    expect(find.textContaining('0 ms'), findsNothing);
  });

  testWidgets('shows GFX profile chip when a known profile label is set', (tester) async {
    await tester.pumpWidget(_wrap(ApexResultCard(session: _record(gfxProfile: 'Equilibrado'))));
    expect(find.textContaining('Equilibrado'), findsOneWidget);
  });

  testWidgets('does not show a profile chip when gfxProfile is null', (tester) async {
    await tester.pumpWidget(_wrap(ApexResultCard(session: _record(gfxProfile: null))));
    expect(find.text('Perfil aplicado'), findsNothing);
  });

  testWidgets('reopen CTA is hidden when onReopenGame is not provided', (tester) async {
    await tester.pumpWidget(_wrap(ApexResultCard(session: _record())));
    expect(find.text('Abrir jogo novamente'), findsNothing);
  });

  testWidgets('reopen CTA appears and invokes callback when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(ApexResultCard(
      session: _record(),
      onReopenGame: () => tapped = true,
    )));
    await tester.tap(find.text('Abrir jogo novamente'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('share CTA appears and invokes callback when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(ApexResultCard(
      session: _record(),
      onCreateSocialCard: () => tapped = true,
    )));
    await tester.tap(find.text('Criar card social'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('failed launch shows failed status, not a success chip', (tester) async {
    await tester.pumpWidget(_wrap(ApexResultCard(session: _record(launchStatus: 'failed'))));
    expect(find.text('Falha ao abrir'), findsOneWidget);
    expect(find.text('Abertura registrada'), findsNothing);
  });

  testWidgets('close CTA is hidden when onClose is not provided', (tester) async {
    await tester.pumpWidget(_wrap(ApexResultCard(session: _record())));
    expect(find.text('FECHAR'), findsNothing);
  });

  testWidgets('close CTA appears and invokes callback when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(ApexResultCard(
      session: _record(),
      onClose: () => tapped = true,
    )));
    await tester.tap(find.text('FECHAR'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}

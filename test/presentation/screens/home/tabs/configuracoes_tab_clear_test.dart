import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/configuracoes_tab.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/historico_tab.dart';

SessionRecord _makeSession(String id) => SessionRecord(
      id: id,
      gameId: 'g1',
      gameName: 'Free Fire',
      launchedAt: DateTime(2024, 1, 1),
      launchStatus: 'success',
      focusModeAvailable: false,
      focusModeAttempted: false,
      metricsAvailable: false,
    );

Widget _wrapConfig() => MaterialApp(
      home: Scaffold(body: ConfiguracoesTab()),
    );

Widget _wrapHistorico({required bool isActive}) => MaterialApp(
      home: Scaffold(body: HistoricoTab(isActive: isActive)),
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

  // ─── ConfiguracoesTab: presença do card ────────────────────────────────────

  testWidgets('ConfiguracoesTab exibe card Limpar historico de sessoes',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    expect(find.text('Limpar histórico de sessões'), findsOneWidget);
  });

  // ─── ConfiguracoesTab: diálogo de confirmação ──────────────────────────────

  testWidgets('tocar no card abre dialogo de confirmacao com titulo correto',
      (tester) async {
    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Limpar histórico de sessões'));
    await tester.tap(find.text('Limpar histórico de sessões'));
    await tester.pumpAndSettle();

    expect(find.text('Limpar histórico?'), findsOneWidget);
    expect(find.text('CANCELAR'), findsOneWidget);
    expect(find.text('LIMPAR'), findsOneWidget);
  });

  // ─── ConfiguracoesTab: CANCELAR preserva sessões ──────────────────────────

  testWidgets('CANCELAR fecha dialogo sem apagar sessoes', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesSessionRepository(prefs);
    await repo.addSession(_makeSession('s1'));

    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Limpar histórico de sessões'));
    await tester.tap(find.text('Limpar histórico de sessões'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();

    expect(find.text('Limpar histórico?'), findsNothing);
    expect(await repo.getSessions(), hasLength(1));
  });

  // ─── ConfiguracoesTab: LIMPAR apaga sessões ────────────────────────────────

  testWidgets('LIMPAR apaga todas as sessoes e exibe snackbar', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesSessionRepository(prefs);
    await repo.addSession(_makeSession('s1'));
    await repo.addSession(_makeSession('s2'));

    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Limpar histórico de sessões'));
    await tester.tap(find.text('Limpar histórico de sessões'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('LIMPAR'));
    await tester.pumpAndSettle();

    expect(await repo.getSessions(), isEmpty);
    expect(find.text('Histórico apagado com sucesso.'), findsOneWidget);
  });

  // ─── Isolamento: apex_games não é afetado ─────────────────────────────────

  testWidgets('LIMPAR nao afeta a chave apex_games do SharedPreferences',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'apex_games': '[{"id":"g1","name":"Free Fire"}]',
    });
    _mockFocusChannel();

    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesSessionRepository(prefs);
    await repo.addSession(_makeSession('s1'));

    await tester.pumpWidget(_wrapConfig());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Limpar histórico de sessões'));
    await tester.tap(find.text('Limpar histórico de sessões'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('LIMPAR'));
    await tester.pumpAndSettle();

    expect(await repo.getSessions(), isEmpty);
    expect(prefs.getString('apex_games'), isNotNull);
  });

  // ─── HistoricoTab: parâmetro isActive ─────────────────────────────────────
  // Nota: pumpAndSettle não é usado aqui porque CircularProgressIndicator
  // agenda frames infinitamente enquanto o loading state está ativo.
  // pump(Duration) avança o clock simulado, resolve async e conclui animações.

  testWidgets('HistoricoTab aceita parametro isActive sem erro', (tester) async {
    await tester.pumpWidget(_wrapHistorico(isActive: false));
    await tester.pump(); // constrói o frame inicial
    await tester.pump(const Duration(seconds: 1)); // resolve async + animações
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'HistoricoTab recarrega sessoes quando isActive muda de false para true',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesSessionRepository(prefs);

    // Começa com isActive: false, sem sessões
    await tester.pumpWidget(_wrapHistorico(isActive: false));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Adiciona sessão enquanto tab está inativa
    await repo.addSession(_makeSession('s1'));

    // Ativa a tab — didUpdateWidget dispara _loadSessions()
    await tester.pumpWidget(_wrapHistorico(isActive: true));
    await tester.pump(); // didUpdateWidget + início do async
    await tester.pump(const Duration(seconds: 1)); // resolve async + animações

    // Sessão deve aparecer na tela
    expect(find.text('Free Fire'), findsOneWidget);
  });
}

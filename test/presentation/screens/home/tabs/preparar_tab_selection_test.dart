import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/preparar_tab.dart';

void main() {
  final t = DateTime(2024, 1, 1);

  ApexGame makeGame(String id, String name) => ApexGame(
        id: id,
        name: name,
        createdAt: t,
        updatedAt: t,
      );

  SessionRecord makeSession(String gameId) => SessionRecord(
        id: 'sess-$gameId',
        gameId: gameId,
        gameName: 'Nome',
        launchedAt: t,
        launchStatus: 'success',
        focusModeAvailable: false,
        focusModeAttempted: false,
        metricsAvailable: false,
      );

  group('selectGameForPreparation — biblioteca vazia', () {
    test('retorna null quando não há jogos', () {
      final result = selectGameForPreparation([], []);
      expect(result, isNull);
    });

    test('retorna null quando não há jogos mesmo com sessões', () {
      final result = selectGameForPreparation([], [makeSession('any')]);
      expect(result, isNull);
    });
  });

  group('selectGameForPreparation — sem histórico', () {
    test('retorna primeiro jogo quando não há sessões', () {
      final games = [makeGame('g1', 'Free Fire'), makeGame('g2', 'PUBG')];
      final result = selectGameForPreparation(games, []);
      expect(result?.id, 'g1');
    });

    test('retorna único jogo disponível quando não há sessões', () {
      final games = [makeGame('g1', 'Free Fire')];
      final result = selectGameForPreparation(games, []);
      expect(result?.id, 'g1');
    });
  });

  group('selectGameForPreparation — com histórico', () {
    test('retorna jogo da última sessão quando ainda existe na biblioteca', () {
      final games = [makeGame('g1', 'Free Fire'), makeGame('g2', 'PUBG')];
      final sessions = [makeSession('g2'), makeSession('g1')];
      final result = selectGameForPreparation(games, sessions);
      expect(result?.id, 'g2');
    });

    test('retorna primeiro jogo quando jogo da última sessão foi removido', () {
      final games = [makeGame('g1', 'Free Fire'), makeGame('g2', 'PUBG')];
      final sessions = [makeSession('g-removido')];
      final result = selectGameForPreparation(games, sessions);
      expect(result?.id, 'g1');
    });

    test('retorna jogo da sessão mais recente (primeira da lista ordenada)', () {
      final games = [
        makeGame('g1', 'Free Fire'),
        makeGame('g2', 'PUBG'),
        makeGame('g3', 'Clash'),
      ];
      final sessions = [makeSession('g3'), makeSession('g1'), makeSession('g2')];
      final result = selectGameForPreparation(games, sessions);
      expect(result?.id, 'g3');
    });
  });

  group('buildIsLaunchableHint', () {
    test('retorna true quando packageName está definido e não vazio', () {
      final game = ApexGame(
        id: 'g1',
        name: 'Free Fire',
        packageName: 'com.garena.game.kalahari',
        createdAt: t,
        updatedAt: t,
      );
      expect(buildIsLaunchableHint(game), isTrue);
    });

    test('retorna false quando packageName é null', () {
      final game = makeGame('g1', 'Jogo Sem Package');
      expect(buildIsLaunchableHint(game), isFalse);
    });

    test('retorna false quando packageName é string vazia', () {
      final game = ApexGame(
        id: 'g1',
        name: 'Jogo',
        packageName: '',
        createdAt: t,
        updatedAt: t,
      );
      expect(buildIsLaunchableHint(game), isFalse);
    });
  });
}

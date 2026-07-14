import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/repositories/in_memory_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';

void main() {
  late InMemoryGameLibraryRepository repo;
  final now = DateTime(2026, 1, 1);

  ApexGame makeGame({String id = 'g1', String name = 'Game One'}) {
    return ApexGame(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    repo = InMemoryGameLibraryRepository();
  });

  group('getGames', () {
    test('returns empty list when no games added', () async {
      final games = await repo.getGames();
      expect(games, isEmpty);
    });

    test('returns copy — external mutation does not affect internal state',
        () async {
      await repo.addGame(makeGame());
      final games = await repo.getGames();
      games.clear();
      expect((await repo.getGames()).length, 1);
    });
  });

  group('getGameById', () {
    test('returns null when id does not exist', () async {
      final result = await repo.getGameById('nonexistent');
      expect(result, isNull);
    });

    test('returns correct game by id', () async {
      final game = makeGame();
      await repo.addGame(game);
      final result = await repo.getGameById('g1');
      expect(result, equals(game));
    });
  });

  group('addGame', () {
    test('adds game and it appears in getGames', () async {
      final game = makeGame();
      await repo.addGame(game);
      final games = await repo.getGames();
      expect(games, contains(game));
    });

    test('throws StateError when adding duplicate id', () async {
      await repo.addGame(makeGame());
      expect(() => repo.addGame(makeGame()), throwsStateError);
    });
  });

  group('updateGame', () {
    test('updates game with same id', () async {
      await repo.addGame(makeGame());
      final updated = makeGame(name: 'Game Updated');
      await repo.updateGame(updated);
      final result = await repo.getGameById('g1');
      expect(result!.name, 'Game Updated');
    });

    test('throws StateError when id does not exist', () async {
      expect(() => repo.updateGame(makeGame()), throwsStateError);
    });
  });

  group('removeGame', () {
    test('removes existing game', () async {
      await repo.addGame(makeGame());
      await repo.removeGame('g1');
      expect(await repo.getGames(), isEmpty);
    });

    test('no-op when id does not exist', () async {
      await repo.addGame(makeGame());
      await repo.removeGame('nonexistent');
      expect((await repo.getGames()).length, 1);
    });
  });

  group('toggleFavorite', () {
    test('sets isFavorite to true when initially false', () async {
      await repo.addGame(makeGame());
      await repo.toggleFavorite('g1');
      final result = await repo.getGameById('g1');
      expect(result!.isFavorite, isTrue);
    });

    test('sets isFavorite back to false on second toggle', () async {
      await repo.addGame(makeGame());
      await repo.toggleFavorite('g1');
      await repo.toggleFavorite('g1');
      final result = await repo.getGameById('g1');
      expect(result!.isFavorite, isFalse);
    });

    test('throws StateError when id does not exist', () async {
      expect(() => repo.toggleFavorite('nonexistent'), throwsStateError);
    });
  });
}

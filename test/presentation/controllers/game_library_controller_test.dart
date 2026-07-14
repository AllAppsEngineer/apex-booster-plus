import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/data/repositories/in_memory_game_library_repository.dart';
import 'package:apex_booster_plus/presentation/controllers/game_library_controller.dart';
import 'package:apex_booster_plus/presentation/controllers/game_library_state.dart';

ApexGame _game({
  String id = 'g1',
  String name = 'Free Fire',
  bool isFavorite = false,
}) {
  final now = DateTime(2026, 5, 20);
  return ApexGame(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
    isFavorite: isFavorite,
  );
}

GameLibraryController _makeController() =>
    GameLibraryController(InMemoryGameLibraryRepository());

void main() {
  group('GameLibraryState', () {
    test('initial state has empty games, isLoading false, no error', () {
      const s = GameLibraryState.initial();
      expect(s.games, isEmpty);
      expect(s.isLoading, isFalse);
      expect(s.errorMessage, isNull);
    });

    test('copyWith updates only specified fields', () {
      const s = GameLibraryState.initial();
      final updated = s.copyWith(isLoading: true);
      expect(updated.isLoading, isTrue);
      expect(updated.games, isEmpty);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith clearError removes errorMessage', () {
      final s = const GameLibraryState.initial()
          .copyWith(errorMessage: 'some error');
      expect(s.errorMessage, 'some error');

      final cleared = s.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test('equality holds for identical states', () {
      const a = GameLibraryState.initial();
      const b = GameLibraryState.initial();
      expect(a, equals(b));
    });
  });

  group('GameLibraryController.loadGames', () {
    test('starts with initial state', () {
      final c = _makeController();
      expect(c.state, const GameLibraryState.initial());
    });

    test('loadGames with empty repository yields empty list', () async {
      final c = _makeController();
      await c.loadGames();
      expect(c.state.games, isEmpty);
      expect(c.state.isLoading, isFalse);
      expect(c.state.errorMessage, isNull);
    });

    test('loadGames reflects pre-populated repository', () async {
      final repo = InMemoryGameLibraryRepository();
      await repo.addGame(_game());
      final c = GameLibraryController(repo);

      await c.loadGames();
      expect(c.state.games.length, 1);
      expect(c.state.games.first.name, 'Free Fire');
    });
  });

  group('GameLibraryController.addGame', () {
    test('addGame appends game to state', () async {
      final c = _makeController();
      await c.addGame(_game());
      expect(c.state.games.length, 1);
      expect(c.state.isLoading, isFalse);
      expect(c.state.errorMessage, isNull);
    });

    test('addGame with duplicate id sets errorMessage', () async {
      final c = _makeController();
      await c.addGame(_game());
      await c.addGame(_game());
      expect(c.state.errorMessage, isNotNull);
      expect(c.state.isLoading, isFalse);
    });
  });

  group('GameLibraryController.updateGame', () {
    test('updateGame reflects new name in state', () async {
      final c = _makeController();
      final original = _game();
      await c.addGame(original);

      final updated = original.copyWith(
        name: 'PUBG Mobile',
        updatedAt: DateTime(2026, 5, 21),
      );
      await c.updateGame(updated);

      expect(c.state.games.first.name, 'PUBG Mobile');
      expect(c.state.errorMessage, isNull);
    });

    test('updateGame with unknown id sets errorMessage', () async {
      final c = _makeController();
      await c.updateGame(_game(id: 'unknown'));
      expect(c.state.errorMessage, isNotNull);
    });
  });

  group('GameLibraryController.removeGame', () {
    test('removeGame removes game from state', () async {
      final c = _makeController();
      await c.addGame(_game());
      expect(c.state.games.length, 1);

      await c.removeGame('g1');
      expect(c.state.games, isEmpty);
      expect(c.state.errorMessage, isNull);
    });

    test('removeGame with unknown id leaves state unchanged', () async {
      final c = _makeController();
      await c.addGame(_game());
      await c.removeGame('nonexistent');
      expect(c.state.games.length, 1);
      expect(c.state.errorMessage, isNull);
    });
  });

  group('GameLibraryController.toggleFavorite', () {
    test('toggleFavorite sets isFavorite true then false', () async {
      final c = _makeController();
      await c.addGame(_game(isFavorite: false));

      await c.toggleFavorite('g1');
      expect(c.state.games.first.isFavorite, isTrue);

      await c.toggleFavorite('g1');
      expect(c.state.games.first.isFavorite, isFalse);
    });

    test('toggleFavorite with unknown id sets errorMessage', () async {
      final c = _makeController();
      await c.toggleFavorite('nonexistent');
      expect(c.state.errorMessage, isNotNull);
    });
  });
}

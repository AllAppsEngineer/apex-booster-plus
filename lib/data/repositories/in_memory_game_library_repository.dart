import '../../domain/entities/apex_game.dart';
import '../../domain/repositories/game_library_repository.dart';

class InMemoryGameLibraryRepository implements GameLibraryRepository {
  final List<ApexGame> _games = [];

  @override
  Future<List<ApexGame>> getGames() async {
    return List.from(_games);
  }

  @override
  Future<ApexGame?> getGameById(String id) async {
    for (final game in _games) {
      if (game.id == id) return game;
    }
    return null;
  }

  @override
  Future<void> addGame(ApexGame game) async {
    for (final existing in _games) {
      if (existing.id == game.id) {
        throw StateError('Game with id "${game.id}" already exists.');
      }
    }
    _games.add(game);
  }

  @override
  Future<void> updateGame(ApexGame game) async {
    final index = _indexById(game.id);
    if (index == -1) {
      throw StateError('Game with id "${game.id}" not found.');
    }
    _games[index] = game;
  }

  @override
  Future<void> removeGame(String id) async {
    _games.removeWhere((g) => g.id == id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final index = _indexById(id);
    if (index == -1) {
      throw StateError('Game with id "$id" not found.');
    }
    final current = _games[index];
    _games[index] = current.copyWith(isFavorite: !current.isFavorite);
  }

  int _indexById(String id) {
    for (var i = 0; i < _games.length; i++) {
      if (_games[i].id == id) return i;
    }
    return -1;
  }
}

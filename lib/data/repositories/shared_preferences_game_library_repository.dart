import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/apex_game.dart';
import '../../domain/repositories/game_library_repository.dart';

class SharedPreferencesGameLibraryRepository implements GameLibraryRepository {
  static const _key = 'apex_game_library';

  final SharedPreferences _prefs;

  SharedPreferencesGameLibraryRepository(this._prefs);

  List<ApexGame> _readAll() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final games = <ApexGame>[];
      for (final item in list) {
        try {
          games.add(ApexGame.fromJson(item as Map<String, dynamic>));
        } catch (_) {
          // discard corrupted entry, continue loading the rest
        }
      }
      return games;
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(List<ApexGame> games) async {
    final encoded = jsonEncode(games.map((g) => g.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  @override
  Future<List<ApexGame>> getGames() async => _readAll();

  @override
  Future<ApexGame?> getGameById(String id) async {
    for (final game in _readAll()) {
      if (game.id == id) return game;
    }
    return null;
  }

  @override
  Future<void> addGame(ApexGame game) async {
    final games = _readAll();
    for (final existing in games) {
      if (existing.id == game.id) {
        throw StateError('Game with id "${game.id}" already exists.');
      }
    }
    games.add(game);
    await _writeAll(games);
  }

  @override
  Future<void> updateGame(ApexGame game) async {
    final games = _readAll();
    final index = games.indexWhere((g) => g.id == game.id);
    if (index == -1) {
      throw StateError('Game with id "${game.id}" not found.');
    }
    games[index] = game;
    await _writeAll(games);
  }

  @override
  Future<void> removeGame(String id) async {
    final games = _readAll();
    games.removeWhere((g) => g.id == id);
    await _writeAll(games);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final games = _readAll();
    final index = games.indexWhere((g) => g.id == id);
    if (index == -1) {
      throw StateError('Game with id "$id" not found.');
    }
    final current = games[index];
    games[index] = current.copyWith(isFavorite: !current.isFavorite);
    await _writeAll(games);
  }
}

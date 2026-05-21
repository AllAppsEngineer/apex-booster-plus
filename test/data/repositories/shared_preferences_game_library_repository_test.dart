import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';

ApexGame _game({
  String id = '1',
  String name = 'Free Fire',
  bool isFavorite = false,
}) {
  final now = DateTime(2024, 1, 1);
  return ApexGame(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
    isFavorite: isFavorite,
  );
}

SharedPreferencesGameLibraryRepository _makeRepo(SharedPreferences prefs) =>
    SharedPreferencesGameLibraryRepository(prefs);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getGames returns empty list when storage is empty', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    expect(await repo.getGames(), isEmpty);
  });

  test('addGame persists a game', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    final game = _game();
    await repo.addGame(game);
    final games = await repo.getGames();
    expect(games.length, 1);
    expect(games.first.id, '1');
    expect(games.first.name, 'Free Fire');
  });

  test('addGame throws when id already exists', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addGame(_game());
    expect(() => repo.addGame(_game()), throwsStateError);
  });

  test('getGameById returns correct game', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addGame(_game(id: 'a', name: 'PUBG'));
    await repo.addGame(_game(id: 'b', name: 'Valorant'));
    final found = await repo.getGameById('b');
    expect(found?.name, 'Valorant');
  });

  test('getGameById returns null when not found', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    expect(await repo.getGameById('missing'), isNull);
  });

  test('removeGame removes the correct game', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addGame(_game(id: 'x'));
    await repo.addGame(_game(id: 'y', name: 'MLBB'));
    await repo.removeGame('x');
    final games = await repo.getGames();
    expect(games.length, 1);
    expect(games.first.id, 'y');
  });

  test('removeGame is silent when id does not exist', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await expectLater(repo.removeGame('ghost'), completes);
  });

  test('toggleFavorite flips isFavorite', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addGame(_game(isFavorite: false));
    await repo.toggleFavorite('1');
    expect((await repo.getGameById('1'))?.isFavorite, isTrue);
    await repo.toggleFavorite('1');
    expect((await repo.getGameById('1'))?.isFavorite, isFalse);
  });

  test('toggleFavorite throws when game not found', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    expect(() => repo.toggleFavorite('missing'), throwsStateError);
  });

  test('updateGame replaces game data', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    final original = _game();
    await repo.addGame(original);
    final updated = original.copyWith(name: 'Free Fire MAX');
    await repo.updateGame(updated);
    final stored = await repo.getGameById('1');
    expect(stored?.name, 'Free Fire MAX');
  });

  test('updateGame throws when game not found', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    expect(() => repo.updateGame(_game()), throwsStateError);
  });

  test('getGames returns empty list when stored JSON is corrupted', () async {
    SharedPreferences.setMockInitialValues({'apex_game_library': 'NOT_JSON'});
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    expect(await repo.getGames(), isEmpty);
  });

  test('getGames skips individual corrupted entries', () async {
    SharedPreferences.setMockInitialValues({
      'apex_game_library':
          '[{"id":"1","name":"OK","createdAt":"2024-01-01T00:00:00.000","updatedAt":"2024-01-01T00:00:00.000","isFavorite":false}, "broken"]',
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    final games = await repo.getGames();
    expect(games.length, 1);
    expect(games.first.name, 'OK');
  });

  test('data persists across repository instances sharing same prefs', () async {
    final prefs = await SharedPreferences.getInstance();
    await _makeRepo(prefs).addGame(_game());
    final games = await _makeRepo(prefs).getGames();
    expect(games.length, 1);
  });
}

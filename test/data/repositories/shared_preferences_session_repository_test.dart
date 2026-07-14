import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_session_repository.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';

SessionRecord _session({
  String id = 's1',
  String gameId = 'g1',
  String gameName = 'Free Fire',
  DateTime? launchedAt,
  String launchStatus = 'success',
}) {
  return SessionRecord(
    id: id,
    gameId: gameId,
    gameName: gameName,
    launchedAt: launchedAt ?? DateTime(2024, 1, 1, 12, 0),
    launchStatus: launchStatus,
    focusModeAvailable: false,
    focusModeAttempted: false,
    metricsAvailable: false,
  );
}

SharedPreferencesSessionRepository _makeRepo(SharedPreferences prefs) =>
    SharedPreferencesSessionRepository(prefs);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getSessions returns empty list when storage is empty', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    expect(await repo.getSessions(), isEmpty);
  });

  test('addSession persists a record', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addSession(_session());
    final sessions = await repo.getSessions();
    expect(sessions.length, 1);
    expect(sessions.first.id, 's1');
    expect(sessions.first.gameName, 'Free Fire');
  });

  test('getSessions returns records ordered by launchedAt descending', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addSession(_session(id: 'a', launchedAt: DateTime(2024, 1, 1)));
    await repo.addSession(_session(id: 'b', launchedAt: DateTime(2024, 1, 3)));
    await repo.addSession(_session(id: 'c', launchedAt: DateTime(2024, 1, 2)));
    final sessions = await repo.getSessions();
    expect(sessions.map((s) => s.id).toList(), ['b', 'c', 'a']);
  });

  test('getSessionsForGame returns only records for the given gameId', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addSession(_session(id: 'a', gameId: 'g1', launchedAt: DateTime(2024, 1, 1)));
    await repo.addSession(_session(id: 'b', gameId: 'g2', launchedAt: DateTime(2024, 1, 2)));
    await repo.addSession(_session(id: 'c', gameId: 'g1', launchedAt: DateTime(2024, 1, 3)));
    final sessions = await repo.getSessionsForGame('g1');
    expect(sessions.map((s) => s.id).toList(), ['c', 'a']);
  });

  test('getSessionsForGame returns empty list when gameId does not exist',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addSession(_session(gameId: 'g1'));
    expect(await repo.getSessionsForGame('ghost'), isEmpty);
  });

  test('getSessionsForGame returns records ordered by launchedAt descending',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addSession(_session(id: 'x', gameId: 'g1', launchedAt: DateTime(2024, 6, 1)));
    await repo.addSession(_session(id: 'y', gameId: 'g1', launchedAt: DateTime(2024, 6, 3)));
    await repo.addSession(_session(id: 'z', gameId: 'g1', launchedAt: DateTime(2024, 6, 2)));
    final sessions = await repo.getSessionsForGame('g1');
    expect(sessions.map((s) => s.id).toList(), ['y', 'z', 'x']);
  });

  test('clearAll removes all sessions', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    await repo.addSession(_session(id: 'a'));
    await repo.addSession(_session(id: 'b'));
    await repo.clearAll();
    expect(await repo.getSessions(), isEmpty);
  });

  test('limit of 50: adding 51st discards the oldest', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    for (var i = 1; i <= 50; i++) {
      await repo.addSession(_session(
        id: 'session_$i',
        launchedAt: DateTime(2024, 1, i),
      ));
    }
    // session_1 is the oldest; adding session_51 should drop it
    await repo.addSession(_session(
      id: 'session_51',
      launchedAt: DateTime(2024, 3, 1),
    ));
    final sessions = await repo.getSessions();
    expect(sessions.length, 50);
    expect(sessions.any((s) => s.id == 'session_1'), isFalse);
    expect(sessions.first.id, 'session_51');
  });

  test('corrupted top-level JSON returns empty list without throwing', () async {
    SharedPreferences.setMockInitialValues({'apex_sessions': 'NOT_VALID_JSON'});
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    expect(await repo.getSessions(), isEmpty);
  });

  test('individual corrupted entry is discarded; valid entries are kept',
      () async {
    SharedPreferences.setMockInitialValues({
      'apex_sessions':
          '[{"id":"s1","gameId":"g1","gameName":"Free Fire","launchedAt":"2024-01-01T12:00:00.000","launchStatus":"success","focusModeAvailable":false,"focusModeAttempted":false,"metricsAvailable":false}, "broken_item"]',
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = _makeRepo(prefs);
    final sessions = await repo.getSessions();
    expect(sessions.length, 1);
    expect(sessions.first.id, 's1');
  });

  test('data persists across repository instances sharing the same prefs',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await _makeRepo(prefs).addSession(_session());
    final sessions = await _makeRepo(prefs).getSessions();
    expect(sessions.length, 1);
    expect(sessions.first.id, 's1');
  });
}

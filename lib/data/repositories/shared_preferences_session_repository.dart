import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/session_record.dart';
import '../../domain/repositories/session_repository.dart';

class SharedPreferencesSessionRepository implements SessionRepository {
  static const _key = 'apex_sessions';
  static const _maxSessions = 50;

  final SharedPreferences _prefs;

  SharedPreferencesSessionRepository(this._prefs);

  List<SessionRecord> _readAll() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final sessions = <SessionRecord>[];
      for (final item in list) {
        try {
          sessions.add(SessionRecord.fromJson(item as Map<String, dynamic>));
        } catch (_) {
          // discard corrupted entry, continue loading the rest
        }
      }
      return sessions;
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(List<SessionRecord> sessions) async {
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  List<SessionRecord> _sortedDescending(List<SessionRecord> sessions) {
    final sorted = List<SessionRecord>.from(sessions);
    sorted.sort((a, b) => b.launchedAt.compareTo(a.launchedAt));
    return sorted;
  }

  @override
  Future<void> addSession(SessionRecord record) async {
    final sessions = _readAll()..add(record);
    final sorted = _sortedDescending(sessions);
    final trimmed = sorted.length > _maxSessions
        ? sorted.sublist(0, _maxSessions)
        : sorted;
    await _writeAll(trimmed);
  }

  @override
  Future<List<SessionRecord>> getSessions() async {
    return _sortedDescending(_readAll());
  }

  @override
  Future<List<SessionRecord>> getSessionsForGame(String gameId) async {
    final filtered =
        _readAll().where((s) => s.gameId == gameId).toList();
    return _sortedDescending(filtered);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_key);
  }
}

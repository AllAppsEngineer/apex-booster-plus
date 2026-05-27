import '../entities/session_record.dart';

abstract class SessionRepository {
  Future<void> addSession(SessionRecord record);
  Future<List<SessionRecord>> getSessions();
  Future<List<SessionRecord>> getSessionsForGame(String gameId);
  Future<void> clearAll();
}

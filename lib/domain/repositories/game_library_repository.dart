import '../entities/apex_game.dart';

abstract class GameLibraryRepository {
  Future<List<ApexGame>> getGames();
  Future<ApexGame?> getGameById(String id);
  Future<void> addGame(ApexGame game);
  Future<void> updateGame(ApexGame game);
  Future<void> removeGame(String id);
  Future<void> toggleFavorite(String id);
}

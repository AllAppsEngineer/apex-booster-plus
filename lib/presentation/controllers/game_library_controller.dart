import '../../domain/entities/apex_game.dart';
import '../../domain/repositories/game_library_repository.dart';
import 'game_library_state.dart';

class GameLibraryController {
  final GameLibraryRepository _repository;

  GameLibraryState _state = const GameLibraryState.initial();

  GameLibraryController(this._repository);

  GameLibraryState get state => _state;

  Future<void> loadGames() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    try {
      final games = await _repository.getGames();
      _state = _state.copyWith(games: games, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addGame(ApexGame game) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.addGame(game);
      final games = await _repository.getGames();
      _state = _state.copyWith(games: games, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateGame(ApexGame game) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateGame(game);
      final games = await _repository.getGames();
      _state = _state.copyWith(games: games, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> removeGame(String id) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.removeGame(id);
      final games = await _repository.getGames();
      _state = _state.copyWith(games: games, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleFavorite(String id) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.toggleFavorite(id);
      final games = await _repository.getGames();
      _state = _state.copyWith(games: games, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

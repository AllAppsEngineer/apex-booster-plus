import '../../domain/entities/apex_game.dart';

class GameLibraryState {
  final List<ApexGame> games;
  final bool isLoading;
  final String? errorMessage;

  const GameLibraryState({
    this.games = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  const GameLibraryState.initial()
      : games = const [],
        isLoading = false,
        errorMessage = null;

  // clearError: use true to explicitly set errorMessage to null without passing null
  GameLibraryState copyWith({
    List<ApexGame>? games,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GameLibraryState(
      games: games ?? this.games,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameLibraryState) return false;
    if (other.isLoading != isLoading) return false;
    if (other.errorMessage != errorMessage) return false;
    if (other.games.length != games.length) return false;
    for (var i = 0; i < games.length; i++) {
      if (other.games[i] != games[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(games),
        isLoading,
        errorMessage,
      );

  @override
  String toString() {
    return 'GameLibraryState('
        'games: ${games.length}, '
        'isLoading: $isLoading, '
        'errorMessage: $errorMessage'
        ')';
  }
}

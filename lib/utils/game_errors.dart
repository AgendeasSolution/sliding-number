class GameError implements Exception {
  final String message;
  final String? code;

  const GameError(this.message, {this.code});

  @override
  String toString() => 'GameError: $message';
}

class InvalidMoveError extends GameError {
  const InvalidMoveError(super.message) : super(code: 'INVALID_MOVE');
}

class GameStateError extends GameError {
  const GameStateError(super.message) : super(code: 'GAME_STATE_ERROR');
}

class ValidationError extends GameError {
  const ValidationError(super.message) : super(code: 'VALIDATION_ERROR');
}

import '../models/game_model.dart';

enum GamesFetchErrorType {
  networkError,
  serverError,
  parsingError,
  unknownError,
}

class GamesFetchResult {
  final List<GameModel>? games;
  final GamesFetchErrorType? errorType;
  final String? errorMessage;

  const GamesFetchResult.success(this.games)
      : errorType = null,
        errorMessage = null;

  const GamesFetchResult.error(this.errorType, {this.errorMessage})
      : games = null;

  bool get isSuccess => games != null;
  bool get isError => errorType != null;
  bool get isNetworkError => errorType == GamesFetchErrorType.networkError;
}


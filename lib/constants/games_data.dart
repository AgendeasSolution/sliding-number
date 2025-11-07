import '../services/games_api_service.dart';
import '../services/games_api_result.dart';

class GamesData {
  // Fetch all games from FGTP Labs API (excluding current game "Sliding Number")
  static Future<GamesFetchResult> getOtherGames() async {
    return await GamesApiService.fetchGames();
  }
}


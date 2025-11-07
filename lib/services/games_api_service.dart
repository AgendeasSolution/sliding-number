import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/game_model.dart';
import 'games_api_result.dart';

class GamesApiService {
  static const String _baseUrl = 'https://api.freegametoplay.com';
  static const String _endpoint = '/apps';
  static const Duration _timeout = Duration(seconds: 10);

  /// Fetch all games from the API
  /// Returns a GamesFetchResult with games or error information
  static Future<GamesFetchResult> fetchGames() async {
    try {
      final uri = Uri.parse('$_baseUrl$_endpoint');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          
          if (jsonData['success'] == true && jsonData['data'] != null) {
            final List<dynamic> gamesJson = jsonData['data'] as List<dynamic>;
            final List<GameModel> games = gamesJson
                .map((gameJson) => GameModel.fromJson(gameJson as Map<String, dynamic>))
                .toList();

            // Filter out "Sliding Number" game (current game)
            final filteredGames = games.where((game) => game.name != 'Sliding Number').toList();
            return GamesFetchResult.success(filteredGames);
          } else {
            // API returned success: false or no data
            return GamesFetchResult.success([]);
          }
        } catch (_) {
          // JSON parsing error
          return GamesFetchResult.error(
            GamesFetchErrorType.parsingError,
            errorMessage: 'Failed to parse server response',
          );
        }
      } else {
        // HTTP error status code (server error)
        return GamesFetchResult.error(
          GamesFetchErrorType.serverError,
          errorMessage: 'Server error: ${response.statusCode}',
        );
      }
    } on SocketException catch (_) {
      // Network error - no internet connection
      return GamesFetchResult.error(
        GamesFetchErrorType.networkError,
        errorMessage: 'No internet connection',
      );
    } on HttpException catch (_) {
      // HTTP error
      return GamesFetchResult.error(
        GamesFetchErrorType.networkError,
        errorMessage: 'Network error occurred',
      );
    } on FormatException catch (_) {
      // URL parsing error
      return GamesFetchResult.error(
        GamesFetchErrorType.parsingError,
        errorMessage: 'Invalid URL format',
      );
    } catch (e) {
      // Timeout or other unknown errors
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('timeout')) {
        return GamesFetchResult.error(
          GamesFetchErrorType.networkError,
          errorMessage: 'Connection timeout. Please check your internet connection',
        );
      }
      return GamesFetchResult.error(
        GamesFetchErrorType.unknownError,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }
}


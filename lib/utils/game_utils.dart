import 'dart:math';
import '../constants/app_constants.dart';

class GameUtils {
  static int calculateGridSize(int level) {
    return level + 3; // Level 1: 4x4, Level 2: 5x5, etc.
  }

  static List<int> generateSolvedState(int gridSize) {
    int totalTiles = gridSize * gridSize;
    return List<int>.generate(totalTiles - 1, (i) => i + 1)..add(AppConstants.emptyTileValue);
  }

  static List<Point<int>> getNeighbors(int row, int col, int gridSize) {
    final neighbors = <Point<int>>[];
    if (row > 0) neighbors.add(Point(row - 1, col));
    if (row < gridSize - 1) neighbors.add(Point(row + 1, col));
    if (col > 0) neighbors.add(Point(row, col - 1));
    if (col < gridSize - 1) neighbors.add(Point(row, col + 1));
    return neighbors;
  }

  static bool isValidMove(Point<int> emptyPos, Point<int> targetPos) {
    final dx = (targetPos.x - emptyPos.x).abs();
    final dy = (targetPos.y - emptyPos.y).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  static double getTileFontSize(int gridSize) {
    if (gridSize <= AppConstants.smallGridThreshold) return AppConstants.largeTileFontSize;
    if (gridSize <= AppConstants.mediumGridThreshold) return AppConstants.mediumTileFontSize;
    if (gridSize <= AppConstants.largeGridThreshold) return AppConstants.smallTileFontSize;
    if (gridSize <= AppConstants.extraLargeGridThreshold) return AppConstants.extraSmallTileFontSize;
    return AppConstants.tinyTileFontSize;
  }

  static double getGoalTileFontSize(int gridSize) {
    if (gridSize <= AppConstants.smallGridThreshold) return 24.0;
    if (gridSize <= AppConstants.mediumGridThreshold) return 20.0;
    if (gridSize <= AppConstants.largeGridThreshold) return 16.0;
    if (gridSize <= AppConstants.extraLargeGridThreshold) return 14.0;
    return 12.0;
  }

  static String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}

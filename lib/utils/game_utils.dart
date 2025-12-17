import 'dart:math';
import '../constants/app_constants.dart';

class GameUtils {
  /// Calculate grid dimensions (rows x columns) for a given level
  /// Level 1: 3x3, Level 2: 3x4, Level 3: 3x5
  /// Level 4: 4x4, Level 5: 4x5, Level 6: 4x6
  /// Level 7: 5x5, Level 8: 5x6, Level 9: 5x7
  /// And so on up to level 21
  static ({int rows, int columns}) calculateGridSize(int level) {
    // Pattern: Every 3 levels, rows increase by 1
    // Within each 3-level group, columns increase by 1
    final baseRow = ((level - 1) ~/ 3) + 3; // Starting from row 3
    final columnOffset = ((level - 1) % 3); // 0, 1, or 2
    final columns = baseRow + columnOffset;
    
    return (rows: baseRow, columns: columns);
  }

  static List<int> generateSolvedState(int rows, int columns) {
    int totalTiles = rows * columns;
    return List<int>.generate(totalTiles - 1, (i) => i + 1)..add(AppConstants.emptyTileValue);
  }

  static List<Point<int>> getNeighbors(int row, int col, int rows, int columns) {
    final neighbors = <Point<int>>[];
    if (row > 0) neighbors.add(Point(row - 1, col));
    if (row < rows - 1) neighbors.add(Point(row + 1, col));
    if (col > 0) neighbors.add(Point(row, col - 1));
    if (col < columns - 1) neighbors.add(Point(row, col + 1));
    return neighbors;
  }

  static bool isValidMove(Point<int> emptyPos, Point<int> targetPos) {
    final dx = (targetPos.x - emptyPos.x).abs();
    final dy = (targetPos.y - emptyPos.y).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  static double getTileFontSize(int rows, int columns) {
    final maxDimension = rows > columns ? rows : columns;
    if (maxDimension <= AppConstants.smallGridThreshold) return AppConstants.largeTileFontSize;
    if (maxDimension <= AppConstants.mediumGridThreshold) return AppConstants.mediumTileFontSize;
    if (maxDimension <= AppConstants.largeGridThreshold) return AppConstants.smallTileFontSize;
    if (maxDimension <= AppConstants.extraLargeGridThreshold) return AppConstants.extraSmallTileFontSize;
    return AppConstants.tinyTileFontSize;
  }

  static double getGoalTileFontSize(int rows, int columns) {
    final maxDimension = rows > columns ? rows : columns;
    if (maxDimension <= AppConstants.smallGridThreshold) return 24.0;
    if (maxDimension <= AppConstants.mediumGridThreshold) return 20.0;
    if (maxDimension <= AppConstants.largeGridThreshold) return 16.0;
    if (maxDimension <= AppConstants.extraLargeGridThreshold) return 14.0;
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

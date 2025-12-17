import 'dart:math';
import '../constants/app_constants.dart';
import '../models/game_state.dart';
import '../utils/game_utils.dart';
import 'level_progression_service.dart';

class GameService {
  static Future<GameState> initializeGame(int level) async {
    final gridDimensions = GameUtils.calculateGridSize(level);
    final solvedState = GameUtils.generateSolvedState(gridDimensions.rows, gridDimensions.columns);
    final emptyPos = Point(gridDimensions.rows - 1, gridDimensions.columns - 1);
    final unlockedLevels = await LevelProgressionService.getUnlockedLevels();
    
    return GameState(
      currentLevel: level,
      maxLevel: AppConstants.maxLevel,
      rows: gridDimensions.rows,
      columns: gridDimensions.columns,
      board: List.from(solvedState),
      initialBoard: List.from(solvedState),
      solvedState: solvedState,
      emptyTilePos: emptyPos,
      initialEmptyPos: emptyPos,
      secondsElapsed: 0,
      movesCount: 0,
      isGameActive: false,
      unlockedLevels: unlockedLevels,
    );
  }

  /// Finds the position of the empty tile in the board
  static Point<int> _findEmptyPosition(List<int> board, int rows, int columns) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == AppConstants.emptyTileValue) {
        return Point(i ~/ columns, i % columns);
      }
    }
    // Fallback to bottom-right corner
    return Point(rows - 1, columns - 1);
  }

  static GameState shuffleBoard(GameState currentState) {
    final random = Random();
    var board = List<int>.from(currentState.solvedState);
    var emptyPos = Point(currentState.rows - 1, currentState.columns - 1);

    // First, perform aggressive random moves to scatter numbers
    for (int i = 0; i < AppConstants.shuffleMoves; i++) {
      final neighbors = GameUtils.getNeighbors(emptyPos.x, emptyPos.y, currentState.rows, currentState.columns);
      if (neighbors.isEmpty) break;
      final randomNeighbor = neighbors[random.nextInt(neighbors.length)];
      
      // Swap tiles
      final tileIndex = randomNeighbor.x * currentState.columns + randomNeighbor.y;
      final emptyIndex = emptyPos.x * currentState.columns + emptyPos.y;
      
      final temp = board[tileIndex];
      board[tileIndex] = board[emptyIndex];
      board[emptyIndex] = temp;
      
      emptyPos = randomNeighbor;
    }

    // Then, apply aggressive anti-sequential algorithm
    board = _applyAntiSequentialShuffle(board, currentState.rows, currentState.columns, random);

    return currentState.copyWith(
      board: board,
      initialBoard: List.from(board),
      emptyTilePos: emptyPos,
      initialEmptyPos: emptyPos,
      secondsElapsed: 0,
      movesCount: 0,
      isGameActive: false,
    );
  }

  /// Aggressive shuffle that ensures no sequential numbers are adjacent
  static List<int> _applyAntiSequentialShuffle(List<int> board, int rows, int columns, Random random) {
    final maxAttempts = 1000;
    int attempts = 0;
    
    while (attempts < maxAttempts && _hasSequentialNeighbors(board, rows, columns)) {
      // Find all sequential pairs
      final sequentialPairs = _findSequentialPairs(board, rows, columns);
      
      if (sequentialPairs.isEmpty) break;
      
      // Randomly select a sequential pair to break
      final pair = sequentialPairs[random.nextInt(sequentialPairs.length)];
      final pos1 = pair['pos1'] as Point<int>;
      final pos2 = pair['pos2'] as Point<int>;
      
      // Find a random position far from both positions
      final farPos = _findFarPosition(pos1, pos2, rows, columns, random);
      
      // Swap one of the sequential numbers with the far position
      final index1 = pos1.x * columns + pos1.y;
      final index2 = pos2.x * columns + pos2.y;
      final farIndex = farPos.x * columns + farPos.y;
      
      // Choose which number to move (avoid moving empty tile)
      if (board[index1] != AppConstants.emptyTileValue) {
        final temp = board[index1];
        board[index1] = board[farIndex];
        board[farIndex] = temp;
      } else if (board[index2] != AppConstants.emptyTileValue) {
        final temp = board[index2];
        board[index2] = board[farIndex];
        board[farIndex] = temp;
      }
      
      attempts++;
    }
    
    return board;
  }

  /// Check if board has any sequential numbers that are neighbors
  static bool _hasSequentialNeighbors(List<int> board, int rows, int columns) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == AppConstants.emptyTileValue) continue;
      
      final row = i ~/ columns;
      final col = i % columns;
      final currentValue = board[i];
      
      // Check all 8 directions (including diagonals)
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          
          final newRow = row + dr;
          final newCol = col + dc;
          
          if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
            final neighborIndex = newRow * columns + newCol;
            final neighborValue = board[neighborIndex];
            
            if (neighborValue != AppConstants.emptyTileValue) {
              // Check if they are sequential (difference of 1)
              if ((currentValue - neighborValue).abs() == 1) {
                return true;
              }
            }
          }
        }
      }
    }
    return false;
  }

  /// Find all pairs of sequential numbers that are neighbors
  static List<Map<String, dynamic>> _findSequentialPairs(List<int> board, int rows, int columns) {
    final pairs = <Map<String, dynamic>>[];
    
    for (int i = 0; i < board.length; i++) {
      if (board[i] == AppConstants.emptyTileValue) continue;
      
      final row = i ~/ columns;
      final col = i % columns;
      final currentValue = board[i];
      
      // Check all 8 directions (including diagonals)
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          
          final newRow = row + dr;
          final newCol = col + dc;
          
          if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
            final neighborIndex = newRow * columns + newCol;
            final neighborValue = board[neighborIndex];
            
            if (neighborValue != AppConstants.emptyTileValue) {
              // Check if they are sequential (difference of 1)
              if ((currentValue - neighborValue).abs() == 1) {
                pairs.add({
                  'pos1': Point(row, col),
                  'pos2': Point(newRow, newCol),
                  'value1': currentValue,
                  'value2': neighborValue,
                });
              }
            }
          }
        }
      }
    }
    
    return pairs;
  }

  /// Find a position that is far from both given positions
  static Point<int> _findFarPosition(Point<int> pos1, Point<int> pos2, int rows, int columns, Random random) {
    final maxDistance = ((rows + columns) * 0.35).round(); // At least 35% of average dimension away
    int attempts = 0;
    
    while (attempts < 100) {
      final candidate = Point(
        random.nextInt(rows),
        random.nextInt(columns),
      );
      
      final distance1 = (candidate.x - pos1.x).abs() + (candidate.y - pos1.y).abs();
      final distance2 = (candidate.x - pos2.x).abs() + (candidate.y - pos2.y).abs();
      
      if (distance1 >= maxDistance && distance2 >= maxDistance) {
        return candidate;
      }
      
      attempts++;
    }
    
    // Fallback: return a random position
    return Point(random.nextInt(rows), random.nextInt(columns));
  }


  static GameState moveTile(GameState currentState, int row, int col) {
    if (!currentState.isGameActive) return currentState;
    
    // Find the actual empty position in the current board
    final actualEmptyPos = _findEmptyPosition(currentState.board, currentState.rows, currentState.columns);
    final targetPos = Point(row, col);
    
    // Check if the target position is adjacent to the empty position
    if (!GameUtils.isValidMove(actualEmptyPos, targetPos)) {
      return currentState;
    }

    final newBoard = List<int>.from(currentState.board);
    final tileIndex = row * currentState.columns + col;
    final emptyIndex = actualEmptyPos.x * currentState.columns + actualEmptyPos.y;

    // Verify the tile at target position is not empty
    if (newBoard[tileIndex] == AppConstants.emptyTileValue) {
      return currentState;
    }

    // Swap tiles
    final temp = newBoard[tileIndex];
    newBoard[tileIndex] = newBoard[emptyIndex];
    newBoard[emptyIndex] = temp;

    return currentState.copyWith(
      board: newBoard,
      emptyTilePos: targetPos,
      movesCount: currentState.movesCount + 1,
    );
  }

  /// Swaps two tiles horizontally (same row, different columns)
  static GameState swapTiles(GameState currentState, int row1, int col1, int row2, int col2) {
    if (!currentState.isGameActive) return currentState;
    
    // Validate positions
    if (row1 < 0 || row1 >= currentState.rows || 
        row2 < 0 || row2 >= currentState.rows ||
        col1 < 0 || col1 >= currentState.columns ||
        col2 < 0 || col2 >= currentState.columns) {
      return currentState;
    }
    
    // Must be in the same row
    if (row1 != row2) {
      return currentState;
    }
    
    final newBoard = List<int>.from(currentState.board);
    final index1 = row1 * currentState.columns + col1;
    final index2 = row2 * currentState.columns + col2;
    
    // Swap the tiles
    final temp = newBoard[index1];
    newBoard[index1] = newBoard[index2];
    newBoard[index2] = temp;
    
    // Update empty tile position if it was involved in the swap
    final newEmptyPos = _findEmptyPosition(newBoard, currentState.rows, currentState.columns);
    
    return currentState.copyWith(
      board: newBoard,
      emptyTilePos: newEmptyPos,
      movesCount: currentState.movesCount + 1,
    );
  }

  static GameState resetToInitial(GameState currentState) {
    return currentState.copyWith(
      board: List.from(currentState.initialBoard),
      emptyTilePos: currentState.initialEmptyPos,
      movesCount: 0,
      secondsElapsed: 0,
      isGameActive: false,
    );
  }

  static GameState startGame(GameState currentState) {
    return currentState.copyWith(isGameActive: true);
  }

  static GameState updateTimer(GameState currentState) {
    return currentState.copyWith(secondsElapsed: currentState.secondsElapsed + 1);
  }

  static Future<GameState> nextLevel(GameState currentState) async {
    if (currentState.currentLevel >= currentState.maxLevel) {
      return currentState;
    }
    
    final newLevel = currentState.currentLevel + 1;
    return await initializeGame(newLevel);
  }

  static Future<GameState> playAgain(GameState currentState) async {
    return await initializeGame(1);
  }

  /// Handle level completion and unlock next level
  static Future<GameState> completeLevel(GameState currentState) async {
    // Mark the current level as completed
    await LevelProgressionService.markLevelCompleted(currentState.currentLevel);
    
    // Unlock the next level
    await LevelProgressionService.unlockNextLevel(currentState.currentLevel);
    
    // Get updated unlocked levels
    final updatedUnlockedLevels = await LevelProgressionService.getUnlockedLevels();
    
    // Return updated state with new unlocked levels
    return currentState.copyWith(unlockedLevels: updatedUnlockedLevels);
  }
}

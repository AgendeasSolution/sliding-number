import 'dart:math';
import '../constants/app_constants.dart';
import '../models/game_state.dart';
import '../utils/game_utils.dart';
import 'level_progression_service.dart';

class GameService {
  static Future<GameState> initializeGame(int level) async {
    final gridSize = GameUtils.calculateGridSize(level);
    final solvedState = GameUtils.generateSolvedState(gridSize);
    final emptyPos = Point(gridSize - 1, gridSize - 1);
    final unlockedLevels = await LevelProgressionService.getUnlockedLevels();
    
    return GameState(
      currentLevel: level,
      maxLevel: AppConstants.maxLevel,
      gridSize: gridSize,
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
  static Point<int> _findEmptyPosition(List<int> board, int gridSize) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == AppConstants.emptyTileValue) {
        return Point(i ~/ gridSize, i % gridSize);
      }
    }
    // Fallback to bottom-right corner
    return Point(gridSize - 1, gridSize - 1);
  }

  static GameState shuffleBoard(GameState currentState) {
    final random = Random();
    var board = List<int>.from(currentState.solvedState);
    var emptyPos = Point(currentState.gridSize - 1, currentState.gridSize - 1);

    // First, perform aggressive random moves to scatter numbers
    for (int i = 0; i < AppConstants.shuffleMoves; i++) {
      final neighbors = GameUtils.getNeighbors(emptyPos.x, emptyPos.y, currentState.gridSize);
      final randomNeighbor = neighbors[random.nextInt(neighbors.length)];
      
      // Swap tiles
      final tileIndex = randomNeighbor.x * currentState.gridSize + randomNeighbor.y;
      final emptyIndex = emptyPos.x * currentState.gridSize + emptyPos.y;
      
      final temp = board[tileIndex];
      board[tileIndex] = board[emptyIndex];
      board[emptyIndex] = temp;
      
      emptyPos = randomNeighbor;
    }

    // Then, apply aggressive anti-sequential algorithm
    board = _applyAntiSequentialShuffle(board, currentState.gridSize, random);

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
  static List<int> _applyAntiSequentialShuffle(List<int> board, int gridSize, Random random) {
    final maxAttempts = 1000;
    int attempts = 0;
    
    while (attempts < maxAttempts && _hasSequentialNeighbors(board, gridSize)) {
      // Find all sequential pairs
      final sequentialPairs = _findSequentialPairs(board, gridSize);
      
      if (sequentialPairs.isEmpty) break;
      
      // Randomly select a sequential pair to break
      final pair = sequentialPairs[random.nextInt(sequentialPairs.length)];
      final pos1 = pair['pos1'] as Point<int>;
      final pos2 = pair['pos2'] as Point<int>;
      
      // Find a random position far from both positions
      final farPos = _findFarPosition(pos1, pos2, gridSize, random);
      
      // Swap one of the sequential numbers with the far position
      final index1 = pos1.x * gridSize + pos1.y;
      final index2 = pos2.x * gridSize + pos2.y;
      final farIndex = farPos.x * gridSize + farPos.y;
      
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
  static bool _hasSequentialNeighbors(List<int> board, int gridSize) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == AppConstants.emptyTileValue) continue;
      
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final currentValue = board[i];
      
      // Check all 8 directions (including diagonals)
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          
          final newRow = row + dr;
          final newCol = col + dc;
          
          if (newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize) {
            final neighborIndex = newRow * gridSize + newCol;
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
  static List<Map<String, dynamic>> _findSequentialPairs(List<int> board, int gridSize) {
    final pairs = <Map<String, dynamic>>[];
    
    for (int i = 0; i < board.length; i++) {
      if (board[i] == AppConstants.emptyTileValue) continue;
      
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final currentValue = board[i];
      
      // Check all 8 directions (including diagonals)
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          
          final newRow = row + dr;
          final newCol = col + dc;
          
          if (newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize) {
            final neighborIndex = newRow * gridSize + newCol;
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
  static Point<int> _findFarPosition(Point<int> pos1, Point<int> pos2, int gridSize, Random random) {
    final maxDistance = (gridSize * 0.7).round(); // At least 70% of grid size away
    int attempts = 0;
    
    while (attempts < 100) {
      final candidate = Point(
        random.nextInt(gridSize),
        random.nextInt(gridSize),
      );
      
      final distance1 = (candidate.x - pos1.x).abs() + (candidate.y - pos1.y).abs();
      final distance2 = (candidate.x - pos2.x).abs() + (candidate.y - pos2.y).abs();
      
      if (distance1 >= maxDistance && distance2 >= maxDistance) {
        return candidate;
      }
      
      attempts++;
    }
    
    // Fallback: return a random position
    return Point(random.nextInt(gridSize), random.nextInt(gridSize));
  }

  static GameState moveTile(GameState currentState, int row, int col) {
    if (!currentState.isGameActive) return currentState;
    
    final targetPos = Point(row, col);
    if (!GameUtils.isValidMove(currentState.emptyTilePos, targetPos)) {
      return currentState;
    }

    final newBoard = List<int>.from(currentState.board);
    final tileIndex = row * currentState.gridSize + col;
    final emptyIndex = currentState.emptyTilePos.x * currentState.gridSize + currentState.emptyTilePos.y;

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

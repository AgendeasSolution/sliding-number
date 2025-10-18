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

    // Phase 1: Basic shuffle with many moves
    final basicShuffleMoves = (currentState.gridSize * currentState.gridSize * 3).clamp(100, 300);
    for (int i = 0; i < basicShuffleMoves; i++) {
      final neighbors = GameUtils.getNeighbors(emptyPos.x, emptyPos.y, currentState.gridSize);
      if (neighbors.isNotEmpty) {
        final randomNeighbor = neighbors[random.nextInt(neighbors.length)];
        
        // Swap tiles
        final tileIndex = randomNeighbor.x * currentState.gridSize + randomNeighbor.y;
        final emptyIndex = emptyPos.x * currentState.gridSize + emptyPos.y;
        
        final temp = board[tileIndex];
        board[tileIndex] = board[emptyIndex];
        board[emptyIndex] = temp;
        
        emptyPos = randomNeighbor;
      }
    }

    // Phase 2: Separate sequential numbers (simple and fast)
    board = _separateSequentialNumbers(board, currentState.gridSize, random);

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

  /// Simple and fast method to separate sequential numbers
  static List<int> _separateSequentialNumbers(List<int> board, int gridSize, Random random) {
    final maxAttempts = 50; // Keep it simple and fast
    int attempts = 0;
    
    while (attempts < maxAttempts && _hasAdjacentSequentialNumbers(board, gridSize)) {
      // Find one pair of adjacent sequential numbers
      final sequentialPair = _findFirstSequentialPair(board, gridSize);
      if (sequentialPair == null) break;
      
      final pos1 = sequentialPair['pos1'] as Point<int>;
      final pos2 = sequentialPair['pos2'] as Point<int>;
      
      // Find a random position far from both
      final farPos = _findRandomFarPosition(pos1, pos2, gridSize, random);
      
      // Swap one of the sequential numbers with the far position
      final index1 = pos1.x * gridSize + pos1.y;
      final farIndex = farPos.x * gridSize + farPos.y;
      
      if (board[index1] != AppConstants.emptyTileValue) {
        final temp = board[index1];
        board[index1] = board[farIndex];
        board[farIndex] = temp;
      }
      
      attempts++;
    }
    
    return board;
  }

  /// Check if board has adjacent sequential numbers (orthogonal only)
  static bool _hasAdjacentSequentialNumbers(List<int> board, int gridSize) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == AppConstants.emptyTileValue) continue;
      
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final currentValue = board[i];
      
      // Check only orthogonal directions (up, down, left, right)
      final directions = [
        [-1, 0], [1, 0], [0, -1], [0, 1]
      ];
      
      for (final dir in directions) {
        final newRow = row + dir[0];
        final newCol = col + dir[1];
        
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
    return false;
  }

  /// Find the first pair of adjacent sequential numbers
  static Map<String, dynamic>? _findFirstSequentialPair(List<int> board, int gridSize) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == AppConstants.emptyTileValue) continue;
      
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final currentValue = board[i];
      
      // Check only orthogonal directions
      final directions = [
        [-1, 0], [1, 0], [0, -1], [0, 1]
      ];
      
      for (final dir in directions) {
        final newRow = row + dir[0];
        final newCol = col + dir[1];
        
        if (newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize) {
          final neighborIndex = newRow * gridSize + newCol;
          final neighborValue = board[neighborIndex];
          
          if (neighborValue != AppConstants.emptyTileValue) {
            if ((currentValue - neighborValue).abs() == 1) {
              return {
                'pos1': Point(row, col),
                'pos2': Point(newRow, newCol),
                'value1': currentValue,
                'value2': neighborValue,
              };
            }
          }
        }
      }
    }
    return null;
  }

  /// Find a random position that is far from both given positions
  static Point<int> _findRandomFarPosition(Point<int> pos1, Point<int> pos2, int gridSize, Random random) {
    final minDistance = (gridSize * 0.4).round(); // At least 40% of grid size away
    int attempts = 0;
    
    while (attempts < 20) { // Keep attempts low for performance
      final candidate = Point(
        random.nextInt(gridSize),
        random.nextInt(gridSize),
      );
      
      final distance1 = (candidate.x - pos1.x).abs() + (candidate.y - pos1.y).abs();
      final distance2 = (candidate.x - pos2.x).abs() + (candidate.y - pos2.y).abs();
      
      if (distance1 >= minDistance && distance2 >= minDistance) {
        return candidate;
      }
      
      attempts++;
    }
    
    // Fallback: return a random position
    return Point(random.nextInt(gridSize), random.nextInt(gridSize));
  }


  static GameState moveTile(GameState currentState, int row, int col) {
    if (!currentState.isGameActive) return currentState;
    
    // Find the actual empty position in the current board
    final actualEmptyPos = _findEmptyPosition(currentState.board, currentState.gridSize);
    final targetPos = Point(row, col);
    
    // Check if the target position is adjacent to the empty position
    if (!GameUtils.isValidMove(actualEmptyPos, targetPos)) {
      return currentState;
    }

    final newBoard = List<int>.from(currentState.board);
    final tileIndex = row * currentState.gridSize + col;
    final emptyIndex = actualEmptyPos.x * currentState.gridSize + actualEmptyPos.y;

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

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
    final board = List<int>.from(currentState.solvedState);
    var emptyPos = Point(currentState.gridSize - 1, currentState.gridSize - 1);

    // Perform random moves to shuffle
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

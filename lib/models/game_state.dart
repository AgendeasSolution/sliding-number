import 'dart:math';

class GameState {
  final int currentLevel;
  final int maxLevel;
  final int gridSize;
  final List<int> board;
  final List<int> initialBoard;
  final List<int> solvedState;
  final Point<int> emptyTilePos;
  final Point<int> initialEmptyPos;
  final int secondsElapsed;
  final int movesCount;
  final bool isGameActive;
  final List<int> unlockedLevels;

  const GameState({
    required this.currentLevel,
    required this.maxLevel,
    required this.gridSize,
    required this.board,
    required this.initialBoard,
    required this.solvedState,
    required this.emptyTilePos,
    required this.initialEmptyPos,
    required this.secondsElapsed,
    required this.movesCount,
    required this.isGameActive,
    required this.unlockedLevels,
  });

  GameState copyWith({
    int? currentLevel,
    int? maxLevel,
    int? gridSize,
    List<int>? board,
    List<int>? initialBoard,
    List<int>? solvedState,
    Point<int>? emptyTilePos,
    Point<int>? initialEmptyPos,
    int? secondsElapsed,
    int? movesCount,
    bool? isGameActive,
    List<int>? unlockedLevels,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      gridSize: gridSize ?? this.gridSize,
      board: board ?? this.board,
      initialBoard: initialBoard ?? this.initialBoard,
      solvedState: solvedState ?? this.solvedState,
      emptyTilePos: emptyTilePos ?? this.emptyTilePos,
      initialEmptyPos: initialEmptyPos ?? this.initialEmptyPos,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      movesCount: movesCount ?? this.movesCount,
      isGameActive: isGameActive ?? this.isGameActive,
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
    );
  }

  bool get isGameComplete => currentLevel == maxLevel;
  bool get isWin => _checkWin();
  
  bool isLevelUnlocked(int level) => unlockedLevels.contains(level);

  bool _checkWin() {
    for (int i = 0; i < board.length; i++) {
      if (board[i] != solvedState[i]) return false;
    }
    return true;
  }
}

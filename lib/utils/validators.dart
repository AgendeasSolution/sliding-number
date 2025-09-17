class Validators {
  static bool isValidLevel(int level) {
    return level >= 1 && level <= 9;
  }

  static bool isValidGridSize(int gridSize) {
    return gridSize >= 4 && gridSize <= 12;
  }

  static bool isValidTileValue(int value, int gridSize) {
    return value >= 0 && value < gridSize * gridSize;
  }
}

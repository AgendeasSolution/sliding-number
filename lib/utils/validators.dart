class Validators {
  static bool isValidLevel(int level) {
    return level >= 1 && level <= 21;
  }

  static bool isValidGridSize(int rows, int columns) {
    return rows >= 3 && rows <= 11 && columns >= 3 && columns <= 11;
  }

  static bool isValidTileValue(int value, int rows, int columns) {
    return value >= 0 && value < rows * columns;
  }
}

class AppConstants {
  // Game Configuration
  static const int maxLevel = 18;
  static const int emptyTileValue = 0;
  static const int shuffleMoves = 500; // Increased for more challenging shuffle
  
  // UI Constants
  static const double tileSpacing = 4.0;
  static const double tileBorderRadius = 8.0;
  static const double modalBorderRadius = 24.0;
  static const double buttonBorderRadius = 12.0;
  
  // Animation Durations
  static const Duration tileAnimationDuration = Duration(milliseconds: 200);
  static const Duration modalAnimationDuration = Duration(milliseconds: 300);
  
  // Font Sizes
  static const double largeTileFontSize = 32.0;
  static const double mediumTileFontSize = 24.0;
  static const double smallTileFontSize = 18.0;
  static const double extraSmallTileFontSize = 16.0;
  static const double tinyTileFontSize = 14.0;
  
  // Grid Size Thresholds
  static const int smallGridThreshold = 4;
  static const int mediumGridThreshold = 6;
  static const int largeGridThreshold = 8;
  static const int extraLargeGridThreshold = 10;
}

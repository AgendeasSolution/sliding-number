import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../models/game_state.dart';
import 'game_tile.dart';

class GameBoard extends StatelessWidget {
  final GameState gameState;
  final Function(int row, int col) onTileTap;
  final Function(DragEndDetails) onVerticalDragEnd;
  final Function(DragEndDetails) onHorizontalDragEnd;
  final bool isSwapMode;
  final String? swapDirection;

  const GameBoard({
    super.key,
    required this.gameState,
    required this.onTileTap,
    required this.onVerticalDragEnd,
    required this.onHorizontalDragEnd,
    this.isSwapMode = false,
    this.swapDirection,
  });

  @override
  Widget build(BuildContext context) {
    if (gameState.board.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate board dimensions based on aspect ratio
        final availableWidth = constraints.maxWidth;
        final aspectRatio = gameState.rows / gameState.columns;
        final boardWidth = availableWidth;
        final boardHeight = boardWidth * aspectRatio;

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: GestureDetector(
              onVerticalDragEnd: onVerticalDragEnd,
              onHorizontalDragEnd: onHorizontalDragEnd,
              child: Container(
                decoration: BoxDecoration(
                  // Outer wooden frame for the board (no shadow)
                  color: AppColors.woodButtonFill,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.woodButtonBorderDark,
                    width: 3,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    // Inner inset frame to mimic wooden tray
                    color: AppColors.woodBackground.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.woodButtonBorderLight,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gameState.columns,
                      mainAxisSpacing: AppConstants.tileSpacing,
                      crossAxisSpacing: AppConstants.tileSpacing,
                    ),
                    itemCount: gameState.rows * gameState.columns,
                    itemBuilder: (context, index) {
                      final tileValue = gameState.board[index];
                      final isVisible =
                          tileValue != AppConstants.emptyTileValue;
                      final row = index ~/ gameState.columns;
                      final col = index % gameState.columns;

                      // Determine if this tile should be highlighted
                      bool isHighlighted = false;
                      if (isSwapMode && isVisible && swapDirection != null) {
                        // Highlight tiles that can be swapped
                        if (swapDirection == 'left') {
                          // For left swap, highlight tiles that have a tile to their left
                          isHighlighted = col > 0;
                        } else if (swapDirection == 'right') {
                          // For right swap, highlight tiles that have a tile to their right
                          isHighlighted = col < gameState.columns - 1;
                        }
                      }

                      return GameTile(
                        tileValue: tileValue,
                        index: index,
                        rows: gameState.rows,
                        columns: gameState.columns,
                        isVisible: isVisible,
                        isHighlighted: isHighlighted,
                        onTap: () => onTileTap(row, col),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
        // Constants for spacing
        const outerBorderWidth = 3.0;
        const innerMargin = 3.0;
        const innerPadding = 6.0;
        const totalHorizontalPadding = outerBorderWidth + innerMargin + innerPadding;
        const totalVerticalPadding = outerBorderWidth + innerMargin + innerPadding;
        
        // Calculate available width for the grid content
        final availableWidth = constraints.maxWidth;
        final gridContentWidth = availableWidth - (totalHorizontalPadding * 2);
        
        // Calculate tile size based on columns and spacing
        final tileSpacing = AppConstants.tileSpacing;
        final tileWidth = (gridContentWidth - (tileSpacing * (gameState.columns - 1))) / gameState.columns;
        
        // Calculate grid content height based on rows and tile size
        final gridContentHeight = (tileWidth * gameState.rows) + (tileSpacing * (gameState.rows - 1));
        
        // Calculate total board height including all padding/margins/borders
        final boardWidth = availableWidth;
        final boardHeight = gridContentHeight + (totalVerticalPadding * 2);

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: GestureDetector(
              onVerticalDragEnd: onVerticalDragEnd,
              onHorizontalDragEnd: onHorizontalDragEnd,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  // Outer wooden frame for the board (no shadow)
                  color: AppColors.woodButtonFill,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.woodButtonBorderDark,
                    width: outerBorderWidth,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(innerMargin),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    // Inner inset frame to mimic wooden tray
                    color: AppColors.woodBackground.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.woodButtonBorderLight,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(innerPadding),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gameState.columns,
                      mainAxisSpacing: tileSpacing,
                      crossAxisSpacing: tileSpacing,
                      childAspectRatio: 1.0,
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

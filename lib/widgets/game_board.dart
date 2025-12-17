import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/game_state.dart';
import 'game_tile.dart';

class GameBoard extends StatelessWidget {
  final GameState gameState;
  final Function(int row, int col) onTileTap;
  final Function(DragEndDetails) onVerticalDragEnd;
  final Function(DragEndDetails) onHorizontalDragEnd;

  const GameBoard({
    super.key,
    required this.gameState,
    required this.onTileTap,
    required this.onVerticalDragEnd,
    required this.onHorizontalDragEnd,
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
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF374151), Color(0xFF4B5563)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
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
                    final isVisible = tileValue != AppConstants.emptyTileValue;
                    final row = index ~/ gameState.columns;
                    final col = index % gameState.columns;

                    return GameTile(
                      tileValue: tileValue,
                      index: index,
                      rows: gameState.rows,
                      columns: gameState.columns,
                      isVisible: isVisible,
                      onTap: () => onTileTap(row, col),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

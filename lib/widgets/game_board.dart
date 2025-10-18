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
        // Use full width and calculate height to maintain square aspect ratio
        final availableWidth = constraints.maxWidth;
        final boardSize = availableWidth;
        
        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
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
                    crossAxisCount: gameState.gridSize,
                    mainAxisSpacing: AppConstants.tileSpacing,
                    crossAxisSpacing: AppConstants.tileSpacing,
                  ),
                  itemCount: gameState.gridSize * gameState.gridSize,
                  itemBuilder: (context, index) {
                    final tileValue = gameState.board[index];
                    final isVisible = tileValue != AppConstants.emptyTileValue;
                    final row = index ~/ gameState.gridSize;
                    final col = index % gameState.gridSize;

                    return GameTile(
                      tileValue: tileValue,
                      index: index,
                      gridSize: gameState.gridSize,
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

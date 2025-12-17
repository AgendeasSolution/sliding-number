import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/game_state.dart';
import '../utils/game_utils.dart';

class GoalBoard extends StatelessWidget {
  final GameState gameState;

  const GoalBoard({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final aspectRatio = gameState.rows / gameState.columns;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF374151), Color(0xFF4B5563)],
          ),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gameState.columns,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: gameState.rows * gameState.columns,
          itemBuilder: (context, index) {
            final value = gameState.solvedState[index];
            final isEmpty = value == AppConstants.emptyTileValue;
            
            return Container(
              decoration: BoxDecoration(
                gradient: isEmpty ? null : const LinearGradient(
                  colors: [AppColors.success, AppColors.successDark],
                ),
                border: isEmpty ? Border.all(
                  color: AppColors.success.withValues(alpha: 0.5),
                  width: 2,
                  style: BorderStyle.solid,
                ) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isEmpty ? '' : '$value',
                  style: TextStyle(
                    fontSize: GameUtils.getGoalTileFontSize(gameState.rows, gameState.columns),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

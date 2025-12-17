import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/game_utils.dart';

class GameTile extends StatelessWidget {
  final int tileValue;
  final int index;
  final int rows;
  final int columns;
  final VoidCallback onTap;
  final bool isVisible;

  const GameTile({
    super.key,
    required this.tileValue,
    required this.index,
    required this.rows,
    required this.columns,
    required this.onTap,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: AppConstants.tileAnimationDuration,
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: isVisible ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE9AF51), Color(0xFFD4A046)],
            ) : null,
            border: isVisible ? null : Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppConstants.tileBorderRadius),
            boxShadow: isVisible ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : [],
          ),
          child: Center(
            child: Text(
              isVisible ? '$tileValue' : '',
              style: TextStyle(
                fontSize: GameUtils.getTileFontSize(rows, columns),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

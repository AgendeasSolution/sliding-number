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
  final bool isHighlighted;

  const GameTile({
    super.key,
    required this.tileValue,
    required this.index,
    required this.rows,
    required this.columns,
    required this.onTap,
    required this.isVisible,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: AppConstants.tileAnimationDuration,
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            // Wooden-style tiles to match home screen & reference game
            gradient: isVisible
                ? (isHighlighted
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryGold,
                          AppColors.primaryGoldDark,
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF8E7C5), // light cream top
                          Color(0xFFE2C89F), // slightly darker bottom
                        ],
                      ))
                : null,
            border: isVisible
                ? Border.all(
                    color: AppColors.woodButtonBorderDark,
                    width: isHighlighted ? 3 : 2,
                  )
                : Border.all(
                    color: AppColors.woodButtonBorderLight.withValues(alpha: 0.5),
                    width: 2,
                  ),
            borderRadius: BorderRadius.circular(AppConstants.tileBorderRadius),
            boxShadow: isVisible
                ? [
                    BoxShadow(
                      color: isHighlighted
                          ? AppColors.primaryGold.withValues(alpha: 0.55)
                          : Colors.black.withValues(alpha: 0.25),
                      blurRadius: isHighlighted ? 14 : 9,
                      offset: const Offset(0, 5),
                      spreadRadius: isHighlighted ? 2 : 0,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isVisible ? '$tileValue' : '',
                style: TextStyle(
                  fontSize: GameUtils.getTileFontSize(rows, columns),
                  fontWeight: FontWeight.w900,
                  color: AppColors.woodButtonText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

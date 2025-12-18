import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_utils.dart';
import '../utils/style_utils.dart';

/// Reusable level card widget
/// Extracted from home_page.dart for better organization and reusability
class LevelCard extends StatelessWidget {
  final int level;
  final int rows;
  final int columns;
  final String difficulty;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.rows,
    required this.columns,
    required this.difficulty,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive values
    final cardPadding = ResponsiveUtils.getResponsiveValue(
      context,
      smallMobile: 4.0,
      mobile: 5.0,
      largeMobile: 6.0,
      tablet: 8.0,
      desktop: 10.0,
    );

    final iconSize = ResponsiveUtils.getResponsiveValue(
      context,
      smallMobile: 28.0,
      mobile: 32.0,
      largeMobile: 36.0,
      tablet: 40.0,
      desktop: 44.0,
    );

    final checkmarkSpacing = ResponsiveUtils.getResponsiveValue(
      context,
      smallMobile: 4.0,
      mobile: 5.0,
      largeMobile: 6.0,
      tablet: 7.0,
      desktop: 8.0,
    );

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: StyleUtils.getLevelCardGradient(
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
            ),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: StyleUtils.getCardBorder(
            color: StyleUtils.getLevelCardBorderColor(
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
            ),
            width: 2.0,
          ),
          boxShadow: StyleUtils.getLevelCardShadow(
            isCompleted: isCompleted,
            isUnlocked: isUnlocked,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isUnlocked ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Level number with enhanced styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$level',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _getLevelNumberColor(),
                        shadows: _getLevelNumberShadows(),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  // Checkmark icon for completed levels
                  if (isCompleted) ...[
                    SizedBox(height: checkmarkSpacing + 4),
                    Container(
                      width: iconSize + 4,
                      height: iconSize + 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: iconSize * 0.6,
                        ),
                      ),
                    ),
                  ],
                  // Lock icon in circle - only for locked levels
                  if (!isUnlocked) ...[
                    SizedBox(height: checkmarkSpacing + 4),
                    Container(
                      width: iconSize + 4,
                      height: iconSize + 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.withValues(alpha: 0.3),
                            Colors.grey.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4),
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lock,
                          color: Colors.grey.shade300,
                          size: iconSize * 0.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelNumberColor() {
    if (isCompleted) {
      return Colors.white;
    } else if (isUnlocked) {
      return Colors.white;
    } else {
      return Colors.grey.shade400;
    }
  }

  List<Shadow> _getLevelNumberShadows() {
    if (isCompleted) {
      return StyleUtils.getGlowTextShadow(
        glowColor: AppColors.completedAccent,
        blurRadius: 6,
        offset: const Offset(2, 2),
      );
    } else if (isUnlocked) {
      return StyleUtils.getGlowTextShadow(
        glowColor: AppColors.infoLight,
        blurRadius: 6,
        offset: const Offset(2, 2),
      );
    } else {
      return StyleUtils.getTextShadow(
        blurRadius: 3,
        offset: const Offset(1, 1),
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Utility class for common styling patterns
/// Eliminates code duplication and provides reusable style builders
class StyleUtils {
  StyleUtils._();

  /// Common box shadow for cards
  static List<BoxShadow> getCardShadow({
    Color? color,
    double blurRadius = 12,
    double spreadRadius = 1,
    Offset offset = const Offset(0, 4),
  }) {
    final shadowColor = color ?? AppColors.primaryGold;
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.4),
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: blurRadius * 0.67,
        offset: Offset(offset.dx, offset.dy * 0.5),
      ),
    ];
  }

  /// Enhanced card shadow with glow effect
  static List<BoxShadow> getGlowShadow({
    required Color color,
    double blurRadius = 20,
    double spreadRadius = 4,
    Offset offset = const Offset(0, 6),
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.6),
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: blurRadius * 1.5,
        offset: Offset(offset.dx, offset.dy * 1.33),
        spreadRadius: spreadRadius * 0.5,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: blurRadius * 0.6,
        offset: Offset(offset.dx, offset.dy * 0.67),
      ),
    ];
  }

  /// Subtle shadow for locked/disabled states
  static List<BoxShadow> getSubtleShadow({
    double blurRadius = 8,
    Offset offset = const Offset(0, 2),
  }) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: blurRadius * 0.5,
        offset: Offset(offset.dx, offset.dy * 0.5),
      ),
    ];
  }

  /// Text shadow for better readability
  static List<Shadow> getTextShadow({
    double blurRadius = 3,
    Offset offset = const Offset(1, 1),
    double alpha = 0.7,
  }) {
    return [
      Shadow(
        color: Colors.black.withValues(alpha: alpha),
        offset: offset,
        blurRadius: blurRadius,
      ),
    ];
  }

  /// Enhanced text shadow with glow
  static List<Shadow> getGlowTextShadow({
    required Color glowColor,
    double blurRadius = 6,
    Offset offset = const Offset(2, 2),
  }) {
    return [
      Shadow(
        color: Colors.black.withValues(alpha: 0.9),
        offset: offset,
        blurRadius: blurRadius,
      ),
      Shadow(
        color: glowColor.withValues(alpha: 0.3),
        offset: Offset(-offset.dx * 0.5, -offset.dy * 0.5),
        blurRadius: blurRadius * 0.67,
      ),
    ];
  }

  /// Common border for cards
  static Border getCardBorder({
    Color? color,
    double width = 2.0,
    double alpha = 0.4,
  }) {
    final borderColor = color ?? AppColors.primaryGold;
    return Border.all(
      color: borderColor.withValues(alpha: alpha),
      width: width,
    );
  }

  /// Gradient border decoration
  static BoxDecoration getGradientBorderDecoration({
    required Gradient gradient,
    double borderRadius = 12.0,
    Color? borderColor,
    double borderWidth = 2.0,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(
              color: borderColor,
              width: borderWidth,
            )
          : null,
      boxShadow: boxShadow ?? getCardShadow(),
    );
  }

  /// Standard button decoration
  static BoxDecoration getButtonDecoration({
    Gradient? gradient,
    Color? backgroundColor,
    double borderRadius = 12.0,
    Color? borderColor,
    double borderWidth = 2.0,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(
              color: borderColor,
              width: borderWidth,
            )
          : null,
      boxShadow: boxShadow ?? getCardShadow(),
    );
  }

  /// Modal container decoration
  static BoxDecoration getModalDecoration({
    double borderRadius = 24.0,
    Color? borderColor,
    double borderWidth = 2.0,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A0E27),
          Color(0xFF1A1F3A),
          Color(0xFF2A2F4D),
          Color(0xFF1A1F3A),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: (borderColor ?? AppColors.primaryGold).withValues(alpha: 0.4),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 25,
        ),
      ],
    );
  }

  /// Level card gradient based on state
  static List<Color> getLevelCardGradient({
    required bool isCompleted,
    required bool isUnlocked,
  }) {
    if (isCompleted) {
      return [AppColors.completed, AppColors.completedDark];
    } else if (isUnlocked) {
      return [AppColors.info, AppColors.infoDark];
    } else {
      return [Colors.grey.shade700, Colors.grey.shade900];
    }
  }

  /// Level card border color based on state
  static Color getLevelCardBorderColor({
    required bool isCompleted,
    required bool isUnlocked,
  }) {
    if (isCompleted) {
      return Colors.white.withValues(alpha: 0.5);
    } else if (isUnlocked) {
      return Colors.white.withValues(alpha: 0.4);
    } else {
      return Colors.grey.withValues(alpha: 0.3);
    }
  }

  /// Level card shadow based on state
  static List<BoxShadow> getLevelCardShadow({
    required bool isCompleted,
    required bool isUnlocked,
  }) {
    if (isCompleted) {
      return getGlowShadow(
        color: AppColors.completed,
        blurRadius: 20,
        spreadRadius: 4,
      );
    } else if (isUnlocked) {
      return getGlowShadow(
        color: AppColors.info,
        blurRadius: 18,
        spreadRadius: 3,
      );
    } else {
      return getSubtleShadow();
    }
  }
}

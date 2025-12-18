import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_utils.dart';
import '../utils/style_utils.dart';
import '../services/audio_service.dart';

/// Reusable icon button with consistent styling
class IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color iconColor;
  final String? tooltip;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40.0,
    this.gradient,
    this.backgroundColor,
    this.iconColor = AppColors.textWhite,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = ResponsiveUtils.getResponsiveValue(
      context,
      smallMobile: size * 0.95,
      mobile: size,
      largeMobile: size * 1.1,
      tablet: size * 1.2,
      desktop: size * 1.3,
    );

    Widget button = SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ??
              const LinearGradient(
                colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
              ),
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: StyleUtils.getCardShadow(),
        ),
        child: ElevatedButton(
          onPressed: () {
            AudioService.instance.playClickSound();
            onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: buttonSize * 0.45,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Reusable game action button with icon and label
class GameActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isEnabled;
  final bool showWatchAd;
  final bool isActive;

  const GameActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isEnabled = true,
    this.showWatchAd = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !isEnabled;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.neutralDark : (isActive ? color : color),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.black,
                  size: ResponsiveUtils.getResponsiveValue(
                    context,
                    smallMobile: 18.0,
                    mobile: 20.0,
                    largeMobile: 22.0,
                    tablet: 24.0,
                    desktop: 26.0,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  showWatchAd && isEnabled ? 'Watch Ad' : '',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.black.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable gradient button with icon and text
class GradientActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final VoidCallback onPressed;
  final Gradient gradient;
  final bool isPrimary;
  final double? width;
  final double? height;

  const GradientActionButton({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    required this.onPressed,
    required this.gradient,
    this.isPrimary = false,
    this.width,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? AppColors.logoGradientEnd.withValues(alpha: 0.8)
                : AppColors.primaryGold.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: StyleUtils.getCardShadow(
            color: gradient.colors.first,
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              AudioService.instance.playClickSound();
              onPressed();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (emoji != null) ...[
                    Text(
                      emoji!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(
                      icon,
                      color: isPrimary ? Colors.black : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isPrimary ? Colors.black : Colors.white,
                        letterSpacing: 1.0,
                        shadows: isPrimary
                            ? [
                                const Shadow(
                                  color: Colors.white24,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ]
                            : [
                                const Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

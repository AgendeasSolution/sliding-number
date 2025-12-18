import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../services/audio_service.dart';

class GameButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;

  const GameButton({
    super.key,
    this.label,
    this.icon,
    required this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.textColor = AppColors.textWhite,
  }) : assert(label != null || icon != null, 'Either label or icon must be provided'),
       assert(gradient != null || backgroundColor != null, 'Either gradient or backgroundColor must be provided');

  @override
  Widget build(BuildContext context) {
    final Color shadowColor = gradient != null 
        ? gradient!.colors.first 
        : backgroundColor!;
    
    // Determine if this is a primary button (gold gradient) or secondary
    final bool isPrimary = gradient != null && 
        gradient!.colors.contains(AppColors.primaryGold);
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        border: Border.all(
          color: isPrimary
              ? AppColors.primaryGold.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.2),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AudioService.instance.playClickSound();
            onPressed();
          },
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: textColor,
                    size: 20,
                  ),
                  if (label != null) const SizedBox(width: 8),
                ],
                if (label != null)
                  Text(
                    label!,
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

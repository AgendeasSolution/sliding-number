import 'package:flutter/material.dart';
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
        
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          AudioService.instance.playClickSound();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
        child: icon != null
            ? Icon(
                icon,
                color: textColor,
                size: 20,
              )
            : Text(
                label!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

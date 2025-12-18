import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ModalHeader extends StatelessWidget {
  final String title;
  final Color color;

  const ModalHeader({
    super.key,
    required this.title,
    this.color = AppColors.primaryGold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryGold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.logoGradientStart,
              AppColors.logoGradientMid,
              AppColors.logoGradientEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 6,
                ),
                Shadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.5),
                  offset: const Offset(0, 0),
                  blurRadius: 15,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

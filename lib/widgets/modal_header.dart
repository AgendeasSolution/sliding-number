import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ModalHeader extends StatelessWidget {
  final String title;
  final Color color; // kept for backward compatibility (unused in style)
  final bool showCloseButton;
  final VoidCallback? onClose;

  const ModalHeader({
    super.key,
    required this.title,
    this.color = AppColors.primaryGold,
    this.showCloseButton = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.woodButtonBorderLight.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.woodTitleMain,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (showCloseButton)
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.woodButtonFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.woodButtonBorderDark,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.woodButtonText,
                ),
              ),
            )
          else
            const SizedBox(width: 4),
        ],
      ),
    );
  }
}

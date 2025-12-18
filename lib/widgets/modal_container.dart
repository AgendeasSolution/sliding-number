import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class ModalContainer extends StatelessWidget {
  final Widget child;

  const ModalContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Single dark-wood panel for all popups
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5B3C2D), // top - medium wood
            Color(0xFF3F2719), // bottom - darker wood
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.modalBorderRadius),
        border: Border.all(
          color: AppColors.woodButtonBorderLight,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

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
        borderRadius: BorderRadius.circular(AppConstants.modalBorderRadius),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
          width: 2.0,
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
      ),
      child: child,
    );
  }
}

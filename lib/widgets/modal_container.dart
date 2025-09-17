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
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.modalBorderRadius),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
        boxShadow: [
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

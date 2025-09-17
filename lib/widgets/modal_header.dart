import 'package:flutter/material.dart';
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
          bottom: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(
                blurRadius: 20.0,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

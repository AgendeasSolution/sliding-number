import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isWin;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.isWin = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWin ? AppColors.success : AppColors.primaryGold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

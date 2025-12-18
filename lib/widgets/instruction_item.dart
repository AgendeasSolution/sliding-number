import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InstructionItem extends StatelessWidget {
  final String icon;
  final String text;

  const InstructionItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textWhite,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

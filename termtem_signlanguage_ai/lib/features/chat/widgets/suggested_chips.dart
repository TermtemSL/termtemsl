import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SuggestedChips extends StatelessWidget {
  final Function(String) onChipTap;

  const SuggestedChips({super.key, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip("ฝึกคำว่า ขอบคุณ"),
          _buildChip("สอนคำทักทาย"),
          _buildChip("แปลประโยคนี้"),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return GestureDetector(
      onTap: () => onChipTap(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

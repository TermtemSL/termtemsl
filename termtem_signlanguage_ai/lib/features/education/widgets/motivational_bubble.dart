import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A mascot-flavoured motivational message shown at the bottom of the
/// Education screen when no search filter or category filter is active.
class MotivationalBubble extends StatelessWidget {
  const MotivationalBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "You're doing great! You've learned 5 new signs today. Keep that streak going!",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

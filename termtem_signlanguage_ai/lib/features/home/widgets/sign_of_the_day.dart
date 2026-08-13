import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';

/// Card displaying the featured sign of the day with an illustration area,
/// a badge label, and the sign name + translation.
class SignOfTheDay extends StatelessWidget {
  const SignOfTheDay({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration area
          Container(
            height: 170,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: const Icon(
              Icons.front_hand,
              size: 90,
              color: Color(0xFF00658D),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'SIGN OF THE DAY',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Khop Khun',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Thank You',
                  style: TextStyle(fontSize: 15, color: AppColors.textSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

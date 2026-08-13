import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';

/// Displays the user's current level, XP badge, learning-path steps, and
/// daily goal progress.
///
/// The [_PathStep] helper widget is kept inline because it is only used here.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR PROGRESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Level 4',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars, size: 18, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      '1,240 XP',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PathStep(
                icon: Icons.check,
                backgroundColor: AppColors.secondaryLight,
                iconColor: AppColors.secondary,
                size: 42,
              ),
              _PathStep(
                icon: Icons.school,
                backgroundColor: AppColors.primary,
                iconColor: Colors.white,
                size: 54,
              ),
              _PathStep(
                icon: Icons.lock_outline,
                backgroundColor: const Color(0xFFEEEFF0),
                iconColor: AppColors.textSoft,
                size: 42,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: const [
              Text(
                'Daily Goal: 85% reached',
                style: TextStyle(color: AppColors.textSoft, fontSize: 13),
              ),
              Spacer(),
              Text(
                '150 XP left',
                style: TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single circular icon node on the learning path.
/// Kept inside [ProgressCard] because it is not used anywhere else.
class _PathStep extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const _PathStep({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A small stat tile used in the "Quick Actions" row on the Translate screen.
///
/// Wraps an icon + title + subtitle inside a bordered card.
/// [QuickActionCard] is not wrapped in [Expanded]; callers should wrap it
/// themselves (e.g. `Expanded(child: QuickActionCard(...))`) when placing
/// multiple tiles in a [Row].
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tertiaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSoft, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

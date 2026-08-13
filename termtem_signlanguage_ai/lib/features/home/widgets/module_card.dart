import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';

/// A row card representing a recommended learning module.
class ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

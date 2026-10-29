import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Greeting headline shown at the top of the Home screen.
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sawatdee👋',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Ready to continue your sign journey?',
          style: TextStyle(fontSize: 15, color: AppColors.textSoft),
        ),
      ],
    );
  }
}

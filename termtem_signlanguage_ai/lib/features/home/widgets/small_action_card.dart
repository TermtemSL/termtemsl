import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A compact square card used for quick-action shortcuts on the Home screen
/// (e.g. "Practice Signs" and "Ask AI Mentor").
class SmallActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color backgroundColor;
  final Color iconColor;

  const SmallActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

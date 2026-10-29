import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';

/// Quick-access card that links to the Translate feature from the Home screen.
class TranslateQuickCard extends StatelessWidget {
  const TranslateQuickCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black,
            child: const Icon(
              Icons.video_library_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Translate Video',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Real-time sign recognition',
                  style: TextStyle(fontSize: 13, color: AppColors.textSoft),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textSoft),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tip bubble shown at the bottom of the Translate screen.
///
/// Displays a lightbulb icon and a styled "Tip from Nong Termtem" rich-text
/// message. Static / stateless — no data is passed in.
class HintBubble extends StatelessWidget {
  const HintBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: AppColors.textSoft, height: 1.4),
                children: [
                  TextSpan(
                    text: 'Tip from Nong Termtem: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: 'Make sure your hands are clearly visible and record in good lighting.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

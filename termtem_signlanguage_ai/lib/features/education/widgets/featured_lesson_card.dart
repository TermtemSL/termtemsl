import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/lesson.dart';

/// The highlighted card shown at the top of the Education screen
/// when no search filter or category filter is active.
///
/// Displays the lesson icon, title, description, and a row of
/// overlapping learner-avatar circles. Tap triggers [onTap].
class FeaturedLessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const FeaturedLessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: NEW LESSON badge + arrow
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW LESSON',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 16),
            // Icon + title/description row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(lesson.icon, size: 30, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSoft,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Learner avatar stack
            Row(
              children: [
                SizedBox(
                  width: 70,
                  height: 28,
                  child: Stack(
                    children: [
                      Positioned(left: 0,  child: _avatarCircle(AppColors.tertiaryLight)),
                      Positioned(left: 20, child: _avatarCircle(AppColors.secondaryLight)),
                      Positioned(left: 40, child: _avatarCircle(AppColors.primaryLight)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Learners joined today',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Small overlapping avatar circle used in the learner-count row.
  Widget _avatarCircle(Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.person, size: 16, color: Colors.black26),
    );
  }
}

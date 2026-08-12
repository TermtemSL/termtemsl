import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'lesson_card.dart';

/// A responsive grid of [LessonCard]s.
///
/// Renders as a single column on mobile (< 600 px wide) and two columns
/// on tablet / desktop, matching the original layout behaviour.
///
/// [lessons]      — the already-filtered list of lessons to display.
/// [onLessonTap]  — called with the tapped [Lesson] so the parent screen
///                  can open the practice modal.
class LessonGrid extends StatelessWidget {
  final List<Lesson> lessons;
  final ValueChanged<Lesson> onLessonTap;

  const LessonGrid({
    super.key,
    required this.lessons,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.2,
            mainAxisExtent: 140,
          ),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            return LessonCard(
              lesson: lessons[index],
              onTap: () => onLessonTap(lessons[index]),
            );
          },
        );
      },
    );
  }
}

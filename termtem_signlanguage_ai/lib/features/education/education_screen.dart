import 'package:flutter/material.dart';
import '../../../shared/widgets/termtem_header.dart';
import '../../../core/theme/app_colors.dart';
import 'models/lesson.dart';
import 'practice_modal.dart';
import 'widgets/lesson_search_bar.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/featured_lesson_card.dart';
import 'widgets/lesson_grid.dart';
import 'widgets/locked_lesson_card.dart';
import 'widgets/motivational_bubble.dart';

/// Education feature root screen.
///
/// Manages state for search query and selected category, then delegates
/// all rendering to the feature-specific widget files in `widgets/`.
///
/// Previously located at `lib/screens/education_screen.dart` (which now
/// re-exports from here for backwards compatibility).
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All Lessons';

  final List<String> _categories = [
    'All Lessons',
    'Basics',
    'Food',
    'Travel',
    'Emergency',
  ];

  final Lesson _featuredLesson = Lesson(
    title: 'Essential Greetings',
    description:
        'Learn the polite ways to say hello and thank you in Thai Sign Language.',
    category: 'Basics',
    level: 'Beginner',
    progress: 0.0,
    stepsDone: 0,
    totalSteps: 5,
    icon: Icons.waving_hand,
  );

  final List<Lesson> _allLessons = [
    Lesson(
      title: 'Family Members',
      description: 'Learn how to refer to family members.',
      category: 'Basics',
      level: 'Beginner',
      progress: 0.75,
      stepsDone: 3,
      totalSteps: 4,
      icon: Icons.family_restroom,
    ),
    Lesson(
      title: 'Ordering Food',
      description: 'Essential signs for ordering at a restaurant.',
      category: 'Food',
      level: 'Intermediate',
      progress: 0.2,
      stepsDone: 2,
      totalSteps: 10,
      icon: Icons.restaurant,
    ),
    Lesson(
      title: 'Directions',
      description: 'How to ask for and give directions.',
      category: 'Travel',
      level: 'Intermediate',
      progress: 0.0,
      stepsDone: 0,
      totalSteps: 8,
      icon: Icons.map,
    ),
    Lesson(
      title: 'Medical Help',
      description: 'Critical signs for emergencies.',
      category: 'Emergency',
      level: 'Critical',
      progress: 0.0,
      stepsDone: 0,
      totalSteps: 5,
      icon: Icons.local_hospital,
    ),
  ];

  final Lesson _lockedLesson = Lesson(
    title: 'Social Chat',
    description: 'Casual conversation signs.',
    category: 'Advanced',
    level: 'Advanced',
    progress: 0.0,
    stepsDone: 0,
    totalSteps: 10,
    isLocked: true,
    unlockText: 'Unlock at Level 5',
    icon: Icons.chat_bubble,
  );

  // Opens the practice modal, or shows a snack-bar if the lesson is locked.
  void _openPracticeModal(Lesson lesson) {
    if (lesson.isLocked) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('This lesson is locked!')));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => PracticeModal(
        word: lesson.title,
        category: lesson.category,
        isChallengeMode: false,
        onWordDone: () {
          // TODO: update lesson progress
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Lesson> filteredLessons = _allLessons.where((lesson) {
      final matchesSearch =
          lesson.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lesson.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All Lessons' ||
          lesson.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final bool showFeatured =
        _searchQuery.isEmpty && _selectedCategory == 'All Lessons';

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          const TermtemHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonSearchBar(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 20),
                  CategoryFilterChips(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) =>
                        setState(() => _selectedCategory = category),
                  ),
                  const SizedBox(height: 24),
                  if (showFeatured) ...[
                    FeaturedLessonCard(
                      lesson: _featuredLesson,
                      onTap: () => _openPracticeModal(_featuredLesson),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Lessons',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LessonGrid(
                    lessons: filteredLessons,
                    onLessonTap: _openPracticeModal,
                  ),
                  const SizedBox(height: 24),
                  if (showFeatured) ...[
                    LockedLessonCard(lesson: _lockedLesson),
                    const SizedBox(height: 32),
                    const MotivationalBubble(),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

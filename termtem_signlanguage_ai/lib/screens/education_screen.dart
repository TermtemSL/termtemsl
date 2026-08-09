import 'package:flutter/material.dart';
import '../widgets/termtem_header.dart';
import 'practice_modal.dart';

class Lesson {
  final String title;
  final String description;
  final String category;
  final String level;
  final double progress;
  final int stepsDone;
  final int totalSteps;
  final bool isLocked;
  final String? unlockText;
  final IconData icon;

  Lesson({
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.progress,
    required this.stepsDone,
    required this.totalSteps,
    this.isLocked = false,
    this.unlockText,
    required this.icon,
  });
}

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

  // Opens a lesson popup, unless that lesson is locked.
  void _openPracticeModal(Lesson lesson) {
    if (lesson.isLocked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This lesson is locked!')));
      return;
    }

    showDialog(
      // Displays a popup above the current screen
      context: context,
      builder: (context) => PracticeModal(
        word: lesson.title,
        category: lesson.category,
        isChallengeMode: false,
        onWordDone: () {
          // Add logic to update progress
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter lessons
    final List<Lesson> filteredLessons = _allLessons.where((lesson) {
      final matchesSearch =
          lesson.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lesson.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All Lessons' ||
          lesson.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Container(
      color: const Color(0xFFF9F9FC), // Background
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
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildCategoryChips(),
                  const SizedBox(height: 24),
                  if (_searchQuery.isEmpty &&
                      _selectedCategory == 'All Lessons') ...[
                    _buildFeaturedLesson(),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Lessons',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLessonGrid(filteredLessons),
                  const SizedBox(height: 24),
                  if (_searchQuery.isEmpty &&
                      _selectedCategory == 'All Lessons') ...[
                    _buildLockedLesson(),
                    const SizedBox(height: 32),
                    _buildMotivationalBubble(),
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search lessons...',
        hintStyle: const TextStyle(color: Color(0xFF564338)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF9B4500)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xFF9B4500), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              selectedColor: const Color(0xFF9B4500),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF564338),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF9B4500)
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedLesson() {
    return GestureDetector(
      onTap: () => _openPracticeModal(_featuredLesson),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B4500).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDBC9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW LESSON',
                    style: TextStyle(
                      color: Color(0xFF9B4500),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFF9B4500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _featuredLesson.icon,
                    size: 30,
                    color: const Color(0xFF9B4500),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _featuredLesson.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _featuredLesson.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF564338),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 70,
                  height: 28,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: _buildAvatarCircle(const Color(0xFFC6E7FF)),
                      ),
                      Positioned(
                        left: 20,
                        child: _buildAvatarCircle(const Color(0xFF8AF5B3)),
                      ),
                      Positioned(
                        left: 40,
                        child: _buildAvatarCircle(const Color(0xFFFFDBC9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Learners joined today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF564338),
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

  Widget _buildAvatarCircle(Color color) {
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

  Widget _buildLessonGrid(List<Lesson> lessons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.2,
            mainAxisExtent: 140, // Fixed height for cards
          ),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            return _buildLessonCard(lessons[index]);
          },
        );
      },
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    return GestureDetector(
      onTap: () => _openPracticeModal(lesson),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                lesson.icon,
                size: 24,
                color: const Color(0xFF006D3F),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC6E7FF).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lesson.level.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006D3F),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF564338),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: lesson.progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF9F9FC),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF006D3F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${lesson.stepsDone}/${lesson.totalSteps} steps',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF564338),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedLesson() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock, size: 24, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lockedLesson.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _lockedLesson.unlockText ?? 'Locked',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalBubble() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B4500).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDBC9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Color(0xFF9B4500), size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "You're doing great! You've learned 5 new signs today. Keep that streak going!",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1C1E),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

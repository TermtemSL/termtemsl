import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A styled search field for filtering lessons by title or description.
///
/// The parent [EducationScreen] owns the query string in its state;
/// this widget fires [onChanged] on every keystroke so the parent can rebuild.
class LessonSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const LessonSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search lessons...',
        hintStyle: const TextStyle(color: AppColors.textSoft),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

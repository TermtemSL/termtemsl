import 'package:flutter/material.dart';

/// Data model for a single lesson unit in the Education feature.
///
/// Previously embedded inside `lib/screens/education_screen.dart`.
/// Extracted here so it can be shared between [EducationScreen] and
/// [PracticeModal] without circular imports.
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

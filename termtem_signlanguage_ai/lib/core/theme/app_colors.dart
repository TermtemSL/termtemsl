import 'package:flutter/material.dart';

/// Canonical colour palette for the TermtemSL app.
///
/// All features should import from here instead of defining their own
/// colour constants. This replaces:
///   - `HomeScreen` static `const Color` fields
///   - `ChatColors` in `features/chat/theme/`
///   - Inline hex literals in `TranslateScreen`
///   - `TermtemHeader` static `const Color` fields
class AppColors {
  // Brand
  static const Color primary      = Color(0xFF9B4500); // terracotta brand
  static const Color primaryLight = Color(0xFFFFDBC9); // warm peach tint

  // Accent
  static const Color secondary      = Color(0xFF006D3F); // forest green
  static const Color secondaryLight = Color(0xFF8AF5B3); // mint
  static const Color tertiaryLight  = Color(0xFFC6E7FF); // sky blue

  // Background / Surface
  static const Color background     = Color(0xFFF9F9FC); // off-white canvas
  static const Color surface        = Colors.white;
  static const Color surfaceVariant = Color(0xFFE2E2E5); // subtle divider

  // Text
  static const Color textDark = Color(0xFF1A1C1E); // near-black
  static const Color textSoft = Color(0xFF564338); // warm muted brown
}

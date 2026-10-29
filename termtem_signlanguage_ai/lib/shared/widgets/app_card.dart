import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A standard white card with rounded corners and a primary-tinted shadow.
///
/// Use this as a drop-in container for any feature card so that the shared
/// card style stays consistent across Home, Translate, and Education screens.
///
/// Example:
/// ```dart
/// AppCard(
///   padding: const EdgeInsets.all(24),
///   child: Text('Card content'),
/// )
/// ```
class AppCard extends StatelessWidget {
  final Widget child;

  /// Corner radius. Defaults to 32 to match the original card style.
  final double radius;

  /// Optional inner padding. When omitted the caller handles its own padding.
  final EdgeInsetsGeometry? padding;

  const AppCard({
    super.key,
    required this.child,
    this.radius = 32,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x149B4500), // primary at ~8 % opacity
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

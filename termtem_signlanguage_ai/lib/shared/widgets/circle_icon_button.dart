import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A compact circular icon button with press-state animation.
///
/// Supports both a filled (primary action) and an outline-less transparent
/// (secondary action) appearance. An optional [tooltip] is shown on long hover.
///
/// Previously located at `features/chat/widgets/circle_icon_button.dart`.
/// Moved to shared so other features can reuse it.
class CircleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// When true the button renders with a filled [AppColors.primary] background.
  final bool filled;
  final String? tooltip;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.onLongPress,
    this.filled = false,
    this.tooltip,
  });

  @override
  State<CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<CircleIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: widget.filled
              ? AppColors.primary
              : _pressed
                  ? AppColors.primaryLight
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: widget.filled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Icon(
          widget.icon,
          size: 22,
          color: widget.filled ? Colors.white : AppColors.textSoft,
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

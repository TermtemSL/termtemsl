import 'package:flutter/material.dart';
import '../theme/chat_colors.dart';

class CircleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
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
              ? ChatColors.primary
              : _pressed
                  ? ChatColors.primaryLight
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: widget.filled
              ? [
                  BoxShadow(
                    color: ChatColors.primary.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Icon(
          widget.icon,
          size: 22,
          color: widget.filled ? Colors.white : ChatColors.textSoft,
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

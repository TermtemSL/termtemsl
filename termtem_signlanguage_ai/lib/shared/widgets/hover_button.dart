import 'package:flutter/material.dart';

/// A button with smooth hover and press-state animations.
///
/// [filled] = `true`  → dark/black background (primary action).
/// [filled] = `false` → light grey background (secondary action).
///
/// Previously the private class `_HoverButton` inside `practice_modal.dart`.
/// Promoted to a public shared widget so it can be reused anywhere.
class HoverButton extends StatefulWidget {
  final String label;

  /// `true` = dark filled background; `false` = light background.
  final bool filled;

  /// When `true` the button stretches to fill its parent's width.
  final bool fullWidth;

  final VoidCallback onTap;

  const HoverButton({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;

    final Color bg = widget.filled
        ? (active ? Colors.grey[800]! : Colors.black)
        : (active ? Colors.grey[200]! : const Color(0xFFF5F5F5));

    final Color textColor = widget.filled
        ? Colors.white
        : (active ? Colors.black : Colors.black87);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// A circular close (X) button with hover and press-state animations.
///
/// Previously the private class `_HoverCloseButton` inside `practice_modal.dart`.
/// Promoted to a public shared widget so it can be reused in any modal or page.
class HoverCloseButton extends StatefulWidget {
  final VoidCallback onTap;

  const HoverCloseButton({super.key, required this.onTap});

  @override
  State<HoverCloseButton> createState() => _HoverCloseButtonState();
}

class _HoverCloseButtonState extends State<HoverCloseButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active ? Colors.grey[300]! : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            size: 18,
            color: active ? Colors.black : Colors.black54,
          ),
        ),
      ),
    );
  }
}

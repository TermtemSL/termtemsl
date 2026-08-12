import 'package:flutter/material.dart';

/// A circular avatar button with hover and press-state animations.
///
/// Shows an initial letter (when the user is logged in) or a person icon
/// (when logged out). Designed for the top-right corner of the app shell.
///
/// Previously the private class `_HoverAvatar` inside `main_screen.dart`.
/// Promoted to a public shared widget so it can be referenced from the
/// header or any other shell-level widget in the future.
class HoverAvatar extends StatefulWidget {
  final bool isLoggedIn;
  final String? initial;
  final VoidCallback onTap;

  const HoverAvatar({
    super.key,
    required this.isLoggedIn,
    required this.onTap,
    this.initial,
  });

  @override
  State<HoverAvatar> createState() => _HoverAvatarState();
}

class _HoverAvatarState extends State<HoverAvatar> {
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: widget.isLoggedIn
                ? (active ? Colors.grey[800]! : Colors.black)
                : (active ? Colors.grey[300]! : Colors.grey[200]!),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: widget.isLoggedIn && widget.initial != null
                ? Text(
                    widget.initial!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: active ? Colors.black : Colors.black54,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}

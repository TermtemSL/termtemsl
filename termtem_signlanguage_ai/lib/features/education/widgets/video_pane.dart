import 'package:flutter/material.dart';

/// A video preview pane used inside [PracticeModal].
///
/// Renders either a camera feed placeholder ([isCamera] = true) or a
/// reference sign-language video placeholder, with a coloured label badge
/// and a subtitle strip at the bottom.
///
/// Previously the private class `_VideoPane` inside
/// `lib/screens/practice_modal.dart`. Promoted to a named widget in the
/// education feature so it can be reused independently.
class VideoPane extends StatelessWidget {
  final String label;
  final Color labelColor;
  final IconData icon;
  final Color bgColor;
  final String sublabel;

  /// When true an additional "(camera permission needed)" hint is shown.
  final bool isCamera;

  const VideoPane({
    super.key,
    required this.label,
    required this.labelColor,
    required this.icon,
    required this.bgColor,
    required this.sublabel,
    required this.isCamera,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            color: bgColor,
            child: Center(child: Icon(icon, size: 52, color: Colors.white24)),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: labelColor, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(sublabel,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ),
            ),
          ),
          if (isCamera)
            const Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(
                child: Text('(camera permission needed)',
                    style:
                        TextStyle(color: Colors.white30, fontSize: 10)),
              ),
            ),
        ],
      ),
    );
  }
}

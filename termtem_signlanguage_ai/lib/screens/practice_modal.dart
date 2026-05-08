import 'package:flutter/material.dart';

class PracticeModal extends StatefulWidget {
  final String word;
  final String category;
  final bool isChallengeMode;
  final int challengeProgress;
  final VoidCallback? onWordDone;

  const PracticeModal({
    super.key,
    required this.word,
    required this.category,
    this.isChallengeMode = false,
    this.challengeProgress = 0,
    this.onWordDone,
  });

  @override
  State<PracticeModal> createState() => _PracticeModalState();
}

class _PracticeModalState extends State<PracticeModal> {
  String _stage = 'ask';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: _stage == 'ask' ? _buildAskStage() : _buildPracticeStage(),
      ),
    );
  }

  // ── Stage 1: Ask ───────────────────────────────────────────────────────────
  Widget _buildAskStage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topLeft,
            child: _HoverCloseButton(onTap: () => Navigator.of(context).pop()),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5), shape: BoxShape.circle),
            child: const Icon(Icons.sign_language, size: 40, color: Colors.black),
          ),
          const SizedBox(height: 20),

          Text(
            widget.category,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),

          Text(
            widget.word,
            style: const TextStyle(
                fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -2),
          ),
          const SizedBox(height: 12),

          Text(
            widget.isChallengeMode
                ? 'Ready to practice this word for your daily challenge?'
                : 'Would you like to try this sign?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 32),

          // Buttons row
          Row(
            children: [
              Expanded(
                child: _HoverButton(
                  label: 'Maybe later',
                  filled: false,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HoverButton(
                  label: "Let's go! 🤙",
                  filled: true,
                  onTap: () => setState(() => _stage = 'practice'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stage 2: Practice ──────────────────────────────────────────────────────
  Widget _buildPracticeStage() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              _HoverCloseButton(onTap: () => Navigator.of(context).pop()),
              const SizedBox(width: 12),
              Text(
                widget.word,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  widget.category,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Camera + Video panes
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _VideoPane(
                    label: 'YOU',
                    labelColor: Colors.blue,
                    icon: Icons.videocam,
                    bgColor: const Color(0xFF1A1A2E),
                    sublabel: 'Camera active',
                    isCamera: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VideoPane(
                    label: 'REFERENCE',
                    labelColor: Colors.green,
                    icon: Icons.sign_language,
                    bgColor: const Color(0xFF0D0D0D),
                    sublabel: 'Tap to replay',
                    isCamera: false,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bottom bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              // Challenge progress bar
              if (widget.isChallengeMode) ...[
                Row(
                  children: [
                    Text(
                      'Daily Challenge  ${widget.challengeProgress}/5',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      '${((widget.challengeProgress / 5) * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: widget.challengeProgress / 5,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Mark as done / Done practicing button
              _HoverButton(
                label: widget.isChallengeMode
                    ? '✅  Mark as done'
                    : '✅  Done practicing',
                filled: true,
                fullWidth: true,
                onTap: () {
                  widget.onWordDone?.call();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Video pane ─────────────────────────────────────────────────────────────────
class _VideoPane extends StatelessWidget {
  final String label;
  final Color labelColor;
  final IconData icon;
  final Color bgColor;
  final String sublabel;
  final bool isCamera;

  const _VideoPane({
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
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: const Center(
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

// ── Reusable hover button ──────────────────────────────────────────────────────
class _HoverButton extends StatefulWidget {
  final String label;
  final bool filled;       // true = black bg, false = light bg
  final bool fullWidth;
  final VoidCallback onTap;

  const _HoverButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
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
                  fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hover close button (X) ─────────────────────────────────────────────────────
class _HoverCloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HoverCloseButton({required this.onTap});

  @override
  State<_HoverCloseButton> createState() => _HoverCloseButtonState();
}

class _HoverCloseButtonState extends State<_HoverCloseButton> {
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
import 'package:flutter/material.dart';
import '../../shared/widgets/hover_button.dart';
import 'widgets/video_pane.dart';

/// A full-screen dialog for practising a single sign-language word.
///
/// Shows two stages:
///   1. **Ask** — prompts the learner to try the sign.
///   2. **Practice** — displays a camera pane (user) + reference pane side
///      by side, with a "Done" button.
///
/// Previously located at `lib/screens/practice_modal.dart` (which now
/// re-exports from here for backwards compatibility).
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
              color: Colors.black.withValues(alpha: 0.15),
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
            child: HoverCloseButton(onTap: () => Navigator.of(context).pop()),
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
                child: HoverButton(
                  label: 'Maybe later',
                  filled: false,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HoverButton(
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
              HoverCloseButton(onTap: () => Navigator.of(context).pop()),
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

        // Camera + Reference panes
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: VideoPane(
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
                  child: VideoPane(
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

              // Done button
              HoverButton(
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

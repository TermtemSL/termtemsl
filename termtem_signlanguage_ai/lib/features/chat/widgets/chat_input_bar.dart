import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/circle_icon_button.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(BuildContext) onShowAttachMenu;
  final Function(BuildContext) onShowModeMenu;
  final String responseMode;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onShowAttachMenu,
    required this.onShowModeMenu,
    required this.responseMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(top: BorderSide(color: AppColors.surfaceVariant)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
            builder: (btnCtx) => CircleIconButton(
              icon: Icons.add_circle_outline,
              onTap: () => onShowAttachMenu(btnCtx),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F6),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Ask Nong Termtem...",
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (btnCtx) => CircleIconButton(
              icon: responseMode == 'speech'
                  ? Icons.record_voice_over
                  : responseMode == 'animation'
                      ? Icons.play_circle_outline
                      : Icons.send,
              filled: true,
              onTap: onSend,
              onLongPress: () => onShowModeMenu(btnCtx),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../../../core/theme/app_colors.dart';

class ChatSessionTile extends StatefulWidget {
  final ChatSession session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ChatSessionTile({
    super.key,
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<ChatSessionTile> createState() => _ChatSessionTileState();
}

class _ChatSessionTileState extends State<ChatSessionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    final active = _hovered || selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondaryLight
                : active
                    ? AppColors.primaryLight.withValues(alpha: 0.6)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: selected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: selected ? Colors.white : AppColors.primaryLight,
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: selected ? AppColors.primary : AppColors.textSoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: selected ? AppColors.primary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.session.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSoft),
                    ),
                  ],
                ),
              ),
              if (_hovered || selected)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: selected ? AppColors.primary : AppColors.textSoft,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

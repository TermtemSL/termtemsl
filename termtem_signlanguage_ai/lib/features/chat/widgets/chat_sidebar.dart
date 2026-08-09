import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../theme/chat_colors.dart';
import 'chat_session_tile.dart';
import 'circle_icon_button.dart';
import '../data/mock_chat_data.dart';

class ChatSidebar extends StatefulWidget {
  final String selectedId;
  final ValueChanged<String> onSelectChat;
  final VoidCallback onNewChat;
  final VoidCallback onClose;

  const ChatSidebar({
    super.key,
    required this.selectedId,
    required this.onSelectChat,
    required this.onNewChat,
    required this.onClose,
  });

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  String _searchQuery = '';

  List<ChatSession> get _filtered {
    return MockChatData.sessions
        .where(
          (session) =>
              session.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              session.preview.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  Map<String, List<ChatSession>> get _grouped {
    final map = <String, List<ChatSession>>{};
    for (final session in _filtered) {
      map.putIfAbsent(session.timeLabel, () => []).add(session);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final timeOrder = ['Today', 'Yesterday', 'Mon', 'Sun', 'Sat'];

    return Container(
      width: 290,
      color: ChatColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final timeLabel in timeOrder)
                    if (grouped.containsKey(timeLabel)) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                        child: Text(
                          timeLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: ChatColors.textSoft,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      for (final session in grouped[timeLabel]!)
                        ChatSessionTile(
                          session: session,
                          isSelected: session.id == widget.selectedId,
                          onTap: () => widget.onSelectChat(session.id),
                          onDelete: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${session.title}"'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: ChatColors.primaryLight,
            child: Icon(Icons.pets, color: ChatColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'Chats',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: ChatColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          CircleIconButton(
            icon: Icons.edit_outlined,
            tooltip: 'New chat',
            onTap: widget.onNewChat,
          ),
          const SizedBox(width: 4),
          CircleIconButton(
            icon: Icons.chevron_left,
            tooltip: 'Close sidebar',
            onTap: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ChatColors.surfaceVariant),
          boxShadow: [
            BoxShadow(
              color: ChatColors.primary.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: ChatColors.textSoft),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(color: ChatColors.textSoft, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

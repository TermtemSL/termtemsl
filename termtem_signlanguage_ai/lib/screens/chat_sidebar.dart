import 'package:flutter/material.dart';

class ChatSession {
  final String id;
  final String title;
  final String preview;
  final String time;

  const ChatSession({
    required this.id,
    required this.title,
    required this.preview,
    required this.time,
  });
}

// Mock data
final List<ChatSession> mockSessions = [
  ChatSession(id: '1', title: 'Imply vs Infer', preview: 'Think of it as a directional flow...', time: 'Today'),
  ChatSession(id: '2', title: 'ASL Basics', preview: 'The handshape for the letter A...', time: 'Today'),
  ChatSession(id: '3', title: 'Passive Voice', preview: 'Passive voice is used when...', time: 'Yesterday'),
  ChatSession(id: '4', title: 'Formal Writing Tips', preview: 'Avoid contractions in academic...', time: 'Yesterday'),
  ChatSession(id: '5', title: 'Subjunctive Mood', preview: 'If I were you, I would...', time: 'Mon'),
  ChatSession(id: '6', title: 'Oxford Comma', preview: 'The serial comma is used after...', time: 'Sun'),
  ChatSession(id: '7', title: 'Dangling Modifiers', preview: 'Walking down the street, the trees...', time: 'Sat'),
];

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

  List<ChatSession> get _filtered => mockSessions
      .where((s) =>
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.preview.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  // Group by time label
  Map<String, List<ChatSession>> get _grouped {
    final map = <String, List<ChatSession>>{};
    for (final s in _filtered) {
      map.putIfAbsent(s.time, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final timeOrder = ['Today', 'Yesterday', 'Mon', 'Sun', 'Sat'];

    return Container(
      width: 280,
      color: const Color(0xFFF9F9F9),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              child: Row(
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // New chat button
                  _SidebarIconBtn(
                    icon: Icons.edit_outlined,
                    tooltip: 'New chat',
                    onTap: widget.onNewChat,
                  ),
                  const SizedBox(width: 4),
                  // Close sidebar
                  _SidebarIconBtn(
                    icon: Icons.chevron_left,
                    tooltip: 'Close sidebar',
                    onTap: widget.onClose,
                  ),
                ],
              ),
            ),

            // ── Search ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Search chats...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Session list ────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final timeLabel in timeOrder)
                    if (grouped.containsKey(timeLabel)) ...[
                      // Group header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Sessions in group
                      for (final session in grouped[timeLabel]!)
                        _SessionTile(
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
}

// ── Single session tile ──────────────────────────────────────────────────────
class _SessionTile extends StatefulWidget {
  final ChatSession session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<_SessionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.black
                : _hovered
                    ? Colors.grey.shade200
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
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
                        fontWeight: FontWeight.w600,
                        color: widget.isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.session.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isSelected ? Colors.white60 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button (show on hover or selected)
              if (_hovered || widget.isSelected)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.delete_outline,
                      size: 15,
                      color: widget.isSelected ? Colors.white54 : Colors.grey,
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

// ── Small icon button for sidebar top bar ────────────────────────────────────
class _SidebarIconBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SidebarIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_SidebarIconBtn> createState() => _SidebarIconBtnState();
}

class _SidebarIconBtnState extends State<_SidebarIconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hovered ? Colors.grey.shade200 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
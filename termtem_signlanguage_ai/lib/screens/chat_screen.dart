import 'package:flutter/material.dart';
import 'chat_sidebar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _responseMode = 'text';
  bool _sidebarOpen = true;           // ← sidebar state
  String _selectedChatId = '1';       // ← active chat

  late final AnimationController _sidebarAnim;
  late final Animation<double> _sidebarSlide;

  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello! I am your sophisticated learning companion. How can I assist you today?", "isUser": false, "type": "text"},
    {"text": "Can you explain the difference between 'imply' and 'infer' in a formal academic context?", "isUser": true, "type": "text"},
    {"text": "Think of it as a directional flow of information. TO IMPLY: The speaker hints at something without saying it directly. TO INFER: The listener deduces a conclusion from the hints provided.", "isUser": false, "type": "explanation"},
  ];

  @override
  void initState() {
    super.initState();
    _sidebarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0, // start open
    );
    _sidebarSlide = CurvedAnimation(parent: _sidebarAnim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _sidebarAnim.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _sidebarOpen = !_sidebarOpen);
    if (_sidebarOpen) {
      _sidebarAnim.forward();
    } else {
      _sidebarAnim.reverse();
    }
  }

  void _onNewChat() {
    setState(() {
      _selectedChatId = DateTime.now().millisecondsSinceEpoch.toString();
      _messages.clear();
      _messages.add({
        "text": "Hello! I am your sophisticated learning companion. How can I assist you today?",
        "isUser": false,
        "type": "text",
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final userText = _controller.text.trim();
    setState(() {
      _messages.add({"text": userText, "isUser": true, "type": "text"});
    });
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        if (_responseMode == 'text') {
          _messages.add({
            "text": "Here's my response to \"$userText\" — This is a text-based reply from your mentor. Great question! Keep exploring.",
            "isUser": false,
            "type": "text",
          });
        } else if (_responseMode == 'speech') {
          _messages.add({
            "text": "🎧 Audio response ready for: \"$userText\"",
            "isUser": false,
            "type": "speech",
            "audioLabel": "Tap to play voice response",
          });
        } else if (_responseMode == 'animation') {
          _messages.add({
            "text": "🎬 Animation response for: \"$userText\"",
            "isUser": false,
            "type": "animation",
            "videoLabel": "Sign Language Animation",
          });
        }
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          if (_scrollController.hasClients &&
              _scrollController.position.hasContentDimensions) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        } catch (_) {}
      });
    });
  }

  // ── menus (unchanged) ───────────────────────────────────────────────────────
  void _showAttachMenu(BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox;
    final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(box.localToGlobal(Offset.zero, ancestor: overlay),
          box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay)),
      Offset.zero & overlay.size,
    );
    showMenu(
      context: ctx,
      position: pos,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attach video from device tapped'))),
          child: Row(children: const [Icon(Icons.video_library_outlined, size: 20), SizedBox(width: 12), Text('Attach video from device')]),
        ),
        PopupMenuItem(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open camera tapped'))),
          child: Row(children: const [Icon(Icons.camera_alt_outlined, size: 20), SizedBox(width: 12), Text('Open camera')]),
        ),
      ],
    );
  }

  void _showSendMenu(BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox;
    final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(box.localToGlobal(Offset.zero, ancestor: overlay),
          box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay)),
      Offset.zero & overlay.size,
    );
    showMenu(
      context: ctx,
      position: pos,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        _buildModeItem(ctx, 'text', Icons.text_fields, 'Text'),
        _buildModeItem(ctx, 'speech', Icons.record_voice_over, 'Speech'),
        _buildModeItem(ctx, 'animation', Icons.play_circle_outline, 'Animation'),
      ],
    );
  }

  PopupMenuItem _buildModeItem(BuildContext ctx, String mode, IconData icon, String label) {
    final selected = _responseMode == mode;
    return PopupMenuItem(
      onTap: () => setState(() => _responseMode = mode),
      child: Row(children: [
        Icon(icon, size: 20, color: selected ? Colors.black : Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        const Spacer(),
        if (selected) const Icon(Icons.check, size: 16),
      ]),
    );
  }

  // ── bubble (unchanged) ──────────────────────────────────────────────────────
  Widget _buildMessageBubble(Map<String, dynamic> msg, BuildContext context) {
    final isUser = msg["isUser"] as bool;
    final type = msg["type"] as String;
    Widget content;

    if (type == 'speech') {
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(msg["text"], style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playing audio...'))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.play_arrow, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(msg["audioLabel"] ?? "Play", style: const TextStyle(color: Colors.white, fontSize: 13)),
            ]),
          ),
        ),
      ]);
    } else if (type == 'animation') {
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(msg["text"], style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            Container(width: double.infinity, height: 140, color: Colors.black,
                child: const Center(child: Icon(Icons.sign_language, color: Colors.white54, size: 56))),
            Positioned(bottom: 8, left: 0, right: 0,
              child: Center(child: GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playing animation...'))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.play_circle_fill, size: 18), SizedBox(width: 6),
                    Text('Play Animation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                ),
              )),
            ),
            Positioned(top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: const Text('ASL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ]);
    } else {
      content = Text(msg["text"],
          style: TextStyle(color: isUser ? Colors.white : Colors.black, fontSize: 16, height: 1.5));
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.black : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(30),
            topRight: const Radius.circular(30),
            bottomLeft: Radius.circular(isUser ? 30 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 30),
          ),
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Animated Sidebar ─────────────────────────────────────────────────
        SizeTransition(
          sizeFactor: _sidebarSlide,
          axis: Axis.horizontal,
          child: ChatSidebar(
            selectedId: _selectedChatId,
            onSelectChat: (id) => setState(() => _selectedChatId = id),
            onNewChat: _onNewChat,
            onClose: _toggleSidebar,
          ),
        ),

        // ── Divider ───────────────────────────────────────────────────────────
        if (_sidebarOpen)
          VerticalDivider(width: 1, color: Colors.grey.shade200),

        // ── Main chat area ───────────────────────────────────────────────────
        Expanded(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with sidebar toggle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Nong Termtem',
                                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -2)),
                            Text('Your Silent Mentor for linguistics and logic.',
                                style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                      // Toggle button (shown when sidebar is closed)
                      if (!_sidebarOpen)
                        _HoverIconButton(
                          icon: Icons.menu,
                          onTap: _toggleSidebar,
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: _messages.length,
                      itemBuilder: (ctx, i) => _buildMessageBubble(_messages[i], ctx),
                    ),
                  ),

                  // Input bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Builder(builder: (btnCtx) => _HoverIconButton(icon: Icons.attach_file, onTap: () {}, onLongPress: () => _showAttachMenu(btnCtx))),
                        _HoverIconButton(icon: Icons.mic_none, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone tapped')))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Ask Nong Termtem anything...",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (btnCtx) => _HoverIconButton(
                            icon: _responseMode == 'speech' ? Icons.record_voice_over : _responseMode == 'animation' ? Icons.play_circle_outline : Icons.send,
                            filled: true,
                            onTap: _sendMessage,
                            onLongPress: () => _showSendMenu(btnCtx),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable hoverable icon button ────────────────────────────────────────────
class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool filled;

  const _HoverIconButton({required this.icon, required this.onTap, this.onLongPress, this.filled = false});

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.filled ? (active ? Colors.grey[800] : Colors.black) : (active ? Colors.grey[200] : Colors.transparent),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, size: 20, color: widget.filled ? Colors.white : (active ? Colors.black : Colors.grey)),
        ),
      ),
    );
  }
}
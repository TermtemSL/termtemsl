import 'package:flutter/material.dart';

import 'data/mock_chat_data.dart';
import 'models/chat_message.dart'; // Imports the ChatMessage data model
import 'theme/chat_colors.dart'; // Imports colours used by the chat page
import 'widgets/chat_input_bar.dart'; // Imports the message input widget
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_sidebar.dart'; // Import chat history sidebar widget
import 'widgets/suggested_chips.dart';
import '../../shared/widgets/termtem_header.dart';

class ChatScreen extends StatefulWidget {
  // StatefulWidget for the main chat screen, managing chat messages, sidebar, and input bar data can change
  const ChatScreen({super.key});

  @override // replace stateful wdget createstate method
  State<ChatScreen> createState() => _ChatScreenState(); // create this screen state object
}

// stores the changing data for the chat screen, including messages, sidebar state, and input bar text
class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller =
      TextEditingController(); //control input text
  final ScrollController _scrollController = ScrollController();

  String _responseMode = 'text'; //current AI response type: text
  bool _sidebarOpen = false; //remembers whether the sidebar is open or closed
  String _selectedChatId =
      '1'; // remembers the currently selected chat session ID

  late final AnimationController
  _sidebarAnim; //control sidebar animation progress
  late final Animation<double>
  _sidebarSlide; // Applies a smooth curve to the animation

  final List<ChatMessage> _messages = List.from(MockChatData.initialMessages);

  @override
  void initState() {
    super.initState(); //Runs the parent class setup first

    _sidebarAnim = AnimationController(
      vsync: this, //pause animation
      duration: const Duration(milliseconds: 250),
      value: 0.0, // sidebar starts closed
    );

    _sidebarSlide = CurvedAnimation(
      // makes the movement smoother
      parent: _sidebarAnim, // use progress from the animation controller
      curve: Curves.easeInOut, // starts and ends the movement
    );
  }

  @override
  void dispose() {
    _sidebarAnim.dispose(); // Releases animation resources
    _controller.dispose(); // Releases text-controller resources
    _scrollController.dispose(); // Releases scroll-controller resources
    super.dispose(); // Runs the parent cleanup last
  }

  // Opens the sidebar if closed, or closes it if open.
  void _toggleSidebar() {
    setState(() => _sidebarOpen = !_sidebarOpen);

    if (_sidebarOpen) {
      _sidebarAnim.forward(); // Plays the opening animation
    } else {
      _sidebarAnim.reverse(); // Plays the closing animation
    }
  }

  void _onNewChat() {
    setState(() {
      _selectedChatId = DateTime.now().millisecondsSinceEpoch.toString();
      _messages.clear();
      _messages.add(
        // Adds the AI's welcome message
        ChatMessage(
          // Creates one message object
          id: DateTime.now().toString(),
          text: "สวัสดีครับ ผม Nong Termtem วันนี้อยากฝึกคำไหนครับ?",
          isUser: false, // Marks this as an AI message
          type: "text",
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void _sendMessage() {
    // Sends the user's message and creates a mock AI response.
    if (_controller.text.trim().isEmpty) return; // Stops if the input is empty

    final userText = _controller.text.trim();

    setState(() {
      // Updates the message list and rebuilds the UI
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          text: userText,
          isUser: true, // Marks it as a user message
          type: "text",
          createdAt: DateTime.now(),
        ),
      );
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      setState(() {
        if (_responseMode == 'text') {
          _messages.add(
            ChatMessage(
              id: DateTime.now().toString(),
              text:
                  "คำถามที่ดีครับ! เดี๋ยวผมจะอธิบาย \"$userText\" ให้เข้าใจง่ายๆ นะครับ",
              isUser: false,
              type: "text",
              createdAt: DateTime.now(),
            ),
          );
        } else if (_responseMode == 'speech') {
          _messages.add(
            ChatMessage(
              id: DateTime.now().toString(),
              text: "เสียงอธิบายสำหรับ: \"$userText\"",
              isUser: false,
              type: "speech",
              audioLabel: "แตะเพื่อฟังเสียง",
              createdAt: DateTime.now(),
            ),
          );
        } else if (_responseMode == 'animation') {
          _messages.add(
            ChatMessage(
              id: DateTime.now().toString(),
              text: "วิดีโอแอนิเมชันสำหรับ: \"$userText\"",
              isUser: false,
              type: "animation",
              videoLabel: "แอนิเมชันภาษามือ",
              createdAt: DateTime.now(),
            ),
          );
        }
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      // Waits for the new bubble to be drawn
      if (_scrollController.hasClients) {
        // Checks that a ListView is attached
        _scrollController.animateTo(
          // Animates the scroll position
          _scrollController
              .position
              .maxScrollExtent, // Targets the bottom of the list
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut, // Makes scrolling slow gently at the end
        );
      }
    });
  }

  void _showAttachMenu(BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox;
    final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;

    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: ctx,
      position: pos,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      items: [
        PopupMenuItem(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attach video from device tapped')),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.video_library_outlined, size: 20),
              SizedBox(width: 12),
              Text('แนบวิดีโอจากเครื่อง'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Open camera tapped')));
          },
          child: const Row(
            children: [
              Icon(Icons.camera_alt_outlined, size: 20),
              SizedBox(width: 12),
              Text('เปิดกล้อง'),
            ],
          ),
        ),
      ],
    );
  }

  void _showSendMenu(BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox;
    final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;

    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: ctx,
      position: pos,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      items: [
        _buildModeItem('text', Icons.text_fields, 'ข้อความ'),
        _buildModeItem('speech', Icons.record_voice_over, 'เสียง'),
        _buildModeItem('animation', Icons.play_circle_outline, 'แอนิเมชัน'),
      ],
    );
  }

  PopupMenuItem _buildModeItem(String mode, IconData icon, String label) {
    final selected = _responseMode == mode;

    return PopupMenuItem(
      onTap: () => setState(() => _responseMode = mode),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: selected ? ChatColors.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (selected)
            const Icon(Icons.check, size: 16, color: ChatColors.primary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;

        return Container(
          color: ChatColors.background,
          child: Row(
            children: [
              if (isDesktop)
                SizeTransition(
                  sizeFactor: _sidebarSlide,
                  axis: Axis.horizontal,
                  child: ChatSidebar(
                    selectedId: _selectedChatId,
                    onSelectChat: (id) {
                      setState(() => _selectedChatId = id);
                    },
                    onNewChat: _onNewChat,
                    onClose: _toggleSidebar,
                  ),
                ),
              if (isDesktop && _sidebarOpen)
                VerticalDivider(width: 1, color: Colors.grey.shade200),
              Expanded(
                child: Column(
                  children: [
                    const TermtemHeader(),
                    Expanded(
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  24,
                                ),
                                itemCount: _messages.length,
                                itemBuilder: (ctx, index) {
                                  return ChatMessageBubble(
                                    message: _messages[index],
                                  );
                                },
                              ),
                            ),
                            SuggestedChips(
                              onChipTap: (text) {
                                setState(() {
                                  _controller.text = text;
                                  _controller.selection =
                                      TextSelection.fromPosition(
                                        TextPosition(
                                          offset: _controller.text.length,
                                        ),
                                      );
                                });
                              },
                            ),
                            ChatInputBar(
                              controller: _controller,
                              onSend: _sendMessage,
                              onShowAttachMenu: _showAttachMenu,
                              onShowModeMenu: _showSendMenu,
                              responseMode: _responseMode,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

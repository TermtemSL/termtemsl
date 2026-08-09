class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final String type; // 'text', 'speech', 'animation'
  final String? audioLabel;
  final String? videoLabel;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.type = 'text',
    this.audioLabel,
    this.videoLabel,
    required this.createdAt,
  });
}

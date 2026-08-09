class ChatSession {
  final String id;
  final String title;
  final String preview;
  final String timeLabel;
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    required this.title,
    required this.preview,
    required this.timeLabel,
    required this.updatedAt,
  });
}

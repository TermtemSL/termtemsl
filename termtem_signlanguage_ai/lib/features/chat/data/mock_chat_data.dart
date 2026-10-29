import '../models/chat_message.dart';
import '../models/chat_session.dart';

class MockChatData {
  static final List<ChatSession> sessions = [
    ChatSession(
      id: '1',
      title: 'ฝึกคำว่า ขอบคุณ',
      preview: 'การทำท่าทางขอบคุณที่ถูกต้อง...',
      timeLabel: 'Today',
      updatedAt: DateTime.now(),
    ),
    ChatSession(
      id: '2',
      title: 'หมวดหมู่ครอบครัว',
      preview: 'พ่อ แม่ พี่ น้อง...',
      timeLabel: 'Today',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ChatSession(
      id: '3',
      title: 'คำทักทายพื้นฐาน',
      preview: 'สวัสดี สบายดีไหม...',
      timeLabel: 'Yesterday',
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ChatSession(
      id: '4',
      title: 'หมวดอาหาร',
      preview: 'ข้าว น้ำ หิวข้าว...',
      timeLabel: 'Mon',
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final List<ChatMessage> initialMessages = [
    ChatMessage(
      id: 'msg1',
      text: "สวัสดีครับ ผม Nong Termtem วันนี้อยากฝึกคำไหนครับ?",
      isUser: false,
      type: 'text',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      id: 'msg2',
      text: "อยากฝึกคำว่า ขอบคุณ",
      isUser: true,
      type: 'text',
      createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      id: 'msg3',
      text: "คำว่า ขอบคุณ ใช้บ่อยมากในการทักทายและแสดงความสุภาพครับ ดูตัวอย่างท่าทางได้เลย",
      isUser: false,
      type: 'animation',
      videoLabel: "ขอบคุณ (Thank You)",
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      id: 'msg4',
      text: "อยากลองฝึกทำตามตอนนี้เลยไหมครับ หรืออยากดูคำอื่นต่อ?",
      isUser: false,
      type: 'text',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];
}

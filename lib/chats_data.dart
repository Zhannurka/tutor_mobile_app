import 'package:flutter/material.dart';

// ========================================================
// 1. User Model
// ========================================================
class User {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String lastVisit;

  const User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
    this.lastVisit = '',
  });
}

// ========================================================
// 2. Message Model
// ========================================================
class Message {
  final String text;
  final String time;
  final bool isMe;

  const Message({required this.text, required this.time, required this.isMe});
}

// ========================================================
// 3. Chat Model
// ========================================================
class Chat {
  final User user;
  final List<Message> messages;
  final bool isActive;

  Chat({required this.user, List<Message>? messages, this.isActive = true})
    : messages = messages ?? [];
}

// ========================================================
// 4. Initial Mock Data
// ========================================================
final User bhupesh = User(
  id: 'mentor_bhupesh',
  name: 'Bhupesh Sharma',
  avatarUrl: 'assets/bhupesh.png',
  isOnline: true,
  lastVisit: '1h ago',
);

final User madina = User(
  id: 'mentor_madina',
  name: 'Мәдина Серікбаева',
  avatarUrl: 'assets/madina.jpeg',
  isOnline: false,
  lastVisit: '2 days ago',
);

final List<Message> bhupeshChatMessages = [
  const Message(text: 'Сәлем, Николь!', time: '09:40', isMe: false),
  const Message(
    text: 'Сәлеметсіз бе! Қалыңыз қалай?',
    time: '09:42',
    isMe: true,
  ),
  const Message(
    text: 'Керемет! Сабаққа дайынсың ба?',
    time: '09:43',
    isMe: false,
  ),
];

List<Chat> initialChats = [
  Chat(user: bhupesh, messages: bhupeshChatMessages),
  Chat(
    user: madina,
    messages: [
      const Message(
        text: 'Кешіріңіз, сессия уақытыңыз аяқталды.',
        time: '11:00',
        isMe: false,
      ),
    ],
    isActive: false,
  ),
];

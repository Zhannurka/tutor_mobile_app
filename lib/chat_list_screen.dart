import 'package:flutter/material.dart';
import 'package:repetitor/chats_data.dart';

const Color primaryGreen = Color(0xFF38B08B);

// ========================================================
// ChatsListScreen - Чаттар тізімі
// ========================================================
class ChatsListScreen extends StatelessWidget {
  final List<Chat> chats;
  final Function(Chat) onChatTapped;

  const ChatsListScreen({
    super.key,
    required this.chats,
    required this.onChatTapped,
  });

  @override
  Widget build(BuildContext context) {
    final activeChats = chats.where((c) => c.isActive).toList();
    final expiredChats = chats.where((c) => !c.isActive).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Чаты',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (activeChats.isNotEmpty)
              _buildChatSection(context, 'Белсенді чаты', activeChats, false),
            if (expiredChats.isNotEmpty)
              _buildChatSection(
                context,
                'Мерзімі біткен чаты',
                expiredChats,
                true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection(
    BuildContext context,
    String title,
    List<Chat> chatList,
    bool isExpired,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...chatList.map((chat) => _buildChatTile(context, chat, isExpired)),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Chat chat, bool isExpired) {
    final lastMessage = chat.messages.isNotEmpty ? chat.messages.first : null;
    final user = chat.user;

    return InkWell(
      onTap: () => onChatTapped(chat),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: primaryGreen.withOpacity(0.1),
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? AssetImage(user.avatarUrl)
                  : null,
              child: user.avatarUrl.isEmpty
                  ? Text(
                      user.name[0],
                      style: const TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isExpired
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: isExpired ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage?.text ?? 'Чат бос',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isExpired ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              lastMessage?.time ?? '',
              style: TextStyle(
                color: isExpired ? Colors.grey : primaryGreen,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

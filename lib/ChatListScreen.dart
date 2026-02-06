import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ChatScreen.dart';

class TutorChatListScreen extends StatefulWidget {
  final String tutorId;

  const TutorChatListScreen({super.key, required this.tutorId});

  @override
  State<TutorChatListScreen> createState() => _TutorChatListScreenState();
}

class _TutorChatListScreenState extends State<TutorChatListScreen> {
  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/student/my-chats/${widget.tutorId}'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            chats = List<Map<String, dynamic>>.from(jsonDecode(response.body));
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Чаттарды жүктеу қатесі: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Хабарламалар"),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
          ? const Center(child: Text("Әзірге хабарламалар жоқ"))
          : RefreshIndicator(
              onRefresh: fetchChats, // Төмен тартқанда жаңарту
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];

                  // Серверден келетін деректі қауіпсіз оқу
                  // Егер Detailed Chats (алдыңғы жауаптағы сервер коды) қолданылса:
                  String studentName = chat['partnerName'] ?? "Студент";
                  String studentId = chat['partnerId'] ?? "";
                  String lastMsg = chat['lastMessage'] ?? "";

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE0E7FF),
                        child: Text(
                          studentName.isNotEmpty
                              ? studentName[0].toUpperCase()
                              : "?",
                        ),
                      ),
                      title: Text(
                        studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Репетитор үшін 'partnerId' бұл — Студент
                        String studentIdFromChat = chat['partnerId'] ?? "";

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              studentId:
                                  studentIdFromChat, // 👈 Бұл жерге студенттің ID-і бару керек
                              tutorId:
                                  widget.tutorId, // Бұл — репетитордың өз ID-і
                              chatPartnerName: studentName,
                              isStudent: false, // ✅ Репетитор екенін растаймыз
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

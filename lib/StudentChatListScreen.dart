import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ChatScreen.dart';
import 'ChatListScreen.dart';

class StudentChatListScreen extends StatefulWidget {
  final String studentId;


  const StudentChatListScreen({super.key, required this.studentId});

  @override
  State<StudentChatListScreen> createState() => _StudentChatListScreenState();
}

class _StudentChatListScreenState extends State<StudentChatListScreen> {
  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentChats();
  }

  Future<void> fetchStudentChats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/student/my-chats/${widget.studentId}'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            chats = List<Map<String, dynamic>>.from(jsonDecode(response.body));
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
        debugPrint("Чаттарды алу қатесі: ${response.statusCode}");
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
        title: const Text("Менің чаттарым"),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
          ? const Center(child: Text("Әзірге чаттар жоқ"))
          : RefreshIndicator(
              onRefresh: fetchStudentChats,
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  String partnerName = chat['partnerName'] ?? "Репетитор";
                  String lastMsg = chat['lastMessage'] ?? "";
                  String tutorId = chat['partnerId'] ?? "";

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
                          partnerName.isNotEmpty
                              ? partnerName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text(
                        partnerName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              studentId: widget.studentId,
                              tutorId: tutorId,
                              chatPartnerName: partnerName, // 👈 репетитор аты
                              autoSendTemplate: true, // шаблон хат жіберіледі
                              isStudent: true, // 👈 студент
                            ),
                          ),
                        ).then((_) => fetchStudentChats());
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

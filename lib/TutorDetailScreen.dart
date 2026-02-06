import 'package:flutter/material.dart';
import 'ChatScreen.dart';

class TutorDetailScreen extends StatelessWidget {
  final Map tutor;
  final String studentId;

  TutorDetailScreen({required this.tutor, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tutor['name'] ?? "Репетитор"),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TUTOR HEADER
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.05),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        (tutor['avatar'] != null && tutor['avatar'] != "")
                        ? NetworkImage(tutor['avatar'])
                        : null,
                    child: (tutor['avatar'] == null || tutor['avatar'] == "")
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    tutor['name'] ?? "Аты жоқ",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    tutor['subject'] ?? "Пән таңдалмаған",
                    style: const TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                ],
              ),
            ),

            // INFO SECTION
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoSection("Бағасы:", "${tutor['price'] ?? 0} тг / сағат"),
                  const SizedBox(height: 25),
                  const Text(
                    "Өзі туралы:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tutor['bio'] ?? "Ақпарат жазылмаған.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(context),
    );
  }

  Widget _infoSection(String title, String val) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            val,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: ElevatedButton(
        onPressed: () {
          if (studentId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Қате: Авторизациядан қайта өтіңіз"),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                studentId: studentId,
                tutorId: tutor['_id'],
                chatPartnerName: tutor['name'] ?? "Репетитор",
                autoSendTemplate: true,
                isStudent: true, // ✅ МІНЕ ОСЫ ЖЕТПЕЙ ТҰРҒАН
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Сабаққа жазылу",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

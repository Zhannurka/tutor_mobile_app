import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'TutorScheduleScreen.dart';
import 'tutor_profile_screen.dart';
import 'ChatListScreen.dart';
import 'ChatScreen.dart';
import 'TutorDetailScreen.dart';

class TutorHomeScreen extends StatefulWidget {
  final String tutorId;

  TutorHomeScreen({required this.tutorId});

  @override
  _TutorHomeScreenState createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> {
  // --- Навигация айнымалылары ---
  int _selectedIndex = 0;

  // --- Деректер айнымалылары ---
  String tutorName = "Жүктелуде...";
  String? avatarUrl;
  int studentCount = 0;
  int completedHours = 0;
  bool isActive = true;

  late IO.Socket socket;
  // String орнына dynamic қолданамыз, себебі серверден әртүрлі тип келеді
  List<Map<String, dynamic>> newMessages = [];

  Map<String, dynamic>? todayNextLesson;

  @override
  void initState() {
    super.initState();
    fetchStats();
    fetchLatestMessages();
    fetchTodayLesson();
    initSocket(); // WebSocket қосу
  }

  // --- 1. Серверден статистика мен профиль алу ---
  Future<void> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/tutor/stats/${widget.tutorId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tutorName = data['name'] ?? "Аты жоқ";
          avatarUrl = (data['avatar'] != null && data['avatar'].isNotEmpty)
              ? data['avatar']
              : null;
          studentCount = data['studentsCount'] ?? 0;
          completedHours = data['completedHours'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Статистика жүктеу қатесі: $e");
    }
  }

  Future<void> fetchLatestMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/tutor/latestMessages/${widget.tutorId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          // Соңғы 5 хабарламаны көрсету
          newMessages = data
              .map(
                (msg) => {
                  "name": msg['senderName'] ?? "Студент",
                  "text": msg['text'] ?? "",
                  "senderId": msg['senderId'] ?? "",
                },
              )
              .take(5)
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Хабарламаларды жүктеу қатесі: $e");
    }
  }

  Future<void> fetchTodayLesson() async {
    try {
      // Серверден бүгінгі ең жақын сабақты алатын маршрут (мысалы: /tutor/today-lesson/)
      final response = await http.get(
        Uri.parse('http://localhost:3000/tutor/today-lesson/${widget.tutorId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data.isNotEmpty) {
          setState(() {
            todayNextLesson = {
              "studentName": data['studentName'] ?? "Студент",
              "time": data['time'] ?? "--:--",
              "date": data['date'] ?? "", // Серверден: 2026-02-02
            };
          });
        }
      }
    } catch (e) {
      debugPrint("Кестені жүктеу қатесі: $e");
    }
  }

  // --- 2. Socket.io байланысы ---
  // ... (басқа кодтар өзгеріссіз)
  void initSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      debugPrint("Socket қосылды");
      // Әр репетитор үшін арнайы бөлмеге қосыламыз
      socket.emit('join_tutor_room', widget.tutorId);
    });

    // Жаңа хабарламаны қабылдау
    socket.on('receive_message', (data) {
      if (!mounted) return;

      // Тек студенттен келген хабарламалар
      if (data['senderRole'] == 'STUDENT' &&
          data['receiverId'].toString() == widget.tutorId) {
        setState(() {
          newMessages.insert(0, {
            "name": data['senderName'] ?? "Студент",
            "text": data['text'] ?? "",
            "senderId": data['senderId'],
          });

          if (newMessages.length > 5) newMessages.removeLast(); // тек соңғы 5
        });
      }
    });
  }

  Widget _chatTile(String name, String text, String studentId) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFE0E7FF),
          child: Text(name.isNotEmpty ? name[0] : "С"),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mail, size: 14, color: Color(0xFF1E3A8A)),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                studentId: studentId,
                tutorId: widget.tutorId,
                chatPartnerName: name, // студенттің аты
                autoSendTemplate: false,
                isStudent: false, // ✅ репетитор
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  // --- БЕТТЕР ТІЗІМІ ---
  List<Widget> _getPages() {
    return [
      _buildHomeContent(), // 0 - Басты бет (Статистика)
      TutorScheduleScreen(tutorId: widget.tutorId), // 1 - Кесте
      TutorChatListScreen(
        tutorId: widget.tutorId,
      ), // 2 - МЫНА ЖЕРГЕ ЖАҢА ЧАТТЫ ҚОСТЫҚ ✅
      TutorProfileScreen(tutorId: widget.tutorId), // 3 - Профиль
    ];
  }

  // --- БАСТЫ БЕТ МАЗМҰНЫ (UI) ---
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await fetchStats();
        await fetchLatestMessages();
        await fetchTodayLesson();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.only(
                top: 60,
                left: 25,
                right: 25,
                bottom: 40,
              ),
              decoration: BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Қайырлы күн,\n$tutorName!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person, size: 35, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),

            // STATISTICS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      _statusCard("$studentCount", "Студенттер"),
                      SizedBox(width: 15),
                      _statusCard("$completedHours", "Сағаттар"),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildStatusToggle(),
                ],
              ),
            ),

            _sectionHeader("Жаңа хабарламалар"),
            _buildMessageList(),

            _sectionHeader("Бүгінгі кесте"),
            _buildScheduleSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      body: _getPages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Егер "Басты бетке" (0) өтсе, деректерді серверден қайта тартамыз
          if (index == 0) {
            fetchStats();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Басты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Кесте',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Чат'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }

  // --- КӨМЕКШІ ВИДЖЕТТЕР ---

  Widget _statusCard(String count, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Жұмысқа дайынмын",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Switch(
            value: isActive,
            onChanged: (v) => setState(() => isActive = v),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (newMessages.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Text("Хабарлама жоқ", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: newMessages.length,
      itemBuilder: (context, index) {
        final msg = newMessages[index];
        return _chatTile(
          msg['name'] ?? "Студент",
          msg['text'] ?? "",
          msg['senderId'] ?? "",
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A38),
          ),
        ),
      ),
    );
  }

  // 2-ші ҚАТЕНІ ТҮЗЕТУ: Кесте виджетін динамикалық қылу
  Widget _buildScheduleSection() {
    // Егер серверден дерек келмесе (todayNextLesson бос болса)
    if (todayNextLesson == null || todayNextLesson!.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            "Бүгінге сабақ жоқ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.timer_outlined, color: Colors.orange),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todayNextLesson!['studentName'] ?? "Студент",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Бүгін, ${todayNextLesson!['time']}", // Серверден келетін уақыт (15:20)
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("Жақында дайын болады", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

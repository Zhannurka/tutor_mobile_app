import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TutorDetailScreen.dart';
import 'StudentChatListScreen.dart';
import 'StudentProfileScreen.dart';
import 'StudentScheduleScreen.dart'; // 👈 ОСЫНЫ ҚОС

class StudentMainScreen extends StatefulWidget {
  final String studentId;
  const StudentMainScreen({super.key, required this.studentId});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _selectedIndex = 0;
  String studentName = "Жүктелуде...";
  String studentAvatar = "";

  @override
  void initState() {
    super.initState();
    fetchStudentProfile();
  }

  // Студенттің аты мен фотосын алу
  Future<void> fetchStudentProfile() async {
    debugPrint(
      "БАТЫРЫМ, МЫНА ID КЕЛДІ: ${widget.studentId}",
    ); // Осы жерде нақты сандар мен әріптер шығуы керек

    if (widget.studentId == ":id" || widget.studentId.isEmpty) {
      setState(() => studentName = "ID келмеді");
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/student/stats/${widget.studentId}',
        ), // 👈 IP-ді тексер
      );

      print("Статус коды: ${response.statusCode}"); // Консольге шығады
      print("Деректер: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          studentName = data['name'] ?? "Аты белгісіз";
          studentAvatar = data['avatar'] ?? "";
        });
      } else {
        setState(() => studentName = "Сервер қатесі");
      }
    } catch (e) {
      print("Қате: $e");
      setState(() => studentName = "Қосылу сәтсіз");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      StudentHomeScreen(
        name: studentName,
        avatar: studentAvatar,
        studentId: widget.studentId,
      ),
      StudentScheduleScreen(studentId: widget.studentId),

      StudentChatListScreen(studentId: widget.studentId),
      StudentProfileScreen(
        studentId: widget.studentId,
        name: studentName,
        avatar: studentAvatar,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        // 👈 IndexedStack қолданған жақсы, бет ауысқанда деректер жоғалмайды
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0 || index == 3) {
            fetchStudentProfile();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
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
}

class StudentHomeScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final String studentId; // 👈 ЖАҢА АЙНЫМАЛЫ

  const StudentHomeScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.studentId, // 👈 МІНДЕТТІ ҚЫЛУ
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  List allTutors = []; // Серверден келген барлық тізім
  List filteredTutors = []; // Іздеу кезінде өзгеретін тізім
  bool isLoading = true;
  final TextEditingController _searchController =
      TextEditingController(); // Контроллер

  @override
  void initState() {
    super.initState();
    fetchTutors();
  }

  // Серверден алу функциясын жаңарту
  Future<void> fetchTutors() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/student/tutors'), // Эмулятор үшін IP
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          allTutors = data;
          filteredTutors = data; // Бастапқыда екеуі бірдей
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // 🔎 ІЗДЕУ ЛОГИКАСЫ
  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      results = allTutors;
    } else {
      results = allTutors.where((tutor) {
        final name = tutor['name'].toString().toLowerCase();
        final subject = (tutor['subject'] ?? "").toString().toLowerCase();
        final searchString = enteredKeyword.toLowerCase();
        return name.contains(searchString) || subject.contains(searchString);
      }).toList();
    }

    setState(() {
      filteredTutors = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFD),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBanner(),
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(),
                        )
                      : _buildTutorList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Қош келдіңіз,",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                backgroundImage: widget.avatar.isNotEmpty
                    ? NetworkImage(widget.avatar)
                    : null,
                child: widget.avatar.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _searchController,
            onChanged: (value) => _runFilter(value), // Жазған сайын іздейді
            decoration: InputDecoration(
              hintText: "Репетитор іздеу...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              // Тазалау батырмасы (X)
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _runFilter('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/banner_ustaz.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 120,
            width: double.infinity,
            color: Colors.green.shade100,
            child: const Center(
              child: Text(
                "Білікті репетиторды таңдаңыз!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorList() {
    // Егер іздеу нәтижесі бос болса
    if (filteredTutors.isEmpty && !isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Өкінішке орай, ештеңе табылмады..."),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredTutors.length, // filteredTutors-ты қолданамыз
      itemBuilder: (context, index) {
        final tutor = filteredTutors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage:
                  (tutor['avatar'] != null && tutor['avatar'] != "")
                  ? NetworkImage(tutor['avatar'])
                  : null,
              child: (tutor['avatar'] == null || tutor['avatar'] == "")
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              tutor['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              tutor['subject'] ?? "Пән жоқ",
              style: const TextStyle(color: Colors.blue),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            // StudentHomeScreen-нің itemBuilder ішінде
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TutorDetailScreen(
                  tutor: tutor,
                  studentId: widget.studentId, // 👈 ЕНДІ БОС ЕМЕС!
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

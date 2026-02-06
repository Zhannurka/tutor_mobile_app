import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'TutorFinderApp.dart';

class TutorProfileScreen extends StatefulWidget {
  final String tutorId;
  TutorProfileScreen({required this.tutorId});

  @override
  _TutorProfileScreenState createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  // Мәліметтерді өңдеу үшін контроллерлер
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // Серверден қолданушы мәліметтерін алу
  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/tutor/stats/${widget.tutorId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Деректерді жүктеу қатесі: $e", Colors.red);
    }
  }

  // Сервердегі профильді жаңарту
  Future<void> _updateProfile() async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://localhost:3000/tutor/update-profile/${widget.tutorId}',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "subject": _subjectController.text,
          "price": int.tryParse(_priceController.text) ?? 0,
          "bio": _bioController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Профиль сәтті жаңартылды!", Colors.green);
        fetchUserProfile(); // Экрандағы деректерді жаңарту
        Navigator.pop(context); // Терезені жабу
      } else {
        _showSnackBar("Қате: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Сервермен байланыс үзілді", Colors.red);
    }
  }

  // Галереядан фото таңдау және серверге жүктеу
  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Сапасын сәл төмендету (жылдам жүктелу үшін)
    );

    if (image != null) {
      _showSnackBar("Сурет жүктелуде...", Colors.blue);

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
            'http://localhost:3000/tutor/upload-avatar/${widget.tutorId}',
          ),
        );
        // fromPath орнына fromBytes қолданамыз. Бұл Web-те де, Mobile-да да істейді.
        var bytes = await image.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'avatar',
            bytes,
            filename: image.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          _showSnackBar("Профиль фотосы жаңартылды!", Colors.green);
          fetchUserProfile(); // Мәліметтерді қайта жаңарту
        } else {
          _showSnackBar("Сервер қатесі: ${response.statusCode}", Colors.red);
        }
      } catch (e) {
        _showSnackBar("Жүктеу қатесі: $e", Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildBioSection(), // ЖАҢА БЛОК ОСЫ ЖЕРДЕ
                  const SizedBox(height: 20),
                  _buildInfoSection(),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      (userData?['avatar'] != null && userData!['avatar'] != "")
                      ? NetworkImage(userData!['avatar'])
                      : null,
                  child:
                      (userData?['avatar'] == null || userData!['avatar'] == "")
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            userData?['name'] ?? "Аты-жөні",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _showEditSheet,
            icon: const Icon(Icons.edit, color: Colors.white, size: 18),
            label: const Text(
              "Профильді өңдеу",
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Text(
            "Тәжірибелі репетитор",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard(
            "Студенттер",
            userData?['studentsCount']?.toString() ?? "0",
            Icons.people,
          ),
          const SizedBox(width: 15),
          _statCard(
            "Сағаттар",
            userData?['completedHours']?.toString() ?? "0",
            Icons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Биография және Қызметтер",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          _bioRow(
            Icons.book_outlined,
            "Пән:",
            userData?['subject'] ?? "Жүктелуде...",
          ),
          _bioRow(
            Icons.payments_outlined,
            "Бағасы:",
            "${userData?['price'] ?? 0} тг / сағат",
          ),
          const Divider(height: 30),
          const Text(
            "Өзім туралы:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            userData?['bio'] ?? "Ақпарат толтырылмаған",
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bioRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _infoRow(Icons.email, "Пошта", userData?['email'] ?? "Көрсетілмеген"),
          const Divider(),
          _infoRow(
            Icons.phone,
            "Телефон",
            userData?['phone'] ?? "Көрсетілмеген",
          ),
          const Divider(),
          _infoRow(Icons.verified, "Статус", "Верификацияланған"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showEditSheet() {
    // Ескі мәліметтерді өрістерге толтырып қою
    _subjectController.text = userData?['subject'] ?? "";
    _priceController.text = userData?['price']?.toString() ?? "";
    _bioController.text = userData?['bio'] ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Пернетақта шыққанда экранның көтерілуі үшін
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Профильді өңдеу",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: "Пән (мысалы: Математика)",
              ),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Бағасы (тг/сағат)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: "Өзіңіз туралы"),
              maxLines: 3,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Сақтау",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: () {
          // Шығуды растау үшін диалогтық терезе көрсету (міндетті емес, бірақ жақсырақ)
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Шығу"),
              content: const Text("Расымен жүйеден шыққыңыз келе ме?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Жоқ"),
                ),
                TextButton(
                  onPressed: () {
                    // Барлық беттерді өшіріп, WelcomeScreen-ге қайту
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                      (route) => false, // Барлық ескі жолдарды (routes) өшіреді
                    );
                  },
                  child: const Text("Иә", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, 55),
          backgroundColor: Colors.red[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "Шығу",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

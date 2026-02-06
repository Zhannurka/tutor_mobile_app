import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'TutorFinderApp.dart'; // 👈 OnboardingScreen осы файлда болуы керек

class StudentProfileScreen extends StatefulWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId, required String name, required String avatar});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String name = "Жүктелуде...";
  String email = "";
  String phone = "Көрсетілмеген";
  String? avatarUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // 1️⃣ Профиль деректерін алу
  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/student/stats/${widget.studentId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data['name'] ?? "Аты жоқ";
          email = data['email'] ?? "";
          phone = data['phone'] ?? "Көрсетілмеген";
          avatarUrl = data['avatar'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Fetch error: $e");
    }
  }

  // 2️⃣ СУРЕТ ТАҢДАУ ЖӘНЕ ЖҮКТЕУ (Осы функция жоқ болғандықтан қызыл болды)
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        var uri = Uri.parse(
          'http://localhost:3000/student/upload-avatar/${widget.studentId}',
        );
        var request = http.MultipartRequest('POST', uri);

        if (kIsWeb) {
          var bytes = await image.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'avatar',
              bytes,
              filename: image.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('avatar', image.path),
          );
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            avatarUrl = data['avatar'];
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Аватарка жаңартылды!")));
        }
      } catch (e) {
        print("Upload error: $e");
      }
    }
  }

  // 3️⃣ Профильді жаңарту (API)
  Future<void> _updateProfile(String newName, String newPhone) async {
    try {
      final response = await http.put(
        Uri.parse(
          'http://localhost:3000/student/update-profile/${widget.studentId}',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": newName, "phone": newPhone}),
      );
      if (response.statusCode == 200) {
        _fetchProfile();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Сәтті сақталды!")));
      }
    } catch (e) {
      print("Update error: $e");
    }
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Профильді өңдеу"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Аты-жөні"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Телефон"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Бас тарту"),
          ),
          ElevatedButton(
            onPressed: () {
              _updateProfile(nameController.text, phoneController.text);
              Navigator.pop(context);
            },
            child: const Text("Сақтау"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Профиль"),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildInfoTile(Icons.email, "Email", email),
                  _buildInfoTile(Icons.phone, "Телефон", phone),
                  _buildInfoTile(
                    Icons.settings,
                    "Баптаулар",
                    "Мәліметтерді жаңарту",
                    onTap: _showEditDialog,
                  ),
                  const Divider(indent: 70),
                  _buildInfoTile(
                    Icons.logout,
                    "Шығу",
                    "Тіркелгіден шығу",
                    color: Colors.red,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white24,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadImage, // 👈 Енді қызыл емес!
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF1E3A8A),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Студент",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String subtitle, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF1E3A8A), size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

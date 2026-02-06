import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();

  Future<void> _resetPassword() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/forgot-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text,
        "phone": _phoneController.text,
        "newPassword": _newPasswordController.text,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Құпия сөз жаңартылды! Енді кіре аласыз."),
        ),
      );
      Navigator.pop(context); // Логин бетіне қайту
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Құпия сөзді ұмыттыңыз ба?")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Телефон (Тіркелген нөмір)",
              ),
            ),
            TextField(
              controller: _newPasswordController,
              // Тексттің түсін қара немесе көкшіл қылу (оқылуы үшін)
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Жаңа құпия сөз",
                labelStyle: const TextStyle(color: Colors.grey), // Жазудың түсі
                filled: true,
                fillColor: Colors.white, // Фонды ақ қылу
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 252, 252, 252),
              ),
              child: const Text("Құпия сөзді өзгерту"),
            ),
          ],
        ),
      ),
    );
  }
}

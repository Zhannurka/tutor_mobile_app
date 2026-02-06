import 'package:flutter/material.dart';
import 'package:repetitor/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'StudentMainScreen.dart';
import 'ForgotPasswordScreen.dart';
class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  static const Color primaryBlue = Color(0xFF1E3A8A);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // 🔹 Эмулятор үшін localhost орнына 10.0.2.2
  final String _serverLoginUrl = 'http://localhost:3000/student/login';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(
        () => _errorMessage =
            'Пожалуйста, введите адрес электронной почты и пароль.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(_serverLoginUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'student', // 🔹 Міндетті түрде қосу керек
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userName = data['user']?['name'] ?? 'Пользователь';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Добро пожаловать, $userName!'),
            backgroundColor: primaryBlue,
          ),
        );

        debugPrint('✅ Студент сәтті кірді.');

        if (mounted) {
          final studentId =
              data['user']?['_id']; // Серверден келген ID-ді аламыз

          if (studentId != null) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => StudentMainScreen(studentId: studentId),
              ),
              (route) => false,
            );
          } else {
            debugPrint('❌ Қате: Сервер ID жіберген жоқ!');
          }
        } else {
          final errorData = jsonDecode(response.body);
          final message =
              errorData['message'] ?? 'Ошибка входа. Проверьте учетные данные.';
          setState(() => _errorMessage = message);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: $message'),
              backgroundColor: Colors.redAccent,
            ),
          );
          debugPrint(
            'HTTP Login Error: ${response.statusCode}, Message: $message',
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Не удалось подключиться к серверу.');
      debugPrint('❌ Network Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String roleTitle = 'Студент';
    final String registerRoute = '/studentRegister';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Войти как $roleTitle',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A38),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                'Электронная почта',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                context,
                Icons.email_outlined,
                'Введите адрес электронной почты',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              const Text(
                'Пароль',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                context,
                Icons.lock_outline,
                'Введите пароль',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 10),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // 👈 Забыли пароль бетіне өту
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Забыли пароль?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ВОЙТИ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Нет аккаунта? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, registerRoute),
                    child: Text(
                      'Зарегистрируйтесь здесь',
                      style: TextStyle(
                        color: TutorFinderApp.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    IconData icon,
    String hintText, {
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 10.0,
          ),
        ),
      ),
    );
  }
}

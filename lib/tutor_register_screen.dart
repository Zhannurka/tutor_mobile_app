import 'package:flutter/material.dart';
import 'package:repetitor/main.dart'; // primaryGreen түсі үшін
import 'dart:convert';
import 'package:http/http.dart' as http;

// ОСЫ ЖЕРДЕ: Логин беті орналасқан файлдың жолын дұрыстап көрсет
import 'package:repetitor/tutor_login_screen.dart';

class TutorRegisterScreen extends StatefulWidget {
  const TutorRegisterScreen({super.key});

  @override
  State<TutorRegisterScreen> createState() => _TutorRegisterScreenState();
}

class _TutorRegisterScreenState extends State<TutorRegisterScreen> {
  // Түсті тікелей TutorFinderApp-тан немесе кодпен бердік
  static const Color buttonColor = Color(0xFF1E3A8A);
  final String role = 'Репетитора';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final String _serverRegisterUrl = 'http://localhost:3000/tutor/register';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🔹 Валидация логикасы
  bool _validateInputs() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Пожалуйста, заполните все поля.');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'Введите корректный email.');
      return false;
    }

    if (password.length < 6) {
      setState(
        () => _errorMessage = 'Пароль должен содержать минимум 6 символов.',
      );
      return false;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Пароли не совпадают.');
      return false;
    }

    return true;
  }

  // --- Репетиторды тіркеу және Логинге өту логикасы ---
  Future<void> _register() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse(_serverRegisterUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text,
          'role': 'tutor',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Регистрация прошла успешно! Теперь войдите.'),
              backgroundColor: buttonColor,
            ),
          );

          // ✅ ТҮЗЕТУ: Тіркелген соң Логин бетіне бағыттау
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TutorLoginScreen()),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(
          () => _errorMessage = errorData['message'] ?? 'Ошибка регистрации.',
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Не удалось подключиться к серверу.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Регистрация $role',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A38),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              _buildLabel('Имя ($role)'),
              _buildInputField(
                Icons.person_outline,
                'Введите Ваше имя',
                controller: _nameController,
              ),
              const SizedBox(height: 30),
              _buildLabel('Электронная почта'),
              _buildInputField(
                Icons.email_outlined,
                'Введите адрес электронной почты',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              _buildLabel('Мобильный номер'),
              _buildInputField(
                Icons.phone_iphone,
                'Введите мобильный номер',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 30),
              _buildLabel('Пароль'),
              _buildInputField(
                Icons.lock_outline,
                'Установите пароль',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 30),
              _buildLabel('Подтверждение пароля'),
              _buildInputField(
                Icons.lock_outline,
                'Подтвердите пароль',
                controller: _confirmPasswordController,
                isPassword: true,
              ),

              const SizedBox(height: 10),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'ЗАРЕГИСТРИРОВАТЬСЯ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)),
  );

  Widget _buildInputField(
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

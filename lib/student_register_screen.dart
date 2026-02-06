import 'package:flutter/material.dart';
import 'package:repetitor/main.dart'; // TutorFinderApp-тен primaryGreen алу үшін
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  static const Color buttonColor = TutorFinderApp.primaryGreen;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final String _serverRegisterUrl = 'http://localhost:3000/student/register';

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

    // Барлық өрістер толтырылуы керек
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Пожалуйста, заполните все поля.';
      });
      return false;
    }

    // Email формат тексеру
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Введите корректный email.';
      });
      return false;
    }

    // Телефон формат тексеру (мысалы, +7 777 123 45 67 немесе 87771234567)
    final phoneRegex = RegExp(r'^(\+7|7|8)?\d{10}$');
    if (!phoneRegex.hasMatch(phone)) {
      setState(() {
        _errorMessage = 'Введите корректный номер телефона.';
      });
      return false;
    }

    // Пароль ұзындығы 6+ таңба болуы керек
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Пароль должен содержать минимум 6 символов.';
      });
      return false;
    }

    // Пароли совпадают
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Пароли не совпадают.';
      });
      return false;
    }

    return true;
  }

  // 🔹 Тіркелу логикасы
  Future<void> _register() async {
    if (!_validateInputs()) {
      return; // Егер валидация сәтсіз болса, серверге жіберілмейді
    }

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
          'role': 'student',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String userName =
            data['user']?['name'] ?? _nameController.text.trim();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Успешная регистрация, $userName!'),
            backgroundColor: buttonColor,
            duration: const Duration(seconds: 3),
          ),
        );

        debugPrint('✅ Студент сәтті тіркелді.');

        // 🔹 Сәтті тіркелуден кейін КІРУ (Логин) бетіне өткізу
        if (mounted) {
          // '/studentLogin' - бұл сенің Login бетіңнің маршруты
          Navigator.pushReplacementNamed(context, '/studentLogin');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final String message =
            errorData['message'] ?? 'Ошибка регистрации. Попробуйте позже.';

        setState(() {
          _errorMessage = message;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $message'),
            backgroundColor: Colors.redAccent,
          ),
        );
        debugPrint(
          'HTTP Registration Error: ${response.statusCode}, Message: $message',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Не удалось подключиться к серверу. Убедитесь, что сервер запущен.';
      });
      debugPrint('❌ Network Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String role = 'Студента';
    final String loginRoute = '/studentLogin';

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

              const Text(
                'Имя (Студента)',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                context,
                Icons.person_outline,
                'Введите Ваше имя',
                controller: _nameController,
              ),
              const SizedBox(height: 30),

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
                'Мобильный номер',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                context,
                Icons.phone_iphone,
                'Введите мобильный номер',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
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
                'Установите пароль',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 30),

              const Text(
                'Подтверждение пароля',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                context,
                Icons.lock_outline,
                'Подтвердите пароль',
                controller: _confirmPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 20),

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
                    elevation: 0,
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

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Уже есть аккаунт? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, loginRoute);
                    },
                    child: Text(
                      'Войти',
                      style: TextStyle(
                        color: TutorFinderApp.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Көмекші функция (Input өрістері)
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

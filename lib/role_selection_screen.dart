import 'package:flutter/material.dart';
import 'package:repetitor/main.dart'; // PrimaryGreen түсін алу үшін

// StatefulWidget-ке ауыстырамыз, себебі бізге таңдалған ролдің күйін сақтау керек
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // Бастапқыда 'Student' таңдалған деп есептейміз
  String _selectedRole = 'Student'; // 'Student' немесе 'Tutor'

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = TutorFinderApp.primaryGreen;
    // Ашық жасыл түс (таңдалғанын көрсету үшін)
    final Color lightGreen = primaryGreen.withOpacity(0.15);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Тақырып
              const Text(
                'С возвращением!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A38),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Пожалуйста, выберите свою роль, чтобы продолжить.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const Spacer(), // Жоғары кеңістік
              // Студент ролін таңдау батырмасы
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = 'Student'; // Рольді жаңарту
                  });
                },
                child: _buildRoleOption(
                  context,
                  'Студент',
                  Icons.person_outline,
                  _selectedRole == 'Student', // Қазіргі таңдалған роль
                  primaryGreen,
                  lightGreen,
                ),
              ),
              const SizedBox(height: 30),

              // Репетитор ролін таңдау батырмасы
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = 'Tutor'; // Рольді жаңарту
                  });
                },
                child: _buildRoleOption(
                  context,
                  'Репетитор',
                  Icons.school_outlined,
                  _selectedRole == 'Tutor', // Қазіргі таңдалған роль
                  primaryGreen,
                  lightGreen,
                ),
              ),

              const Spacer(), // Төменгі кеңістік
              // Продолжить батырмасы (Жасыл түсті)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // НАВИГАЦИЯНЫ ТЕКСЕРУ: Дұрыс маршрутты таңдау
                    String loginRoute = _selectedRole == 'Tutor'
                        ? '/tutorLogin'
                        : '/studentLogin';

                    Navigator.pushNamed(
                      context,
                      loginRoute, // Дұрыс логин бетіне өтеміз
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen, // Жасыл түсті
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Роль таңдау элементін құрастыруға арналған көмекші виджет
  Widget _buildRoleOption(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    Color primaryGreen,
    Color lightGreen,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? lightGreen
            : Colors.white, // Таңдалса, ашық жасыл фон
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? primaryGreen
              : Colors.grey.shade300, // Таңдалса, жасыл жиек
          width: 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: primaryGreen.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          if (!isSelected) // Таңдалмаса, ақ фонға жеңіл көлеңке
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: isSelected ? primaryGreen : Colors.grey.shade700,
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? primaryGreen : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

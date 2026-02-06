import 'package:flutter/material.dart';
import 'package:repetitor/main.dart'; // PrimaryGreen түсін алу үшін

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1E3A8A);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Контентты скролл жасау үшін Expanded + SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Сурет орны
                      Image.asset(
                        'assets/tutor.png',
                        height: 250,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 50),

                      // Тақырып (Орысша)
                      const Text(
                        'Найти лучшего репетитора в вашем районе',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2A38),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Сипаттама (Орысша)
                      const Text(
                        'Мы поможем найти лучшего репетитора в вашем районе. '
                        'Вы можете установить свои предпочтения и многое другое, '
                        'чтобы выбрать и забронировать репетитора.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),

              // Начать батырмасы экранның төменінде фиксирленген
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/roleSelection');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Начать',
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
}

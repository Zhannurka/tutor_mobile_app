import 'package:flutter/material.dart';

// Барлық экрандарды импорттау
import 'package:repetitor/TutorFinderApp.dart';
import 'package:repetitor/role_selection_screen.dart';
import 'package:repetitor/student_login_screen.dart';
import 'package:repetitor/tutor_login_screen.dart';
import 'package:repetitor/student_register_screen.dart';
import 'package:repetitor/tutor_register_screen.dart';
import 'package:repetitor/StudentMainScreen.dart';
import 'package:repetitor/mentor_search_screen.dart';
import 'package:repetitor/articles_screen.dart';
import 'package:repetitor/TutorHomeScreen.dart';

// 🔥🔥🔥 Қажетсіз ЧАТ ИМПОРТЫ АЛЫП ТАСТАЛДЫ 🔥🔥🔥
// import 'package:repetitor/chat_list_screen.dart';

void main() {
  runApp(const TutorFinderApp());
}

class TutorFinderApp extends StatelessWidget {
  const TutorFinderApp({super.key});

  // Негізгі жасыл түс
  static const Color primaryGreen = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutor Finder App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(secondary: primaryGreen, primary: primaryGreen),
        useMaterial3: true,
      ),

      initialRoute: '/',

      // ✅ МАРШРУТТАР ТІЗІМІ
      routes: {
        // Бастапқы экран (Бұл жерде сізде OnboardingScreen болуы керек)
        '/': (context) => const OnboardingScreen(),
        '/roleSelection': (context) => const RoleSelectionScreen(),

        // Студент
        '/studentLogin': (context) => const StudentLoginScreen(),
        '/studentRegister': (context) => const StudentRegisterScreen(),
        '/studentHome': (context) => StudentMainScreen(studentId: ''),

        // Репетитор
        '/tutorLogin': (context) => const TutorLoginScreen(),
        '/tutorRegister': (context) => const TutorRegisterScreen(),
        // Ескерту: Егер репетитордың жеке беті болмаса, студенттің үй бетіне жіберіледі
        '/tutorHome': (context) => TutorHomeScreen(tutorId: ''),

        // Репетиторларды іздеу (Навигациялық панельдегі 'Репетиторы' батырмасы үшін)
        '/mentorSearch': (context) => const MentorsScreen(),

        '/studentArticles': (context) => const ArticlesScreen(),

        // 🔥🔥🔥 '/chatScreen' маршруты StudentHomeScreen логикасына ауыстырылды,
        // сондықтан ол маршрут тізімінен толығымен алынып тасталды.
      },
    );
  }
}

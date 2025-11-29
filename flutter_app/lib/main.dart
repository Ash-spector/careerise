// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pages
import 'pages/profile_builder_page.dart';
import 'pages/career_insights_page.dart';
import 'pages/exams_page.dart';
import 'pages/exam_details_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/otp_verify_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/roadmap_page.dart';
import 'widgets/sidebar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  runApp(CareeriseApp(
    initialRoute: userId == null ? '/login' : '/dashboard',
  ));
}

class CareeriseApp extends StatelessWidget {
  final String initialRoute;
  const CareeriseApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Careerise',
      debugShowCheckedModeBanner: false,

      // 🌙 Dark theme UI
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050816),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B3EFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),

      // 🔗 Navigation Route Setup
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/forgot': (_) => const ForgotPasswordPage(),

        // Correct OTP route
        '/verify-otp': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
          final email = args['email'] ?? '';
          final from = args['from'] ?? 'forgot';
          return OtpVerifyPage(email: email, from: from);
        },

        // Reset password
        '/reset-password': (_) => const ResetPasswordPage(),

        // Dashboard
        '/dashboard': (_) => const SidebarLayout(),

        // Other functional pages
        '/profile': (_) => const ProfileBuilderPage(),
        '/career': (_) => const CareerInsightsPage(),
        '/exams': (_) => const ExamsPage(),
        '/exam-details': (_) => const ExamDetailsPage(),

        '/roadmap': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return RoadmapPage(
            role: args['role'],
            roadmap: args['roadmap'],
          );
        },
      },
    );
  }
}

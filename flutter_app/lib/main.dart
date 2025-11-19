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

      // ✅ App theme
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0C10),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B3EFF),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),

      // ✅ Route setup
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),

        // ✅ OTP verification route
        '/otp-verify': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final email = args is String ? args : '';
          return OtpVerifyPage(email: email);
        },

        // ✅ SidebarLayout no longer takes any parameters
        '/dashboard': (context) => const SidebarLayout(),

        // ✅ Other screens
        '/profile': (context) => const ProfileBuilderPage(),
        '/career': (context) => const CareerInsightsPage(),
        '/roadmap': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
              return RoadmapPage(role: args['role'], roadmap: args['roadmap']);
               },

        '/exams': (context) => const ExamsPage(),
        '/exam-details': (context) => const ExamDetailsPage(),
      },
    );
  }
}

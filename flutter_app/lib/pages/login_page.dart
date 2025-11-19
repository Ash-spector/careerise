import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  bool isValidEmail(String email) {
    return RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(email);
  }

  Future<void> doLogin() async {
    if (!isValidEmail(emailCtrl.text.trim())) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter valid email")));
      return;
    }

    setState(() => loading = true);

    try {
      final res = await AuthService.login(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", res["userId"]);
      await prefs.setString("userName", res["name"]);

      Navigator.pushReplacementNamed(context, "/dashboard");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Careerise", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: loading ? null : doLogin,
                child: loading ? const CircularProgressIndicator() : const Text("Login"),
              ),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/signup"),
                child: const Text("Create account"),
              ),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/forgot-password"),
                child: const Text("Forgot Password?"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

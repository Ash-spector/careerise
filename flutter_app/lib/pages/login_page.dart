import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  void handleLogin() async {
    setState(() => loading = true);
    final result = await AuthService.login(email.text.trim(), password.text);
    setState(() => loading = false);

    if (result["success"] == true) {
      final prefs = await SharedPreferences.getInstance();
      if (result.containsKey('userId')) await prefs.setString('userId', result['userId']);
      Navigator.pushReplacementNamed(context, "/dashboard");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result["message"] ?? "Login failed")));
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Careerise", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loading ? null : handleLogin, child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Login")),
            TextButton(onPressed: () => Navigator.pushNamed(context, "/signup"), child: const Text("Create Account")),
            TextButton(onPressed: () => Navigator.pushNamed(context, "/forgot"), child: const Text("Forgot Password?")),
          ],
        ),
      ),
    );
  }
}

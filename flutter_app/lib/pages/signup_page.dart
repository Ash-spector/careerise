import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  bool isValidEmail(String email) {
    return RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(email);
  }

  Future<void> doSignup() async {
    if (!isValidEmail(emailCtrl.text.trim())) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter a valid email")));
      return;
    }

    setState(() => loading = true);
    try {
      final res = await AuthService.signup(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', res['userId']);
      await prefs.setString('userName', res['name'] ?? '');

      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
        arguments: {
          'email': emailCtrl.text.trim(),
          'skillScore': 0,
          'completion': 0,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Create account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 8),

            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),

            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),

            ElevatedButton(
                onPressed: loading ? null : doSignup,
                child: loading ? const CircularProgressIndicator() : const Text('Sign up')),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Already have an account? Login'))
          ]),
        ),
      ),
    );
  }
}

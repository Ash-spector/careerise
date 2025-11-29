// lib/pages/reset_password_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool loading = false;
  String email = "";
  String otp = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    email = args['email'] ?? '';
    otp = args['otp'] ?? '';
  }

  Future<void> resetPassword() async {
    final newPass = newPassCtrl.text.trim();
    final confirmPass = confirmCtrl.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All fields required")));
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => loading = true);
    final ok = await AuthService.resetPassword(email, otp, newPass);
    setState(() => loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset successful! Please login.")));
      Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset failed")));
    }
  }

  @override
  void dispose() {
    newPassCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password"), backgroundColor: Colors.black),
      backgroundColor: const Color(0xFF0B0C10),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Reset password for:\n$email", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),
              TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "New Password", filled: true, fillColor: Color(0xFF141821)), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              TextField(controller: confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Confirm Password", filled: true, fillColor: Color(0xFF141821)), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: loading ? null : resetPassword, child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Reset Password")),
            ],
          ),
        ),
      ),
    );
  }
}

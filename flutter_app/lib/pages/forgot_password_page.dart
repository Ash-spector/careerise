import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailCtrl = TextEditingController();
  bool loading = false;

  void sendOtp() async {
    setState(() => loading = true);
    final ok = await AuthService.sendOtp(emailCtrl.text.trim());
    setState(() => loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP sent successfully")));
      Navigator.pushNamed(context, '/verify-otp', arguments: {'email': emailCtrl.text.trim(), 'from': 'forgot'});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Forgot Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loading ? null : sendOtp, child: loading ? const CircularProgressIndicator() : const Text("Send OTP")),
          ]),
        ),
      ),
    );
  }
}

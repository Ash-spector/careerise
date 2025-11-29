import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  final String from;
  const OtpVerifyPage({super.key, required this.email, this.from = 'forgot'});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final otpCtrl = TextEditingController();
  bool loading = false;

  void verifyOtp() async {
    setState(() => loading = true);
    final ok = await AuthService.verifyOtp(widget.email, otpCtrl.text.trim());
    setState(() => loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP verified")));
      Navigator.pushReplacementNamed(context, '/reset-password', arguments: {'email': widget.email});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP verification failed")));
    }
  }

  @override
  void dispose() {
    otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("OTP will be sent to: ${widget.email}"),
            const SizedBox(height: 12),
            TextField(controller: otpCtrl, decoration: const InputDecoration(labelText: "Enter OTP")),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loading ? null : verifyOtp, child: loading ? const CircularProgressIndicator() : const Text("Verify OTP")),
          ]),
        ),
      ),
    );
  }
}

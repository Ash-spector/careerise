import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  static String _base() {
    try {
      return ApiConfig.baseApi;
    } catch (_) {
      return "http://10.0.2.2:8000";
    }
  }

  // ✅ LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("${_base()}/auth/login");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed: ${res.statusCode} ${res.body}');
  }

  // ✅ SIGNUP
  static Future<Map<String, dynamic>> signup(
      String name, String email, String password) async {
    final url = Uri.parse("${_base()}/auth/signup");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Signup failed: ${res.statusCode} ${res.body}');
  }

  // ✅ SEND OTP
  static Future<bool> sendOtp(String email) async {
    final url = Uri.parse("${_base()}/auth/send-otp");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        if (data["success"] == true) return true;
        if (data["status"] == "OTP sent") return true;
        if (data["status"] == "ok") return true;
      }
    }

    return false;
  }

  // ✅ VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse("${_base()}/auth/verify-otp");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Verify OTP failed: ${res.statusCode} ${res.body}');
  }

  // ✅ RESET PASSWORD (new)
  static Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    final url = Uri.parse("${_base()}/auth/reset-password");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception('Reset password failed: ${res.statusCode} ${res.body}');
  }
}

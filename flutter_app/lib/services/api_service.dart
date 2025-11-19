// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  static String _base() {
    try {
      return ApiConfig.baseApi;
    } catch (_) {
      return "http://10.0.2.2:8000"; // fallback for Android emulator
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
      return jsonDecode(res.body);
    }
    throw Exception('Login failed: ${res.statusCode} ${res.body}');
  }

  // ✅ SIGNUP
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final url = Uri.parse("${_base()}/auth/signup");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw Exception('Signup failed: ${res.statusCode} ${res.body}');
  }

  // ✅ SEND OTP (Forgot Password)
  static Future<bool> sendOtp(String email) async {
    final url = Uri.parse("${_base()}/auth/send-otp");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data["success"] == true;
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
      return jsonDecode(res.body);
    }
    throw Exception('Verify OTP failed: ${res.statusCode} ${res.body}');
  }

  // ✅ Optional Password Reset (if implemented)
  static Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    final url = Uri.parse("${_base()}/auth/reset-password");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp, 'new_password': newPassword}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw Exception('Reset password failed: ${res.statusCode} ${res.body}');
  }
}

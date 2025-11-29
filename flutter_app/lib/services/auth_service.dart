import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  static String get _base => ApiConfig.baseApi;
  static Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // Signup returns Map with success bool & message (consistent)
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse("$_base/auth/signup"),
      headers: _headers,
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return {"success": true, ...body};
    }
    return {"success": false, "message": body["detail"] ?? body["message"] ?? "Signup failed"};
  }

  // Login returns map {success: bool, ...}
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$_base/auth/login"),
      headers: _headers,
      body: jsonEncode({"email": email, "password": password}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return {"success": true, ...body};
    return {"success": false, "message": body["detail"] ?? body["message"] ?? "Login failed"};
  }

  // sendOtp must return bool (so `if (ok)` works)
  static Future<bool> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$_base/auth/send-otp"),
      headers: _headers,
      body: jsonEncode({"email": email}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      return body["success"] == true;
    }
    return false;
  }

  // verifyOtp returns bool
  static Future<bool> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$_base/auth/verify-otp"),
      headers: _headers,
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return res.statusCode == 200;
  }

  // resetPassword returns bool
  static Future<bool> resetPassword(String email, String otp, String newPassword) async {
    final res = await http.post(
      Uri.parse("$_base/auth/reset-password"),
      headers: _headers,
      body: jsonEncode({"email": email, "otp": otp, "new_password": newPassword}),
    );
    return res.statusCode == 200;
  }
}

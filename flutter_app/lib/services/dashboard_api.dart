// lib/services/dashboard_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DashboardApi {
  // GET profile/dashboard by userId
  static Future<Map<String, dynamic>?> getDashboard({required String userId}) async {
    final url = Uri.parse(ApiConfig.profileGet(userId));
    final res = await http.get(url);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } else if (res.statusCode == 404) {
      return {};
    } else {
      throw Exception('Failed to load dashboard: ${res.statusCode}');
    }
  }

  // upload resume (multipart). For web pass bytes via other helper; this is for path.
  static Future<Map<String, dynamic>> uploadResume({required String userId, required String filePath, List<int>? bytes}) async {
    final uri = Uri.parse(ApiConfig.resumeUpload(userId));
    final request = http.MultipartRequest('POST', uri);
    if (bytes != null) {
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'resume.pdf'));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      return jsonDecode(body) as Map<String, dynamic>;
    } else {
      throw Exception('Resume upload failed: ${streamed.statusCode} $body');
    }
  }

  // POST create/update profile
  static Future<Map<String, dynamic>> createProfile(Map<String, dynamic> payload) async {
    final url = Uri.parse(ApiConfig.profileSave);
    final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
    if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Create profile failed: ${res.statusCode}: ${res.body}');
  }

  // GET career recommendations
  static Future<List<dynamic>> getCareerInsights({required String userId}) async {
    final url = Uri.parse(ApiConfig.recommendCareers(userId));
    final res = await http.get(url);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      // support both map with key or a list
      if (decoded is Map && decoded['recommendedCareers'] != null) return decoded['recommendedCareers'] as List<dynamic>;
      if (decoded is List) return decoded;
      return [];
    }
    throw Exception('Career insights failed: ${res.statusCode}');
  }

  // GET exams (returns Map-like body)
  static Future<Map<String, dynamic>> getExams({required String userId}) async {
    final url = Uri.parse(ApiConfig.recommendExams(userId));
    final res = await http.get(url);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    }
    throw Exception('Get exams failed: ${res.statusCode}');
  }
}

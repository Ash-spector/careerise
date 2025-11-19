import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ProfileApi {
  // ✅ Get full profile
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final url = ApiConfig.profileGet(userId);
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print("⚠️ getProfile failed: ${res.statusCode}");
        return {};
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      return {};
    }
  }

  // ✅ Save (create/update) profile
  static Future<bool> saveProfile(Map<String, dynamic> data) async {
    try {
      final url = ApiConfig.profileSave;
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        print("⚠️ saveProfile failed: ${res.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error saving profile: $e");
      return false;
    }
  }

  // ✅ Upload resume (support bytes or file path)
  static Future<Map<String, dynamic>> uploadResume(
      String userId, String filePath,
      {List<int>? bytes}) async {
    try {
      final url = ApiConfig.resumeUpload(userId);
      var request = http.MultipartRequest("POST", Uri.parse(url));

      if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes("file", bytes,
            filename: "resume.pdf"));
      } else {
        request.files
            .add(await http.MultipartFile.fromPath("file", filePath));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(respStr);
      } else {
        print("⚠️ Resume upload failed: ${response.statusCode}");
        throw Exception("Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error uploading resume: $e");
      rethrow;
    }
  }

  // ✅ Fetch career recommendations
  static Future<List<dynamic>> getCareerInsights(String userId) async {
    try {
      final url = ApiConfig.recommendCareers(userId);
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print("⚠️ Career insights failed: ${res.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching career insights: $e");
      return [];
    }
  }

// ✅ Fetch exam recommendations (Govt + Private + Internship)
static Future<Map<String, dynamic>> getExamInsights(String userId) async {
  try {
    final url = ApiConfig.recommendExams(userId);
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      // If backend accidentally returns a list, convert to map
      if (decoded is List) {
        return {"recommended_exams": decoded};
      }

      return decoded;
    } else {
      print("⚠️ Exam insights failed: ${res.statusCode}");
      return {};
    }
  } catch (e) {
    print("❌ Error fetching exam insights: $e");
    return {};
  }
}
}
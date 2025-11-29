// lib/config/api_config.dart
class ApiConfig {
  // Use your Render URL here
  static const String baseApi = "https://careerise-1.onrender.com";

  static String profileGet(String userId) => "$baseApi/profile/$userId";
  static String get profileSave => "$baseApi/profile/save";
  static String resumeUpload(String userId) => "$baseApi/resume/upload/$userId";
  static String recommendCareers(String userId) => "$baseApi/recommend/careers/$userId";
  static String recommendExams(String userId) => "$baseApi/recommend/exams/$userId";
}

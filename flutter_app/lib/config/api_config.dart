// lib/config/api_config.dart
class ApiConfig {
  static const String baseApi = "http://10.0.2.2:8000";

  static String profileGet(String userId) => "$baseApi/profile/$userId";
  static String get profileSave => "$baseApi/profile/save";
  static String resumeUpload(String userId) => "$baseApi/resume/upload/$userId";

  static String recommendCareers(String userId) =>
      "$baseApi/recommend/careers/$userId";

  // canonical exams endpoint
  static String recommendExams(String userId) =>
      "$baseApi/exams/$userId";
}

class ApiConfig {
  // Update these to match your backend hosts & ports
  static const String auth = 'http://127.0.0.1:5000'; // backend-auth
  static const String ml = 'http://127.0.0.1:8000';   // backend-ml

  // Full endpoints helpers
  static String login() => '$auth/auth/login';
  static String register() => '$auth/auth/register';
  static String profile() => '$auth/auth/profile';

  static String uploadResume() => '$ml/ml/upload-resume';
  static String skills() => '$ml/ml/skills';
  static String recommendations() => '$ml/ml/recommendations';
  static String exams() => '$ml/ml/exams';
}

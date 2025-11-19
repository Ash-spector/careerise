// lib/models/profile_model.dart
class ProfileModel {
  final String userId;
  final String name;
  final String email;
  final List<Map<String, dynamic>> skills; // {name, type, level}
  final Map<String, dynamic> academic; // {level, field, gpa, achievements: []}
  final List<Map<String, dynamic>> interests; // {name, level}
  final Map<String, dynamic> preferences; // {workEnvironment, arrangement, companySize}
  final int profileCompletion; // 0-100
  final Map<String, dynamic>? resumeInfo; // returned by resume upload (if any)

  ProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.skills,
    required this.academic,
    required this.interests,
    required this.preferences,
    required this.profileCompletion,
    this.resumeInfo,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      academic: json['academic'] != null
          ? Map<String, dynamic>.from(json['academic'])
          : {
              'level': '',
              'field': '',
              'gpa': null,
              'achievements': <String>[],
            },
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'])
          : {
              'workEnvironment': '',
              'arrangement': '',
              'companySize': '',
            },
      profileCompletion: json['profileCompletion'] is int
          ? json['profileCompletion']
          : (json['profile_completion'] is int
              ? json['profile_completion']
              : 0),
      resumeInfo: json['resumeInfo'] != null
          ? Map<String, dynamic>.from(json['resumeInfo'])
          : (json['resume_info'] != null
              ? Map<String, dynamic>.from(json['resume_info'])
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'skills': skills,
      'academic': academic,
      'interests': interests,
      'preferences': preferences,
      'profileCompletion': profileCompletion,
      'resumeInfo': resumeInfo,
    };
  }
}

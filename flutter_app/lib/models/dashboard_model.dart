class DashboardModel {
  final String userName;
  final String email;
  final int profileCompletion;
  final int skillsAdded;
  final int careerMatches;
  final int growthScore;

  DashboardModel({
    required this.userName,
    required this.email,
    required this.profileCompletion,
    required this.skillsAdded,
    required this.careerMatches,
    required this.growthScore,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      userName: json['name'] ?? "User",
      email: json['email'] ?? "",
      profileCompletion: json['profile_completion'] ?? 0,
      skillsAdded: json['skills_count'] ?? 0,
      careerMatches: json['career_matches'] ?? 0,
      growthScore: json['growth_score'] ?? 0,
    );
  }
}

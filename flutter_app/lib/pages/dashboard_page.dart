// lib/pages/dashboard_page.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/profile_api.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  XFile? profileImage;

  // profile fields
  String userEmail = "careerise@user.com";
  String userName = "User";
  int skillScore = 0;
  int completion = 0;
  int skillsAdded = 0;
  int careerMatches = 0;
  int growthScore = 0;
  int learningStreakDays = 0;

  Map<String, dynamic> _profile = {};

  // Lottie
  late final AnimationController _lottieController;
  double _lottieTarget = 0.0;
  bool _lottieReady = false;

  double _tilt = 0.0;

  @override
  void initState() {
    super.initState();
    _lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _loadAllData();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  // ---------------- LOAD DATA -----------------
  Future<void> _loadAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? "";

      // fallback local stored values
      userEmail = prefs.getString('email') ?? userEmail;
      userName = prefs.getString('name') ?? userName;

      if (userId.isEmpty) {
        setState(() {});
        return;
      }

      // fetch backend profile
      final profile = await ProfileApi.getProfile(userId);

      if (profile.containsKey('profile')) {
        _profile = Map<String, dynamic>.from(profile['profile']);
      } else {
        _profile = Map<String, dynamic>.from(profile);
      }

      userName = (_profile['name'] ?? userName).toString();
      userEmail = (_profile['email'] ?? userEmail).toString();

      final resumeSkills = List<String>.from(
        (_profile['resumeInfo']?['skills'] ?? []).map((e) => e.toString()),
      );

      // manual skills
      final manualSkills = <String>[];
      for (final s in (_profile['skills'] ?? [])) {
        if (s is Map && s.containsKey('name')) {
          manualSkills.add(s['name']);
        }
      }

      skillsAdded = resumeSkills.length + manualSkills.length;

      // career insights
      try {
        final careers = await ProfileApi.getCareerInsights(userId);
        careerMatches = careers.length;
      } catch (_) {
        careerMatches = 0;
      }

      final academicLevel =
          (_profile['academic']?['level'] ?? '').toString().toLowerCase();

      final academicWeight = _academicWeight(academicLevel);
      final resumeScore = resumeSkills.length * 3;
      final manualScore = manualSkills.length * 2;

      skillScore =
          (resumeScore + manualScore + academicWeight).clamp(0, 100).toInt();

      completion = (_profile['profileCompletion'] ?? 40).clamp(0, 100);

      // growth score
      growthScore =
          ((skillScore * 0.6) + (completion * 0.4)).toInt().clamp(0, 100);

      learningStreakDays =
          (_profile['learningStreakDays'] as int?) ?? Random().nextInt(10);

      _lottieTarget = (skillScore / 100).clamp(0.0, 1.0);

      if (_lottieReady) {
        _lottieController.animateTo(_lottieTarget,
            curve: Curves.easeOutCubic);
      }

      setState(() {});
    } catch (e) {
      debugPrint("Load error: $e");
    }
  }

  int _academicWeight(String level) {
    switch (level) {
      case "phd":
        return 25;
      case "masters":
        return 20;
      case "graduation":
        return 15;
      case "diploma":
        return 10;
      case "12th":
        return 5;
      default:
        return 8;
    }
  }

  // ---------------- IMAGE PICKER -----------------
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => profileImage = img);
    }
  }

  // ---------------- LEARN MORE DIALOG -----------------
  void _openLearnMoreDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF121428),
        title: const Text("Learn More",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "🎯 Careerise - AI-powered career recommendation system.\n\n"
          "Developed by: Aniket Shukla\n"
          "📧 Email: shuklaaniket712@gmail.com\n"
          "🌐 Portfolio: aniketshukla.vercel.app\n\n"
          "This app analyzes resumes, skills, and interests "
          "to generate personalized career insights, exam eligibility, "
          "and skill growth recommendations.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final url = Uri.parse("https://aniketshukla.vercel.app");
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            child: const Text("Visit Portfolio",
                style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ---------------- DESCRIPTION -----------------
  String _describeScore(int s) {
    if (s >= 85) return "Excellent — strong skill coverage for jobs.";
    if (s >= 65) return "Good — add a few more projects.";
    if (s >= 40) return "Fair — add more skills & projects.";
    return "Low — add skills & upload resume.";
  }

  // ---------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F18),
      appBar: AppBar(
        title:
            const Text("Home Page", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: _openLearnMoreDialog,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: const Color(0xFF7B3EFF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeCard(),
              const SizedBox(height: 20),
              _progressCard(),
              const SizedBox(height: 20),
              _actionButtons(),
              const SizedBox(height: 20),
              _skillScoreCard(),
              const SizedBox(height: 20),
              _statsGrid(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- WELCOME CARD -----------------
  Widget _welcomeCard() {
    ImageProvider<Object> imgProvider =
        profileImage != null
            ? FileImage(File(profileImage!.path)) as ImageProvider<Object>
            : const AssetImage("assets/profile.png") as ImageProvider<Object>;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _neonBox,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundImage: imgProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: pickImage,
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 13, color: Colors.black),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, $userName 👋",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Let's shape your future career 🚀",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PROGRESS CARD -----------------
  Widget _progressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardBox,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Profile Completion",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 12,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF7B3EFF)),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$completion%",
                  style: const TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/profile"),
                child: const Text("Complete Profile"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ACTION BUTTONS -----------------
  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: _glowButton(
            "Career Insights",
            const Color(0xFF7B3EFF),
            () => Navigator.pushNamed(context, "/career"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _glowButton(
            "Exams & Opportunities",
            const Color(0xFF4AA8E0),
            () => Navigator.pushNamed(context, "/exams"),
          ),
        ),
      ],
    );
  }

  Widget _glowButton(String title, Color color, VoidCallback tap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: tap,
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ---------------- SKILL SCORE CARD -----------------
  Widget _skillScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A103D), Color(0xFF4C2EFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B3EFF).withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Skill Score",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    setState(() {
                      _tilt += d.delta.dx * 0.002;
                      _tilt = _tilt.clamp(-0.18, 0.18);
                    });
                  },
                  onHorizontalDragEnd: (_) =>
                      setState(() => _tilt = 0.0),

                  child: Transform.rotate(
                    angle: _tilt,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Lottie.asset(
                          "assets/animations/score_dial.json",
                          controller: _lottieController,
                          onLoaded: (c) {
                            _lottieController.duration = c.duration;
                            _lottieReady = true;
                            _lottieController.animateTo(
                              _lottieTarget,
                              curve: Curves.easeOutCubic,
                            );
                          },
                          repeat: false,
                        ),

                        Text(
                          "$skillScore%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Skill Strength",
                      style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _describeScore(skillScore),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- STATS GRID -----------------
  Widget _statsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        _gridBox("🧠 Skills Added", skillsAdded.toString()),
        _gridBox("🎯 Career Matches", careerMatches.toString()),
        _gridBox("🔥 Growth Score", "$growthScore%"),
        _gridBox("📅 Learning Streak", learningStreakDays.toString()),
      ],
    );
  }

  Widget _gridBox(String title, String value) {
    return Container(
      decoration: _cardBox,
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------- DECORATIONS -----------------
  BoxDecoration get _neonBox => BoxDecoration(
        color: const Color(0xFF13172B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      );

  BoxDecoration get _cardBox => BoxDecoration(
        color: const Color(0xFF111428),
        borderRadius: BorderRadius.circular(12),
      );
}

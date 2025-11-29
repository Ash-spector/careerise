// lib/pages/exams_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  bool loading = true;
  bool profileIncomplete = false;

  List<dynamic> exams = [];

  @override
  void initState() {
    super.initState();
    fetchExams();
  }

  Future<void> fetchExams() async {
    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId") ?? "";

      final url = ApiConfig.recommendExams(userId);
      final res = await http.get(Uri.parse(url));

      print("📌 RAW EXAM RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        profileIncomplete = data["profile_incomplete"] ?? false;

        exams = data["recommended_exams"] ?? [];
      }
    } catch (e) {
      debugPrint("Exam fetch error: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: const Text("Exam & Internship Recommendations"),
        backgroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : exams.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: fetchExams,
                  color: Colors.purple,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exams.length,
                    itemBuilder: (ctx, i) {
                      return _examCard(exams[i]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              profileIncomplete
                  ? "Profile Not Complete"
                  : "No Recommendations Yet",
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              profileIncomplete
                  ? "Add more skills or upload your resume for better recommendations."
                  : "Try updating your skills for personalised exam suggestions.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/profile"),
              child: const Text("Update Profile"),
            )
          ],
        ),
      ),
    );
  }

  Widget _examCard(Map<String, dynamic> exam) {
    return Card(
      color: const Color(0xFF131722),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam["title"] ?? "Exam",
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "${exam["eligibility_score"]}% match",
              style: const TextStyle(color: Colors.greenAccent),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _openApply(exam["apply_link"] ?? ""),
                  child: const Text("Apply Now"),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showDetails(exam),
                  child: const Text("More Info"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openApply(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No application link available")),
      );
      return;
    }

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cannot open link")));
    }
  }

  void _showDetails(Map<String, dynamic> exam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF10131A),
        title: Text(
          exam["title"] ?? "Exam",
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          "Match Score: ${exam["eligibility_score"]}%\n\nThis exam matches your education and skills.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }
}
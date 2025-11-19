import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_api.dart';

class CareerInsightsPage extends StatefulWidget {
  const CareerInsightsPage({super.key});

  @override
  State<CareerInsightsPage> createState() => _CareerInsightsPageState();
}

class _CareerInsightsPageState extends State<CareerInsightsPage> {
  bool loading = true;
  List<dynamic> careers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      careers = await ProfileApi.getCareerInsights(userId);
    } catch (e) {
      careers = [];
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: const Text("Career Insights"),
        backgroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (careers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("No recommendations yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text(
              "Upload your resume or add skills to generate AI-based matches.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/profile"),
              child: const Text("Complete Profile"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: careers.length,
      itemBuilder: (ctx, i) => _careerCard(careers[i]),
    );
  }

  // ---------------------------------------------------------
  // Career Card UI
  // ---------------------------------------------------------
  Widget _careerCard(Map<String, dynamic> c) {
    final role = c["role"];
    final score = c["matchingScore"];
    final level = c["study_level"];
    final skills = (c["skillsRequired"] as List).cast<String>();
    final roadmap = c["roadmap"];
    final course = c["course_link"];
    final playlist = c["playlist_link"];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF11161F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            Text("$score% match",
                style: const TextStyle(color: Colors.greenAccent))
          ],
        ),

        const SizedBox(height: 8),

        // Study Level Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text("Level: $level",
              style: const TextStyle(color: Colors.blueAccent)),
        ),

        const SizedBox(height: 12),

        // Skills required
        Wrap(
          spacing: 7,
          children: skills
              .map((s) =>
                  Chip(label: Text(s), backgroundColor: Colors.blueGrey))
              .toList(),
        ),

        const SizedBox(height: 12),

        // Roadmap preview
        Text(roadmap,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70)),

        const SizedBox(height: 12),

        // Buttons
        Row(children: [
          ElevatedButton(
              onPressed: () => _openLink(course),
              child: const Text("Course")),
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: () => _openLink(playlist),
              child: const Text("Playlist")),
        ])
      ]),
    );
  }

  void _openLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Error opening link");
    }
  }
}

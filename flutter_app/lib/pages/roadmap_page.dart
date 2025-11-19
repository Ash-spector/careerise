import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RoadmapPage extends StatelessWidget {
  final String role;
  final String roadmap;

  const RoadmapPage({
    super.key,
    required this.role,
    required this.roadmap,
  });

  // Open links
  void openURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("$role Roadmap"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _sectionTitle("🌟 Overview"),
            _sectionCard(Text(
              roadmap,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            )),

            const SizedBox(height: 20),

            _sectionTitle("📘 Step-by-Step Roadmap"),
            _sectionCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _step("Step 1: Learn the Basics", [
                    "Understand fundamentals",
                    "Get familiar with key concepts",
                  ]),
                  _step("Step 2: Practice Real Projects", [
                    "Build 2–3 small projects",
                    "Learn debugging and testing",
                  ]),
                  _step("Step 3: Advanced Concepts", [
                    "Master tools and frameworks",
                    "Build portfolio-ready projects",
                  ]),
                  _step("Step 4: Build Resume & Apply", [
                    "Create projects on GitHub",
                    "Apply for internships/jobs",
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("🛠 Skills to Master"),
            _sectionCard(Wrap(
              spacing: 8,
              children: [
                _chip("Python"),
                _chip("SQL"),
                _chip("Machine Learning"),
                _chip("Power BI"),
                _chip("Data Visualization"),
                _chip("Statistics"),
              ],
            )),

            const SizedBox(height: 20),

            _sectionTitle("📚 Recommended Courses"),
            _sectionCard(
              Column(
                children: [
                  _courseTile(
                      "Data Analyst Course – Google",
                      "https://www.coursera.org/professional-certificates/google-data-analytics"),
                  _courseTile(
                      "SQL for Beginners – Udemy",
                      "https://www.udemy.com/course/the-complete-sql-bootcamp"),
                  _courseTile(
                      "Power BI Training – Microsoft",
                      "https://learn.microsoft.com/en-us/training/powerplatform/power-bi"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("▶ YouTube Playlists"),
            _sectionCard(
              Column(
                children: [
                  _ytTile("Data Analyst Roadmap", "https://youtu.be/uqR-hGm8qw8"),
                  _ytTile("SQL Full Course", "https://youtu.be/hlGoQC332VM"),
                  _ytTile("Power BI Full Course", "https://youtu.be/AGrl-H87pRU"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("📅 12-Week Timeline"),
            _sectionCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _timeline("Week 1–2", "Basics of tools & languages"),
                  _timeline("Week 3–4", "Hands-on mini projects"),
                  _timeline("Week 5–8", "Advanced topics + portfolio"),
                  _timeline("Week 9–12", "Internship/job preparation"),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // UI Components
  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _sectionCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF11161F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _step(String title, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...points.map((p) => Row(
                children: [
                  const Text("• ", style: TextStyle(color: Colors.white70)),
                  Expanded(
                      child: Text(p,
                          style: const TextStyle(
                              color: Colors.white70, height: 1.4))),
                ],
              ))
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.deepPurple.shade400.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  Widget _courseTile(String title, String url) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.open_in_new, color: Colors.white70),
      onTap: () => openURL(url),
    );
  }

  Widget _ytTile(String title, String url) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      leading: const Icon(Icons.play_circle_fill, color: Colors.redAccent),
      onTap: () => openURL(url),
    );
  }

  Widget _timeline(String period, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(period,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(desc,
                style: const TextStyle(color: Colors.white70, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

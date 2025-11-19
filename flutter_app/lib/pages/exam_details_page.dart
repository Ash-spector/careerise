// lib/pages/exam_details_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ExamDetailsPage extends StatefulWidget {
  const ExamDetailsPage({super.key});

  @override
  State<ExamDetailsPage> createState() => _ExamDetailsPageState();
}

class _ExamDetailsPageState extends State<ExamDetailsPage> {
  Map<String, dynamic> exam = {};
  bool saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      exam = Map<String, dynamic>.from(args);
      _checkSaved();
    }
  }

  Future<void> _checkSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('savedExams') ?? [];
    saved = list.contains(jsonEncode(exam));
    if (mounted) setState(() {});
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'savedExams';
    final list = prefs.getStringList(key) ?? [];
    final encoded = jsonEncode(exam);

    if (list.contains(encoded)) {
      list.remove(encoded);
      saved = false;
    } else {
      list.add(encoded);
      saved = true;
    }
    await prefs.setStringList(key, list);
    if (mounted) setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(saved ? "Saved to your list" : "Removed from saved")),
    );
  }

  Future<void> _applyNow() async {
    final link = (exam['apply_link'] ?? exam['link'] ?? exam['url'] ?? "").toString();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No apply link provided.")));
      return;
    }

    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open link.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = exam['title'] ?? exam['name'] ?? 'Exam/Opportunity';
    final eligibility = exam['eligibility'] ?? exam['requirements'] ?? 'Not specified';
    final details = exam['details'] ?? exam['notes'] ?? '';
    final type = (exam['type'] ?? 'Other').toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
            onPressed: _toggleSave,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0F1320), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(type.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(onPressed: _applyNow, icon: const Icon(Icons.open_in_new), label: const Text("Apply Now"))
              ]),
              const SizedBox(height: 12),
              const Text("Eligibility:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(eligibility, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              if (details.isNotEmpty) ...[
                const Text("Details & Syllabus:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(details, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
              ],
              const Text("How to prepare:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                _generatePrepTips(eligibility, details, exam),
                style: const TextStyle(color: Colors.white70),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _applyNow,
            icon: const Icon(Icons.open_in_new),
            label: const Text("Open Apply Link"),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _toggleSave,
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
            label: Text(saved ? "Saved" : "Save for later"),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }

  String _generatePrepTips(String eligibility, String details, Map<String, dynamic> exam) {
    // lightweight heuristic tips generator
    final buffer = StringBuffer();
    buffer.write("• Review the core topics mentioned in eligibility.\n");
    if (eligibility.toLowerCase().contains("program") || eligibility.toLowerCase().contains("coding")) {
      buffer.write("• Practice coding (DSA, algorithms) and aptitude problems.\n");
    }
    if (eligibility.toLowerCase().contains("data") || eligibility.toLowerCase().contains("python")) {
      buffer.write("• Strengthen Python, SQL and data handling skills. Build 1-2 projects.\n");
    }
    if (details.isNotEmpty) {
      buffer.write("• Focus on syllabus sections: ${details.length > 200 ? "${details.substring(0, 200)}..." : details}\n");
    }
    buffer.write("• Use official study materials & mock tests. Apply early for best chances.");
    return buffer.toString();
  }
}

// lib/widgets/resume_upload_widget.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_api.dart';
// ✅ Make sure this import is added

class ResumeUploadWidget extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onUploaded;
  const ResumeUploadWidget({super.key, this.onUploaded});

  @override
  State<ResumeUploadWidget> createState() => _ResumeUploadWidgetState();
}

class _ResumeUploadWidgetState extends State<ResumeUploadWidget> {
  bool uploading = false;
  Map<String, dynamic>? resumeInfo;

  Future<void> pickAndUpload() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );
    if (res == null) return;

    final file = res.files.single;
    setState(() => uploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      Map<String, dynamic> resp;
      if (file.bytes != null) {
        resp = await ProfileApi.uploadResume(userId, '', bytes: file.bytes);
      } else {
        resp = await ProfileApi.uploadResume(userId, file.path!);
      }

      setState(() => resumeInfo = resp['resume_info'] ?? resp);
      widget.onUploaded?.call(resumeInfo!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Resume uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload failed: $e')),
      );
    } finally {
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const Icon(Icons.upload_file, size: 36, color: Colors.green),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Upload your resume (PDF/DOCX). AI will extract skills & education.',
                ),
              ),
              ElevatedButton(
                onPressed: uploading ? null : pickAndUpload,
                child: uploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Upload'),
              )
            ]),
          ),
        ),
        if (resumeInfo != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Extracted Information',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Name: ${resumeInfo?['name'] ?? ''}'),
                  Text('Email: ${resumeInfo?['email'] ?? ''}'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: ((resumeInfo?['skills'] as List<dynamic>?) ?? [])
                        .map((s) => Chip(label: Text(s.toString())))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

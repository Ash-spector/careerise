// lib/pages/profile_builder_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/resume_upload_widget.dart';
import '../services/profile_api.dart';

class ProfileBuilderPage extends StatefulWidget {
  const ProfileBuilderPage({super.key});
  @override
  State<ProfileBuilderPage> createState() => _ProfileBuilderPageState();
}

class _ProfileBuilderPageState extends State<ProfileBuilderPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool loading = true;

  String userId = "";
  Map<String, dynamic> profile = {};

  List<Map<String, dynamic>> skills = [];
  Map<String, dynamic> academic = {
    'level': '',
    'field': '',
    'gpa': '',
    'achievements': <dynamic>[]
  };

  List<Map<String, dynamic>> interests = [];
  Map<String, dynamic> preferences = {
    'workEnvironment': '',
    'arrangement': '',
    'companySize': ''
  };

  Map<String, dynamic>? resumeInfo;

  final List<String> tabTitles = [
    "Resume",
    "Skills",
    "Academic",
    "Interests",
    "Preferences"
  ];

  final List<IconData> tabIcons = [
    Icons.picture_as_pdf,
    Icons.bolt,
    Icons.school,
    Icons.favorite,
    Icons.tune,
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabTitles.length, vsync: this);
    // Ensure UI updates when user swipes between tabs
    tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? "";

    try {
      final data = await ProfileApi.getProfile(userId);
      if (data.isNotEmpty) {
        profile = Map<String, dynamic>.from(data);
        skills = List<Map<String, dynamic>>.from(data['skills'] ?? []);
        academic = {
          'level': (data['academic']?['level'] ?? '').toString(),
          'field': (data['academic']?['field'] ?? '').toString(),
          'gpa': (data['academic']?['gpa'] ?? '').toString(),
          'achievements':
              List.from(data['academic']?['achievements'] ?? <dynamic>[])
        };
        interests = List<Map<String, dynamic>>.from(data['interests'] ?? []);
        preferences = {
          'workEnvironment':
              (data['preferences']?['workEnvironment'] ?? '').toString(),
          'arrangement': (data['preferences']?['arrangement'] ?? '').toString(),
          'companySize': (data['preferences']?['companySize'] ?? '').toString(),
        };
        resumeInfo = data['resumeInfo'] ?? data['resume_info'];
      }
    } catch (e) {
      // ignore load errors for now
    } finally {
      setState(() => loading = false);
    }
  }

  int computeCompletion() {
    int score = 0;
    if (resumeInfo != null) score += 25;
    if (skills.isNotEmpty) score += 25;
    if ((academic['level'] ?? '').toString().isNotEmpty) score += 20;
    if (interests.isNotEmpty) score += 15;
    if ((preferences['workEnvironment'] ?? '').toString().isNotEmpty) {
      score += 15;
    }
    if (score > 100) score = 100;
    return score;
  }

Future<void> saveProfile() async {
  final payload = {
    'userId': userId,
    'name': profile['name'] ?? '',
    'email': profile['email'] ?? '',
    'skills': skills,
    'academic': academic,
    'interests': interests,
    'preferences': preferences,
    'resumeInfo': resumeInfo ?? {},
    'profileCompletion': computeCompletion(),
  };

  try {
    final ok = await ProfileApi.saveProfile(payload);

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile Saved Successfully")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to save profile")),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Error saving profile: $e")),
      );
    }
  }
}


  Future<void> _addSkillDialog() async {
    final nameCtrl = TextEditingController();
    String type = 'Technical', level = 'Intermediate';

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Skill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Skill name')),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                  value: type,
                  items: ['Technical', 'Soft']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => type = v ?? 'Technical'),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                  value: level,
                  items: ['Beginner', 'Intermediate', 'Advanced']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => level = v ?? 'Intermediate'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                setState(() =>
                    skills.add({'name': name, 'type': type, 'level': level}));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  Future<void> _addInterestDialog() async {
    final nameCtrl = TextEditingController();
    int lvl = 4;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Interest'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Interest')),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: lvl,
                items: List.generate(5, (i) => i + 1)
                    .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                    .toList(),
                onChanged: (v) => lvl = v ?? 1,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                setState(() => interests.add({'name': name, 'level': lvl}));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  Future<void> _addAchievementDialog() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Achievement'),
          content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Achievement')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final val = ctrl.text.trim();
                if (val.isEmpty) return;
                setState(
                    () => (academic['achievements'] as List<dynamic>).add(val));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  // Pill tab widget (neon style) with icons
  Widget _pillTabs() {
    final int current = tabController.index;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: List.generate(tabTitles.length, (i) {
          final bool active = i == current;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                tabController.animateTo(i);
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin:
                    EdgeInsets.only(right: i == tabTitles.length - 1 ? 0 : 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF7B3EFF)
                      : const Color(0xFF0F1320),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: const Color(0xFF7B3EFF).withOpacity(0.22),
                              blurRadius: 14,
                              spreadRadius: 1)
                        ]
                      : null,
                  border: Border.all(
                      color: active ? Colors.transparent : Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tabIcons[i],
                        size: 16,
                        color: active ? Colors.white : Colors.white70),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        tabTitles[i],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.white70,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _resumeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ResumeUploadWidget(
              onUploaded: (data) => setState(() => resumeInfo = data)),
          const SizedBox(height: 12),
          if (resumeInfo != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1320),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${(resumeInfo?['name'] ?? '').toString()}",
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text("Email: ${(resumeInfo?['email'] ?? '').toString()}",
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: ((resumeInfo?['skills'] as List?) ?? [])
                          .map((s) => Chip(
                              label: Text(s.toString(),
                                  style: const TextStyle(color: Colors.black)),
                              backgroundColor: Colors.white))
                          .toList(),
                    )
                  ]),
            )
        ],
      ),
    );
  }

  Widget _skillsTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ElevatedButton.icon(
              onPressed: _addSkillDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Skill")),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              // quick preset add
              setState(() => skills.add({
                    'name': 'JavaScript',
                    'type': 'Technical',
                    'level': 'Intermediate'
                  }));
            },
            icon: const Icon(Icons.flash_on),
            label: const Text("Quick Add"),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA8E0)),
          )
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['Python', 'JavaScript', 'Flutter', 'SQL']
              .map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(color: Colors.white)),
                    onPressed: () => setState(() => skills.add({
                          'name': s,
                          'type': 'Technical',
                          'level': 'Intermediate'
                        })),
                    backgroundColor: const Color(0xFF1A1F2E),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        const Text("Your Skills",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Expanded(
          child: skills.isEmpty
              ? const Center(
                  child: Text("No skills added",
                      style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  itemCount: skills.length,
                  itemBuilder: (ctx, i) {
                    final sk = skills[i];
                    return ListTile(
                      tileColor: const Color(0xFF0F1320),
                      title: Text(sk['name'] ?? '',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                          "${sk['type'] ?? ''} · ${sk['level'] ?? ''}",
                          style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => setState(() => skills.removeAt(i))),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _academicTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(
          initialValue: academic['level'] ?? '',
          decoration: inputStyle('Education Level'),
          onChanged: (v) => academic['level'] = v,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: academic['field'] ?? '',
          decoration: inputStyle('Field of Study'),
          onChanged: (v) => academic['field'] = v,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: academic['gpa'] ?? '',
          decoration: inputStyle('GPA'),
          onChanged: (v) => academic['gpa'] = v,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text('Achievements', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
            onPressed: _addAchievementDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Achievement")),
        const SizedBox(height: 12),
        Expanded(
          child: (academic['achievements'] as List).isEmpty
              ? const Center(
                  child: Text('No achievements',
                      style: TextStyle(color: Colors.white54)))
              : ListView(
                  children: (academic['achievements'] as List)
                      .map((a) => ListTile(
                          title: Text(a.toString(),
                              style: const TextStyle(color: Colors.white70))))
                      .toList()),
        )
      ]),
    );
  }

  Widget _interestsTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ElevatedButton.icon(
            onPressed: _addInterestDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Interest")),
        const SizedBox(height: 12),
        Expanded(
          child: interests.isEmpty
              ? const Center(
                  child: Text('No interests added',
                      style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  itemCount: interests.length,
                  itemBuilder: (ctx, i) {
                    final it = interests[i];
                    return ListTile(
                      tileColor: const Color(0xFF0F1320),
                      title: Text(it['name'] ?? '',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text("Level: ${it['level']}",
                          style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () =>
                              setState(() => interests.removeAt(i))),
                    );
                  },
                ),
        )
      ]),
    );
  }

  Widget _preferencesTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownButtonFormField<String>(
          value: preferences['workEnvironment'] == ''
              ? null
              : preferences['workEnvironment'],
          decoration: inputStyle('Preferred Work Environment'),
          dropdownColor: const Color(0xFF0F1320),
          style: const TextStyle(color: Colors.white),
          items: ['Office', 'Remote', 'Hybrid']
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white))))
              .toList(),
          onChanged: (v) =>
              setState(() => preferences['workEnvironment'] = v ?? ''),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: preferences['arrangement'] == ''
              ? null
              : preferences['arrangement'],
          decoration: inputStyle('Working Arrangement'),
          dropdownColor: const Color(0xFF0F1320),
          style: const TextStyle(color: Colors.white),
          items: ['Full-time', 'Part-time', 'Contract', 'Internship']
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white))))
              .toList(),
          onChanged: (v) =>
              setState(() => preferences['arrangement'] = v ?? ''),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: preferences['companySize'] == ''
              ? null
              : preferences['companySize'],
          decoration: inputStyle('Company Size Preference'),
          dropdownColor: const Color(0xFF0F1320),
          style: const TextStyle(color: Colors.white),
          items: ['Startup (1-50)', 'SME (50-500)', 'Large (500+)']
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white))))
              .toList(),
          onChanged: (v) =>
              setState(() => preferences['companySize'] = v ?? ''),
        ),
        const Spacer(),
        Row(children: [
          Expanded(
              child: ElevatedButton(
                  onPressed: saveProfile, child: const Text("Save Profile"))),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              setState(() {
                skills = [];
                academic = {
                  'level': '',
                  'field': '',
                  'gpa': '',
                  'achievements': []
                };
                interests = [];
                preferences = {
                  'workEnvironment': '',
                  'arrangement': '',
                  'companySize': ''
                };
                resumeInfo = null;
              });
            },
            child: const Text("Reset"),
          )
        ])
      ]),
    );
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF1A1F2E),
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7B3EFF), width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final completion = computeCompletion();

    // ✅ Replace your existing Scaffold (where body: is defined) with this:

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Build Your Career Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ✅ Prevent keyboard overflow issues
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ✅ Profile progress section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile Completion",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: completion / 100,
                        minHeight: 10,
                        backgroundColor: Colors.white10,
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF7B3EFF)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$completion%",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // ✅ Neon pill tab selector
              _pillTabs(),

              // ✅ Tab container (scrollable within fixed height)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1320),
                  borderRadius: BorderRadius.circular(14),
                ),
                height: MediaQuery.of(context).size.height * 0.7,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    _resumeTab(),
                    _skillsTab(),
                    _academicTab(),
                    _interestsTab(),
                    _preferencesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.removeListener(() {}); // safe remove
    tabController.dispose();
    super.dispose();
  }
}

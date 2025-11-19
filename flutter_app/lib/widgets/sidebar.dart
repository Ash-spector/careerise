import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/profile_builder_page.dart';
import '../pages/career_insights_page.dart';
import '../pages/exams_page.dart';

class SidebarLayout extends StatefulWidget {
  const SidebarLayout({super.key});

  @override
  State<SidebarLayout> createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Dashboard",
    "Profile Builder",
    "Career Insights",
     "Exams & Internships",
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardPage(),
      const ProfileBuilderPage(),
      const CareerInsightsPage(),
      const ExamsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      // ✅ Drawer sidebar
      drawer: Drawer(
        backgroundColor: const Color(0xFF0D0F18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _drawerHeader(),
            const SizedBox(height: 10),
            _drawerItem(Icons.dashboard, "Dashboard", 0),
            _drawerItem(Icons.person_outline, "Profile Builder", 1),
            _drawerItem(Icons.insights_outlined, "Career Insights", 2),
            _drawerItem(Icons.school_outlined, "Exams & Internships", 3),
            const Spacer(),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => Navigator.pushReplacementNamed(context, "/login"),
            ),
          ],
        ),
      ),

      // ✅ Page content
      body: pages[_selectedIndex],
    );
  }

  Widget _drawerHeader() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          SizedBox(height: 10),
          Text(
            "Careerise",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "AI-Powered Career Platform",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading:
          Icon(icon, color: isSelected ? Colors.blueAccent : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blueAccent : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

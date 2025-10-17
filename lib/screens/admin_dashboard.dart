import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String name;
  final String email;

  const AdminDashboard({super.key, required this.name, required this.email});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final double attendanceRate = 0.92;
  final double teacherActivity = 0.78;
  final double studentParticipation = 0.86;
  final double systemHealth = 0.95;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _pages = [
      _buildHomePage(),
      _placeholderPage('Manage Users', Icons.group, 'Coming soon...'),
      _placeholderPage('Reports', Icons.bar_chart, 'Reports and data visualizations'),
      _settingsPage(),
    ];
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------- MAIN UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
      ),
      drawer: _buildSideDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0.2, 0), end: Offset.zero)
                    .animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: _pages[_selectedIndex],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _controller.reset();
            _controller.forward();
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // ------------------- DRAWER -------------------
  Drawer _buildSideDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D1B2A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings,
                  color: Colors.blueAccent, size: 40),
            ),
            accountName: Text(widget.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail:
                Text(widget.email, style: const TextStyle(color: Colors.white70)),
          ),
          _drawerItem(Icons.home, 'Home', 0),
          _drawerItem(Icons.group, 'Manage Users', 1),
          _drawerItem(Icons.bar_chart, 'Reports', 2),
          _drawerItem(Icons.settings, 'Settings', 3),
          const Divider(color: Colors.white30),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () async {
              bool confirm = await showConfirmationDialog(
                context,
                'Logout',
                'Are you sure you want to logout?',
              );
              if (confirm) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthEntryScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  // ------------------- HOME PAGE -------------------
  Widget _buildHomePage() {
    return SingleChildScrollView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          const Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // 🔵 Animated Circular Indicators
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildCircularIndicator("Attendance", attendanceRate, Colors.greenAccent,
                  Icons.access_time_filled),
              _buildCircularIndicator("Teacher Activity", teacherActivity,
                  Colors.orangeAccent, Icons.person),
              _buildCircularIndicator("Student Participation",
                  studentParticipation, Colors.blueAccent, Icons.school),
              _buildCircularIndicator("System Health", systemHealth,
                  Colors.purpleAccent, Icons.memory),
            ],
          ),
          const SizedBox(height: 40),

          const Text(
            'Quick Actions',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: [
              _buildActionCard('Manage Users', Icons.group, Colors.orangeAccent),
              _buildActionCard('Reports', Icons.bar_chart, Colors.greenAccent),
              _buildActionCard(
                  'Export Attendance', Icons.file_download, Colors.purpleAccent),
              _buildActionCard('Feedback', Icons.feedback_outlined, Colors.pinkAccent),
              _buildActionCard('Announcements', Icons.campaign, Colors.blueAccent),
              _buildActionCard('Settings', Icons.settings, Colors.tealAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white,
          child: Icon(Icons.admin_panel_settings, color: Colors.blue, size: 40),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${widget.name} 👋',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(widget.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 5),
              Text(DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------- CIRCULAR INDICATOR -------------------
  Widget _buildCircularIndicator(
      String title, double percent, Color color, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 8.0,
            animation: true,
            percent: percent,
            center: Icon(icon, color: color, size: 30),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: color,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percent * 100).toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ------------------- PLACEHOLDER & SETTINGS -------------------
  Widget _placeholderPage(String title, IconData icon, String subtitle) {
    return Center(
      key: ValueKey(title),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 70),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _settingsPage() {
    return ListView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Settings',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 20),
        _settingsTile(Icons.lock, 'Change Password', 'Update your password'),
        _settingsTile(Icons.notifications, 'Notifications', 'Manage alerts and updates'),
        _settingsTile(Icons.color_lens, 'Theme', 'Customize color scheme'),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title feature coming soon!')),
        );
      },
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

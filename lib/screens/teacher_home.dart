import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

class TeacherHome extends StatefulWidget {
  final String name;
  final String email;
  const TeacherHome({super.key, required this.name, required this.email});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> _tabs = ['Dashboard', 'Attendance', 'Profile'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.forward(from: 0); // Restart fade animation on tab change
    });
  }

  Future<void> _logout(BuildContext context) async {
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
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.deepPurple;
    final Color accent = Colors.amber;
    final Color background = const Color(0xFFF5F4FB);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 4,
        title: Text(
          _tabs[_selectedIndex],
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(primary, accent),
            _buildAttendance(context),
            _buildProfileSection(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: primary.withOpacity(0.1),
        elevation: 3,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.check_box_outlined), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  /// Dashboard tab
  Widget _buildDashboard(Color primary, Color accent) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ListView(
        children: [
          Text(
            'Welcome back, ${widget.name} 👋',
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.bold, color: primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your classes and attendance easily.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedFeatureCard(
                  tag: 'mark',
                  icon: Icons.check_circle_outline,
                  title: 'Mark Attendance',
                  color: primary,
                  onTap: () => _markAttendance(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedFeatureCard(
                  tag: 'view',
                  icon: Icons.visibility_outlined,
                  title: 'View Attendance',
                  color: accent,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('View attendance — feature coming soon.')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnimatedFeatureCard(
            tag: 'class',
            icon: Icons.class_outlined,
            title: 'Manage Classes',
            color: Colors.teal,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Class management — coming soon.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFeatureCard({
    required String tag,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Hero(
      tag: tag,
      child: GestureDetector(
        onTapDown: (_) => _controller.reverse(), // Small animation feedback
        onTapUp: (_) => _controller.forward(),
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: color.withOpacity(0.9),
            child: Container(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Attendance tab
  Widget _buildAttendance(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _markAttendance(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
        icon: const Icon(Icons.check_box_outlined, color: Colors.white),
        label: Text(
          'Start Attendance',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _markAttendance(BuildContext context) async {
    bool confirm = await showConfirmationDialog(
      context,
      'Mark Attendance',
      'Are you ready to mark attendance for your class?',
    );
    if (confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mark attendance — connect to classroom API.')),
      );
    }
  }

  /// Profile tab
  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildProfileTile(Icons.person, 'Name', widget.name),
          _buildProfileTile(Icons.email, 'Email', widget.email),
          const Spacer(),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text('Logout',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text(value, style: GoogleFonts.poppins(color: Colors.black87)),
      ),
    );
  }
}

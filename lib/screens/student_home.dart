import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

// ✅ Standardized App Colors — now with dark black text variants
class AppColors {
  static const Color primary = Colors.deepPurple;
  static const Color accent = Colors.blueAccent;
  static const Color background = Color(0xFFF5F4FB);
  static const Color white = Colors.white;

  // 🖤 Dark black for better readability (not pure #000000)
  static const Color darkBlack = Color(0xFF121212);        // Primary text
  static const Color darkBlackSecondary = Color(0xFF424242); // Secondary text

  // Attendance status colors
  static const Color presentBase = Colors.greenAccent;
  static const Color absentBase = Colors.redAccent;
  static const Color leaveBase = Colors.orangeAccent;
  static const Color holidayBase = Colors.blueAccent;
}

class StudentHome extends StatefulWidget {
  final String name;
  final String email;
  const StudentHome({super.key, required this.name, required this.email});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, String> attendanceData = {
    DateTime(2025, 10, 1): 'Present',
    DateTime(2025, 10, 2): 'Absent',
    DateTime(2025, 10, 3): 'Leave',
    DateTime(2025, 10, 4): 'Holiday',
    DateTime(2025, 10, 5): 'Present',
  };

  final List<String> _tabs = ['Home', 'Attendance', 'Profile'];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.forward(from: 0);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 3,
        title: Text(
          _tabs[_selectedIndex],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
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
            _buildHomeTab(),
            _buildAttendanceTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        elevation: 3,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  /// 🏠 Home Tab (Calendar)
  Widget _buildHomeTab() {
    final Color present = AppColors.presentBase;
    final Color absent = AppColors.absentBase;
    final Color leave = AppColors.leaveBase;
    final Color holiday = AppColors.holidayBase;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Welcome, ${widget.name} 👋',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlack, // ✅ Updated
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your monthly attendance below.',
            style: GoogleFonts.poppins(color: AppColors.darkBlackSecondary), // ✅ Updated
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2026, 12, 31),
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    String? status = attendanceData[DateTime(day.year, day.month, day.day)];
                    if (status == null) return null;

                    Color color;
                    switch (status) {
                      case 'Present':
                        color = present;
                        break;
                      case 'Absent':
                        color = absent;
                        break;
                      case 'Leave':
                        color = leave;
                        break;
                      case 'Holiday':
                        color = holiday;
                        break;
                      default:
                        color = Colors.grey;
                    }

                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendDot(present, 'Present'),
              _buildLegendDot(absent, 'Absent'),
              _buildLegendDot(leave, 'Leave'),
              _buildLegendDot(holiday, 'Holiday'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.darkBlackSecondary, // ✅ Consistent secondary text
          ),
        ),
      ],
    );
  }

  /// 📊 Attendance Tab
  Widget _buildAttendanceTab() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Summary',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlack, // ✅ Updated
            ),
          ),
          const SizedBox(height: 12),
          _buildStatCard('Total Days', '30', AppColors.primary),
          const SizedBox(height: 10),
          _buildStatCard('Present', '26', AppColors.presentBase),
          const SizedBox(height: 10),
          _buildStatCard('Absent', '2', AppColors.absentBase),
          const SizedBox(height: 10),
          _buildStatCard('Leave', '2', AppColors.leaveBase),
          const Spacer(),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                bool confirm = await showConfirmationDialog(
                  context,
                  'Request Correction',
                  'Do you want to submit an attendance correction request?',
                );
                if (confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Request correction — implement backend.')));
                }
              },
              icon: const Icon(Icons.edit_note),
              label: Text(
                'Request Correction',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            value[0],
            style: TextStyle(color: AppColors.white),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlack, // ✅ Primary text
          ),
        ),
        trailing: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlack, // ✅ Bold value in dark black
          ),
        ),
      ),
    );
  }

  /// 👤 Profile Tab
  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlack, // ✅ Updated
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileTile(Icons.person, 'Name', widget.name),
          _buildProfileTile(Icons.email, 'Email', widget.email),
          const Spacer(),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout, color: AppColors.white),
              label: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlack, // ✅ Title in dark black
          ),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.poppins(
            color: AppColors.darkBlackSecondary, // ✅ Subtitle in secondary dark
          ),
        ),
      ),
    );
  }
}
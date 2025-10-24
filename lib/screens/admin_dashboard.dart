import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

// -------------------- ACTIVITY MODEL --------------------
class Activity {
  final String title;
  final IconData icon;
  final DateTime timestamp;
  final Color color;

  Activity({
    required this.title,
    required this.icon,
    required this.timestamp,
    required this.color,
  });

  String get formattedTime {
    final now = DateTime.now();
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      return DateFormat('hh:mm a').format(timestamp);
    } else if (timestamp.difference(now).inDays.abs() == 1) {
      return 'Yesterday';
    } else {
      return '${timestamp.difference(now).inDays.abs()} days ago';
    }
  }
}

// -------------------- NOTIFICATION MODEL --------------------
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime time;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
  });
}

// -------------------- ADMIN DASHBOARD --------------------
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
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'New User Registered',
      message: 'John Doe has joined as a teacher.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: '2',
      title: 'Attendance Report Ready',
      message: 'Monthly attendance report is ready to download.',
      time: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppNotification(
      id: '3',
      title: 'System Update',
      message: 'A new system update is available.',
      time: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final TextEditingController _feedbackController = TextEditingController();

  List<Activity> get _allActivities {
    final now = DateTime.now();
    return [
      Activity(title: "User John Doe registered", icon: Icons.person_add, timestamp: now.subtract(const Duration(hours: 2)), color: Colors.green),
      Activity(title: "Attendance report exported", icon: Icons.file_download, timestamp: now.subtract(const Duration(hours: 2, minutes: 25)), color: Colors.blue),
      Activity(title: "Password changed for teacher", icon: Icons.lock, timestamp: now.subtract(const Duration(days: 1)), color: Colors.orange),
      Activity(title: "New announcement posted", icon: Icons.campaign, timestamp: now.subtract(const Duration(days: 2)), color: Colors.purple),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _goToNotifications() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      _placeholderPage('Manage Users', Icons.group, 'Coming soon...'),
      _placeholderPage('Reports', Icons.bar_chart, 'Reports and data visualizations'),
      _notificationsPage(),
      _feedbackPage(),
      _settingsPage(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSearch(context),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: _goToNotifications,
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
              if (_notifications.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_notifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: _buildSideDrawer(context),
      body: Container(
        color: Colors.indigo[900], // Standard dark background
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
                    .animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: pages[_selectedIndex],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.indigo[900]?.withOpacity(0.9) ?? Colors.black,
        selectedItemColor: Colors.white,
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
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback_outlined), label: 'Feedback'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: AppSearchDelegate(
        activities: _allActivities,
        notifications: _notifications,
      ),
    );
  }

  Drawer _buildSideDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.indigo[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo[800], // Slightly lighter for contrast
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings,
                  color: Colors.blue, size: 40),
            ),
            accountName: Text(widget.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            accountEmail:
                Text(widget.email, style: const TextStyle(color: Colors.white70)),
          ),
          _drawerItem(Icons.home, 'Home', 0),
          _drawerItem(Icons.group, 'Manage Users', 1),
          _drawerItem(Icons.bar_chart, 'Reports', 2),
          _drawerItem(Icons.notifications, 'Notifications', 3),
          _drawerItem(Icons.feedback_outlined, 'Feedback', 4),
          _drawerItem(Icons.settings, 'Settings', 5),
          const Divider(color: Colors.white30),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
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
      selectedTileColor: Colors.indigo[700],
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          const Text("Today's Overview", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildCircularIndicator("Attendance", 0.92, Colors.green, Icons.access_time_filled),
              _buildCircularIndicator("Teacher Activity", 0.78, Colors.orange, Icons.person),
              _buildCircularIndicator("Student Participation", 0.86, Colors.blue, Icons.school),
              _buildCircularIndicator("System Health", 0.95, Colors.purple, Icons.memory),
            ],
          ),
          const SizedBox(height: 40),
          const Text("Recent Activities", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _allActivities.map((a) => _activityCard(a)).toList(),
          ),
          const SizedBox(height: 30),
          const Text('Quick Actions', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final cardWidth = (maxWidth - 30) / 2;
              return Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  _buildActionCard('Manage Users', Icons.group, Colors.orange, cardWidth),
                  _buildActionCard('Reports', Icons.bar_chart, Colors.green, cardWidth),
                  _buildActionCard('Export Attendance', Icons.file_download, Colors.purple, cardWidth),
                  _buildActionCard('Feedback', Icons.feedback_outlined, Colors.pink, cardWidth),
                  _buildActionCard('Announcements', Icons.campaign, Colors.blue, cardWidth),
                  _buildActionCard('Settings', Icons.settings, Colors.teal, cardWidth),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
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
              Text('Welcome, ${widget.name} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(widget.email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 5),
              Text(DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularIndicator(String title, double percent, Color color, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
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
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text('${(percent * 100).toStringAsFixed(1)}%', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _activityCard(Activity activity) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activity.color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: activity.color.withOpacity(0.3),
            child: Icon(activity.icon, color: activity.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(activity.formattedTime, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationsPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        key: ValueKey('notifications_${_notifications.length}'),
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          if (_notifications.isEmpty)
            const Center(child: Text('No notifications', style: TextStyle(color: Colors.white70)))
          else
            ..._notifications.map((notif) => _notificationTile(notif)).toList(),
        ],
      ),
    );
  }

  Widget _notificationTile(AppNotification notif) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const Icon(Icons.notifications_active, color: Colors.blue),
        title: Text(notif.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notif.message, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(DateFormat('MMM d, hh:mm a').format(notif.time), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteNotification(notif.id),
        ),
      ),
    );
  }

  Widget _feedbackPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Feedback', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe your issue or suggestion...',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_feedbackController.text.trim().isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
                  _feedbackController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter feedback.')));
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Feedback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsPage() {
    return ListView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 20),
        _settingsTile(Icons.lock, 'Change Password', 'Update your password'),
        _settingsTile(Icons.notifications, 'Notification Preferences', 'Manage alerts'),
        _settingsTile(Icons.color_lens, 'Theme', 'Switch between light/dark mode'),
        _settingsTile(Icons.language, 'Language', 'Select app language'),
        _settingsTile(Icons.help_outline, 'Help & Support', 'Contact support team'),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title feature coming soon!')));
      },
    );
  }

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

  Widget _buildActionCard(String title, IconData icon, Color color, double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// -------------------- SEARCH DELEGATE --------------------
class AppSearchDelegate extends SearchDelegate<String> {
  final List<Activity> activities;
  final List<AppNotification> notifications;

  AppSearchDelegate({required this.activities, required this.notifications});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
        icon: const Icon(Icons.clear, color: Colors.white),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back, color: Colors.white),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState();
    }

    final lowerQuery = query.toLowerCase();
    final filteredActivities = activities.where((a) => a.title.toLowerCase().contains(lowerQuery)).toList();
    final filteredNotifications = notifications.where((n) => n.title.toLowerCase().contains(lowerQuery) || n.message.toLowerCase().contains(lowerQuery)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (filteredActivities.isEmpty && filteredNotifications.isEmpty)
          const Center(child: Text('No results found.', style: TextStyle(color: Colors.white70)))
        else ...[
          if (filteredActivities.isNotEmpty) ...[
            const ListTile(title: Text('Activities', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
            ...filteredActivities.map((a) => ListTile(
                  leading: CircleAvatar(backgroundColor: a.color.withOpacity(0.3), child: Icon(a.icon, color: a.color)),
                  title: Text(a.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(a.formattedTime, style: const TextStyle(color: Colors.white54)),
                )),
          ],
          if (filteredNotifications.isNotEmpty) ...[
            const ListTile(title: Text('Notifications', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
            ...filteredNotifications.map((n) => ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: Text(n.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(n.message, style: const TextStyle(color: Colors.white54)),
                )),
          ],
        ],
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('Search activities, notifications, and more...', style: TextStyle(color: Colors.white70)),
    );
  }
}
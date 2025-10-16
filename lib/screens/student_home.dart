import 'package:flutter/material.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

/// --------------------------------------------
/// Mock Realtime Service (replace with backend)
/// --------------------------------------------
class RealtimeAttendanceService {
  static Future<Map<String, dynamic>> getStudentAttendance(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'totalClasses': 42,
      'present': 38,
      'lastUpdated': DateTime.now().toString(),
      'recentRecords': [
        {'date': '2025-10-14', 'status': 'Present'},
        {'date': '2025-10-13', 'status': 'Present'},
        {'date': '2025-10-12', 'status': 'Absent'},
        {'date': '2025-10-11', 'status': 'Present'},
      ],
    };
  }

  static Future<void> sendCorrectionRequest(String email, String message) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

/// --------------------------------------------
/// Student Home Wrapper (with Bottom Navbar)
/// --------------------------------------------
class StudentHome extends StatefulWidget {
  final String name;
  final String email;
  const StudentHome({super.key, required this.name, required this.email});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      StudentDashboard(name: widget.name),
      StudentAttendance(email: widget.email),
      StudentCorrectionRequest(email: widget.email),
      StudentProfile(name: widget.name, email: widget.email),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), label: 'Correction'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

/// --------------------------------------------
/// 1️⃣ Student Dashboard
/// --------------------------------------------
class StudentDashboard extends StatelessWidget {
  final String name;
  const StudentDashboard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, $name 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Quick Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _quickButton(context, Icons.bar_chart, 'View Attendance', Colors.blue, 1),
              _quickButton(context, Icons.edit_note, 'Correction Request', Colors.orange, 2),
              _quickButton(context, Icons.person, 'My Profile', Colors.green, 3),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _quickButton(BuildContext context, IconData icon, String title, Color color, int index) {
    return InkWell(
      onTap: () {
        final parent = context.findAncestorStateOfType<_StudentHomeState>();
        parent?.setState(() => parent._selectedIndex = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: color)),
        ]),
      ),
    );
  }
}

/// --------------------------------------------
/// 2️⃣ Student Attendance (Realtime)
/// --------------------------------------------
class StudentAttendance extends StatefulWidget {
  final String email;
  const StudentAttendance({super.key, required this.email});

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance> {
  late Future<Map<String, dynamic>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = RealtimeAttendanceService.getStudentAttendance(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final total = data['totalClasses'];
          final present = data['present'];
          final percent = (present / total * 100).toStringAsFixed(1);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Column(children: [
                  Text('$percent%',
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 6),
                  Text('Attendance Percentage',
                      style: TextStyle(color: Colors.grey[600])),
                ]),
              ),
              const SizedBox(height: 20),
              Text('Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Total Classes: $total'),
              Text('Attended: $present'),
              Text('Last Updated: ${data['lastUpdated'].substring(0, 16)}'),
              const SizedBox(height: 20),
              const Divider(),
              const Text('Recent Attendance Records:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: data['recentRecords'].length,
                  itemBuilder: (context, i) {
                    final r = data['recentRecords'][i];
                    return ListTile(
                      leading: Icon(
                        r['status'] == 'Present'
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                        color:
                            r['status'] == 'Present' ? Colors.green : Colors.redAccent,
                      ),
                      title: Text(r['date']),
                      subtitle: Text(r['status']),
                    );
                  },
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

/// --------------------------------------------
/// 3️⃣ Correction Request Page
/// --------------------------------------------
class StudentCorrectionRequest extends StatefulWidget {
  final String email;
  const StudentCorrectionRequest({super.key, required this.email});

  @override
  State<StudentCorrectionRequest> createState() =>
      _StudentCorrectionRequestState();
}

class _StudentCorrectionRequestState extends State<StudentCorrectionRequest> {
  final _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendRequest() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter your message')));
      return;
    }

    final confirm = await showConfirmationDialog(
      context,
      'Submit Request',
      'Send correction request?',
    );
    if (!confirm) return;

    setState(() => _isSending = true);
    await RealtimeAttendanceService.sendCorrectionRequest(widget.email, _controller.text);
    setState(() => _isSending = false);
    _controller.clear();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Request sent successfully ✅')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Correction Request')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Describe your attendance issue:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Example: I was present on 12/10/2025 but marked absent.',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isSending ? null : _sendRequest,
            icon: _isSending
                ? const SizedBox(
                    height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
            label: _isSending ? const Text('Sending...') : const Text('Submit Request'),
          ),
        ]),
      ),
    );
  }
}

/// --------------------------------------------
/// 4️⃣ Profile Page (Logout)
/// --------------------------------------------
class StudentProfile extends StatelessWidget {
  final String name;
  final String email;
  const StudentProfile({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showConfirmationDialog(
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(name),
            subtitle: const Text('Student Name'),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(email),
            subtitle: const Text('Email'),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('Version 1.0.0')),
        ]),
      ),
    );
  }
}

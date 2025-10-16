import 'package:flutter/material.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

class TeacherHome extends StatelessWidget {
  final String name;
  final String email;
  const TeacherHome({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: $email', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                bool confirm = await showConfirmationDialog(
                  context,
                  'Mark Attendance',
                  'Are you ready to mark attendance for your class?',
                );
                if (confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mark attendance — connect to classroom API.')));
                }
              },
              icon: const Icon(Icons.check_box_outlined),
              label: const Text('Mark Attendance'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('View attendance — implement view.')));
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
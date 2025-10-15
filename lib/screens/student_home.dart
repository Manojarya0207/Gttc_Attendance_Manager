import 'package:flutter/material.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

class StudentHome extends StatelessWidget {
  final String name;
  final String email;
  const StudentHome({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
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
            Text('Welcome, $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: $email', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('View personal attendance — integrate with backend.')));
              },
              icon: const Icon(Icons.pie_chart_outline),
              label: const Text('View Attendance'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                bool confirm = await showConfirmationDialog(
                  context,
                  'Request Correction',
                  'Do you want to submit an attendance correction request?',
                );
                if (confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request correction — implement backend.')));
                }
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('Request Correction'),
            ),
          ],
        ),
      ),
    );
  }
}
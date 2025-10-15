import 'package:flutter/material.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

class AdminDashboard extends StatelessWidget {
  final String name;
  final String email;
  const AdminDashboard({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: $email', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            const Text('Admin actions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                bool confirm = await showConfirmationDialog(
                  context,
                  'Manage Users',
                  'Proceed to manage users and classes?',
                );
                if (confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manage users — implement backend integration.')));
                }
              },
              icon: const Icon(Icons.manage_accounts),
              label: const Text('Manage users & classes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                bool confirm = await showConfirmationDialog(
                  context,
                  'Export Attendance',
                  'This will generate and download attendance reports. Continue?',
                );
                if (confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export / Reports — implement backend integration.')));
                }
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Export attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
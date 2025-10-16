import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/dialog_utils.dart';
import 'auth_entry_screen.dart';

/// ------------------------------------------------------
/// DATA MODELS
/// ------------------------------------------------------
class ClassModel {
  final String id;
  final String name;
  const ClassModel(this.id, this.name);
}

class Student {
  final String id;
  final String name;
  final bool isPresent;
  final String? remarks;
  const Student(this.id, this.name, this.isPresent, {this.remarks});

  Student copyWith({bool? isPresent, String? remarks}) => Student(
        id,
        name,
        isPresent ?? this.isPresent,
        remarks: remarks ?? this.remarks,
      );
}

/// ------------------------------------------------------
/// MOCK SERVICE (Replace with real API later)
/// ------------------------------------------------------
class AttendanceService {
  static Future<List<ClassModel>> getClasses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      ClassModel('c1', 'Grade 10 - A'),
      ClassModel('c2', 'Grade 11 - B'),
    ];
  }

  static Future<List<Student>> getStudents(String classId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      const Student('s1', 'Alice Johnson', false),
      const Student('s2', 'Bob Smith', true),
      const Student('s3', 'Charlie Brown', false),
      const Student('s4', 'David Williams', true),
      const Student('s5', 'Eve Taylor', false),
    ];
  }

  static Future<void> submitAttendance(String classId, DateTime date, List<Student> students) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

/// ------------------------------------------------------
/// LOCAL DATABASE HELPER (SQLite)
/// ------------------------------------------------------
class AttendanceDB {
  static Database? _db;

  static Future<Database> _getDB() async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'attendance.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE attendance(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            classId TEXT,
            className TEXT,
            date TEXT,
            presentCount INTEGER,
            totalCount INTEGER
          )
        ''');
      },
      version: 1,
    );
    return _db!;
  }

  static Future<void> insertRecord(String classId, String className, DateTime date, int present, int total) async {
    final db = await _getDB();
    await db.insert('attendance', {
      'classId': classId,
      'className': className,
      'date': date.toIso8601String(),
      'presentCount': present,
      'totalCount': total,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchRecords() async {
    final db = await _getDB();
    return db.query('attendance', orderBy: 'id DESC');
  }
}

/// ------------------------------------------------------
/// MAIN TEACHER HOME WRAPPER WITH NAVBAR
/// ------------------------------------------------------
class TeacherHome extends StatefulWidget {
  final String name;
  final String email;
  const TeacherHome({super.key, required this.name, required this.email});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      AttendanceScreen(name: widget.name, email: widget.email),
      const AttendanceHistoryScreen(),
      TeacherProfileScreen(name: widget.name, email: widget.email),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
/// ATTENDANCE SCREEN (Main functionality)
/// ------------------------------------------------------
class AttendanceScreen extends StatefulWidget {
  final String name;
  final String email;
  const AttendanceScreen({super.key, required this.name, required this.email});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<ClassModel>> _classesFuture;
  String? _selectedClassId;
  String? _selectedClassName;
  DateTime _selectedDate = DateTime.now();
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isSynced = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _classesFuture = AttendanceService.getClasses();
  }

  Future<void> _loadStudents() async {
    if (_selectedClassId == null) return;
    setState(() => _isLoading = true);
    try {
      final students = await AttendanceService.getStudents(_selectedClassId!, _selectedDate);
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isSynced = true;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Failed to load students: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _toggleAttendance(String id) {
    setState(() {
      _students = _students.map((s) => s.id == id ? s.copyWith(isPresent: !s.isPresent) : s).toList();
      _applySearchFilter();
      _isSynced = false;
    });
  }

  void _applySearchFilter() {
    _filteredStudents = _searchQuery.isEmpty
        ? _students
        : _students.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _markAll(bool present) {
    setState(() {
      _students = _students.map((s) => s.copyWith(isPresent: present)).toList();
      _applySearchFilter();
      _isSynced = false;
    });
  }

  Future<void> _submitAttendance() async {
    if (_selectedClassId == null) return;
    final confirm = await showConfirmationDialog(
      context as BuildContext,
      'Submit Attendance',
      'Submit attendance for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}?',
    );
    if (!confirm) return;

    setState(() => _isSubmitting = true);
    try {
      await AttendanceService.submitAttendance(_selectedClassId!, _selectedDate, _students);

      final total = _students.length;
      final present = _students.where((s) => s.isPresent).length;

      await AttendanceDB.insertRecord(
          _selectedClassId!, _selectedClassName ?? '', _selectedDate, present, total);

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(content: Text('Attendance saved locally')));
      setState(() => _isSynced = true);
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _students.length;
    final present = _students.where((s) => s.isPresent).length;
    final absent = total - present;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Hello, ${widget.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          FutureBuilder<List<ClassModel>>(
            future: _classesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropdownButtonFormField<String>(
                  value: _selectedClassId,
                  hint: const Text('Select Class'),
                  items: snapshot.data!
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (value) {
                    final className = snapshot.data!.firstWhere((c) => c.id == value!).name;
                    setState(() {
                      _selectedClassId = value;
                      _selectedClassName = className;
                      _students = [];
                      _filteredStudents = [];
                    });
                    if (value != null) _loadStudents();
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Text('Date: '),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  if (_selectedClassId != null) _loadStudents();
                }
              },
            ),
          ]),
          if (_students.isNotEmpty)
            TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Search Students'),
              onChanged: (v) {
                setState(() {
                  _searchQuery = v;
                  _applySearchFilter();
                });
              },
            ),
          if (total > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('✅ $present | ❌ $absent | 📊 ${(present / total * 100).toStringAsFixed(1)}%'),
            ),
          if (!_isSynced)
            const Text('Unsaved changes', style: TextStyle(color: Colors.orange)),
          if (_students.isNotEmpty)
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => _markAll(true), child: const Text('Mark All Present')),
              TextButton(onPressed: () => _markAll(false), child: const Text('Mark All Absent')),
            ]),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? const Center(child: Text('No Students'))
                    : ListView.builder(
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, i) {
                          final s = _filteredStudents[i];
                          return CheckboxListTile(
                            title: Text(s.name),
                            value: s.isPresent,
                            onChanged: (v) => _toggleAttendance(s.id),
                          );
                        },
                      ),
          ),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: _isLoading ? null : _loadStudents,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload),
                label: _isSubmitting
                    ? const Text('Submitting...')
                    : const Text('Submit Attendance'),
                onPressed: _isSubmitting || _students.isEmpty || _isSynced
                    ? null
                    : _submitAttendance,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// ------------------------------------------------------
/// ATTENDANCE HISTORY SCREEN (Reads SQLite)
/// ------------------------------------------------------
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = AttendanceDB.fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history found'));
          }
          final data = snapshot.data!;
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final row = data[i];
              final percent =
                  (row['presentCount'] / row['totalCount'] * 100).toStringAsFixed(1);
              final date = DateTime.parse(row['date']);
              return ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text('${row['className']}'),
                subtitle:
                    Text('${date.day}/${date.month}/${date.year}  —  $percent% attendance'),
              );
            },
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------
/// TEACHER PROFILE SCREEN
/// ------------------------------------------------------
class TeacherProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  const TeacherProfileScreen({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showConfirmationDialog(
                context as BuildContext,
                'Logout',
                'Are you sure you want to logout?',
              );
              if (confirm) {
                Navigator.of(context as BuildContext).pushAndRemoveUntil(
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
            subtitle: const Text('Name'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(email),
            subtitle: const Text('Email'),
          ),
        ]),
      ),
    );
  }
}

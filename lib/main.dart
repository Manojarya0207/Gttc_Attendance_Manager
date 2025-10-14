import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

/// -----------------------------
/// Mock Auth Service (in-memory)
/// -----------------------------
/// This simple service keeps users in-memory during the app lifecycle.
/// Each user: {email, password, role, name}
/// - Register only allows "Teacher" and "Student" (per requirement)
/// - There is one pre-created Admin account (admin@demo.com / admin123)
class AuthService {
  AuthService._privateConstructor();

  static final AuthService instance = AuthService._privateConstructor();

  final Map<String, Map<String, String>> _users = {
    // pre-seeded admin
    'admin@demo.com': {
      'password': 'admin123',
      'role': 'Admin',
      'name': 'GTTC Admin',
    },
  };

  bool emailExists(String email) => _users.containsKey(email.toLowerCase());

  Future<String?> register({
    required String email,
    required String password,
    required String role, // Teacher or Student (we will enforce)
    required String name,
  }) async {
    final e = email.trim().toLowerCase();
    if (_users.containsKey(e)) {
      return 'Email already registered';
    }
    if (!(role == 'Teacher' || role == 'Student')) {
      return 'Only Teacher and Student can register here.';
    }
    // simple password policy
    if (password.length < 6) return 'Password must be at least 6 characters';
    _users[e] = {
      'password': password,
      'role': role,
      'name': name,
    };
    return null; // success
  }

  Future<Map<String, String>?> login({
    required String email,
    required String password,
    required String roleSelected,
  }) async {
    final e = email.trim().toLowerCase();
    if (!_users.containsKey(e)) return null;
    final user = _users[e]!;
    if (user['password'] != password) return null;
    // allow login only for matching role (admin account should choose Admin)
    if (user['role'] != roleSelected) return null;
    return {
      'email': e,
      'role': user['role']!,
      'name': user['name'] ?? '',
    };
  }
}

/// -----------------------------
/// App Root
/// -----------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GTTC Attendance Manager',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1116),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B72FF),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF131416),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

/// -----------------------------
/// SPLASH SCREEN (fade logo)
/// -----------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    // wait then navigate
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthEntry()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // white background for brand splash (keeps logo colors intact), then app uses dark theme
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/GTTC-Lgo-.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              const Text(
                'GTTC Attendance Manager',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0A0A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Simplifying Attendance Tracking',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -----------------------------
/// AUTH ENTRY: choose Login / Register
/// -----------------------------
class AuthEntry extends StatelessWidget {
  const AuthEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1116), Color(0xFF081428)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Image.asset('assets/GTTC-Lgo-.png', width: 80, height: 80),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Login or create an account to continue',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B72FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()));
                          },
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: Color(0xFF0B72FF)),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// -----------------------------
/// GLASS CARD Widget (reusable)
/// -----------------------------
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final EdgeInsets padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 8.0,
    this.padding = const EdgeInsets.all(18.0),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// -----------------------------
/// LOGIN SCREEN
/// -----------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _role;
  bool _loading = false;

  final _roles = ['Admin', 'Teacher', 'Student'];

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _tryLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // faux delay

    final user = await AuthService.instance.login(
      email: _email.text,
      password: _password.text,
      roleSelected: _role!,
    );

    setState(() => _loading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials or role mismatch')),
      );
      return;
    }

    // navigate to role-specific home
    if (user['role'] == 'Admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AdminDashboard(name: user['name']!, email: user['email']!)),
      );
    } else if (user['role'] == 'Teacher') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TeacherHome(name: user['name']!, email: user['email']!)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => StudentHome(name: user['name']!, email: user['email']!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1116), Color(0xFF041028)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundImage: const AssetImage('assets/GTTC-Lgo-.png'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Sign in', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 6),
                    const Text('Choose your role and login', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 18),

                    // role dropdown
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.badge, color: Colors.white70),
                      ),
                      items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _role = v),
                      dropdownColor: const Color(0xFF121316),
                      validator: (v) => v == null ? 'Please pick a role' : null,
                    ),
                    const SizedBox(height: 14),

                    // email
                    TextFormField(
                      controller: _email,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Colors.white70),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email required';
                        final e = v.trim();
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(e)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // password
                    TextFormField(
                      controller: _password,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _tryLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B72FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // forgot / register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot password - connect to backend to enable.')));
                          },
                          child: const Text('Forgot?', style: TextStyle(color: Colors.white70)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          },
                          child: const Text('Create account', style: TextStyle(color: Color(0xFF0B72FF))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// -----------------------------
/// REGISTER SCREEN (no Admin option)
/// -----------------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'Student';
  bool _loading = false;

  final _roles = ['Teacher', 'Student']; // Admin not available

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _tryRegister() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final err = await AuthService.instance.register(
      email: _email.text,
      password: _password.text,
      role: _role,
      name: _name.text.trim(),
    );

    setState(() => _loading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful — you can login now.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // keep consistent gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1116), Color(0xFF041028)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28),
            child: GlassCard(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                   Image.asset('assets/GTTC-Lgo-.png', width: 100, height: 100),
                    const SizedBox(height: 12),
                    const Text('Create Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),

                    // role
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(labelText: 'Register as', prefixIcon: Icon(Icons.badge, color: Colors.white70)),
                      items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _role = v ?? 'Student'),
                    ),
                    const SizedBox(height: 12),

                    // name
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person, color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                    ),
                    const SizedBox(height: 12),

                    // email
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email, color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email required';
                        final e = v.trim();
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(e)) return 'Enter valid email';
                        if (AuthService.instance.emailExists(e)) return 'Email already registered';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // password
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock, color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        if (v.length < 6) return 'Password must be 6+ chars';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _tryRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B72FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to login', style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// -----------------------------
/// ADMIN DASHBOARD (placeholder)
/// -----------------------------
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
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthEntry()),
                (route) => false,
              );
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manage users — implement backend integration.')));
              },
              icon: const Icon(Icons.manage_accounts),
              label: const Text('Manage users & classes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export / Reports — implement backend integration.')));
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

/// -----------------------------
/// TEACHER HOME (placeholder)
/// -----------------------------
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
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthEntry()),
                (route) => false,
              );
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mark attendance — connect to classroom API.')));
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

/// -----------------------------
/// STUDENT HOME (placeholder)
/// -----------------------------
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
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthEntry()),
                (route) => false,
              );
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request correction — implement backend.')));
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

class AuthService {
  AuthService._privateConstructor();

  static final AuthService instance = AuthService._privateConstructor();

  final Map<String, Map<String, String>> _users = {
    'manojarya0207@gmail.com': {
      'password': 'manojarya',
      'role': 'Admin',
      'name': 'GTTC Admin',
    },
  };

  bool emailExists(String email) => _users.containsKey(email.toLowerCase());

  Future<String?> register({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    final e = email.trim().toLowerCase();
    if (_users.containsKey(e)) {
      return 'Email already registered';
    }
    if (!(role == 'Teacher' || role == 'Student')) {
      return 'Only Teacher and Student can register here.';
    }
    if (password.length < 6) return 'Password must be at least 6 characters';
    _users[e] = {
      'password': password,
      'role': role,
      'name': name,
    };
    return null;
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
    if (user['role'] != roleSelected) return null;
    return {
      'email': e,
      'role': user['role']!,
      'name': user['name'] ?? '',
    };
  }
}
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

class LocalAuthService {
  static const String _boxName = 'users';

  /// Register a user locally. Returns true if success, false if user exists.
  static Future<bool> register(Map<String, dynamic> user) async {
    final box = Hive.box(_boxName);
    final email = (user['email'] ?? '').toString().toLowerCase();
    if (email.isEmpty) return false;
    if (box.containsKey(email)) return false; // already registered

    final password = user['password'] ?? '';
    final hashed = _hash(password.toString());

    final stored = Map<String, dynamic>.from(user);
    stored['password'] = hashed;

    await box.put(email, stored);
    return true;
  }

  /// Login locally. Returns user map if successful, null otherwise.
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final box = Hive.box(_boxName);
    final key = email.toLowerCase();
    if (!box.containsKey(key)) return null;
    final stored = Map<String, dynamic>.from(box.get(key));
    final hashed = _hash(password);
    if (stored['password'] == hashed) return stored;
    return null;
  }

  static String _hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

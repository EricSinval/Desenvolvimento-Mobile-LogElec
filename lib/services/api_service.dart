import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService({this.baseUrl = 'http://10.0.2.2:8080'});

  /// Attempts to login against backend. Returns true if a token is received and stored.
  Future<bool> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/login');
      final resp = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final token = data['token'] ?? data['accessToken'] ?? data['jwt'];
        if (token != null) {
          await _secureStorage.write(key: 'auth_token', value: token.toString());
          return true;
        }
        return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Sends signup payload to backend. Returns true on success (200/201).
  Future<bool> signup(Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/signup');
      final resp = await http.post(uri,
          headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}

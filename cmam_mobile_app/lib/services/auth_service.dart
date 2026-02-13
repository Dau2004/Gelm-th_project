import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8001/api/auth';
  static const storage = FlutterSecureStorage();
  
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Store tokens
        await storage.write(key: 'access_token', value: data['access']);
        await storage.write(key: 'refresh_token', value: data['refresh']);
        
        // Store user info
        await storage.write(key: 'user_id', value: data['user']['id'].toString());
        await storage.write(key: 'username', value: data['user']['username']);
        await storage.write(key: 'full_name', value: data['user']['full_name']);
        await storage.write(key: 'phone', value: data['user']['phone']);
        await storage.write(key: 'state', value: data['user']['state']);
        await storage.write(key: 'facility', value: data['user']['facility']);
        await storage.write(key: 'role', value: data['user']['role']);
        
        return data['user'];
      } else {
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  static Future<void> logout() async {
    await storage.deleteAll();
  }
  
  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }
  
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  static Future<Map<String, String>?> getCurrentUser() async {
    final userId = await storage.read(key: 'user_id');
    if (userId == null) return null;
    
    return {
      'id': userId,
      'username': await storage.read(key: 'username') ?? '',
      'full_name': await storage.read(key: 'full_name') ?? '',
      'phone': await storage.read(key: 'phone') ?? '',
      'state': await storage.read(key: 'state') ?? '',
      'facility': await storage.read(key: 'facility') ?? '',
      'role': await storage.read(key: 'role') ?? '',
    };
  }
  
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
}

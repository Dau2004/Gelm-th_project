import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_assessment.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator
  // Use 'http://10.0.2.2:8000/api' for Android emulator
  // Use your computer's IP (e.g., 'http://192.168.1.x:8000/api') for physical device

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        await prefs.setBool('is_logged_in', true);
        
        // Handle user data if present
        if (data.containsKey('user') && data['user'] != null) {
          await prefs.setString('user_role', data['user']['role'] ?? 'CHW');
          await prefs.setInt('user_id', data['user']['id'] ?? 0);
          if (data['user']['facility'] != null) {
            await prefs.setInt('facility_id', data['user']['facility']);
          }
        }
        return data;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> syncAssessment(ChildAssessment assessment) async {
    try {
      final headers = await _getHeaders();
      final token = await _getToken();
      
      if (token == null) {
        print('❌ Sync failed: No authentication token found');
        return null;
      }
      
      final payload = assessment.toApiMap();
      print('📤 Syncing assessment: ${payload['child_id']}');
      
      // Convert facility name to ID if needed
      if (payload['facility'] != null && payload['facility'] is String) {
        final facilityId = await _getFacilityIdByName(payload['facility']);
        if (facilityId != null) {
          payload['facility'] = facilityId;
          print('✓ Facility converted: ${payload['facility']} -> $facilityId');
        } else {
          print('⚠ Facility not found, removing from payload');
          payload.remove('facility');
        }
      }
      
      print('📦 Payload: ${jsonEncode(payload)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/assessments/'),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('📥 Response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        print('✅ Sync successful!');
        return jsonDecode(response.body);
      }
      print('❌ Sync failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('❌ Sync error: $e');
      return null;
    }
  }

  static Future<int?> _getFacilityIdByName(String name) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/facilities/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final facilities = data['results'] ?? data;
        for (var facility in facilities) {
          if (facility['name'] == name) {
            return facility['id'];
          }
        }
      }
      return null;
    } catch (e) {
      print('Facility lookup error: $e');
      return null;
    }
  }

  static Future<List<ChildAssessment>> fetchAssessments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/assessments/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? data;
        return results.map((json) => ChildAssessment.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Fetch error: $e');
      return [];
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/../admin/'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);
  }
}

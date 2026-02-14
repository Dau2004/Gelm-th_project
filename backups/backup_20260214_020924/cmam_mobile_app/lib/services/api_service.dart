import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/child_assessment.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator
  // Use 'http://10.0.2.2:8000/api' for Android emulator
  // Use your computer's IP (e.g., 'http://192.168.1.x:8000/api') for physical device

  static Future<String?> _getToken() async {
    return await AuthService.getAccessToken();
  }

  static Future<Map<String, String>> _getHeaders() async {
    return await AuthService.getAuthHeaders();
  }

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    return await AuthService.login(username, password);
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
    await AuthService.logout();
  }

  static Future<List<Map<String, dynamic>>> getActiveDoctors() async {
    try {
      final token = await _getToken();
      print('🔑 Token for doctors: ${token != null ? "Present" : "Missing"}');
      
      final headers = await _getHeaders();
      print('📤 Fetching doctors from: $baseUrl/referrals/active_doctors/');
      
      final response = await http.get(
        Uri.parse('$baseUrl/referrals/active_doctors/'),
        headers: headers,
      );

      print('📥 Doctors response: ${response.statusCode}');
      
      if (response.statusCode == 401) {
        print('❌ Authentication failed - clearing token');
        await logout();
        return [];
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Doctors loaded: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to load doctors: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e) {
      print('❌ Get doctors error: $e');
      return [];
    }
  }

  static Future<bool> createReferral({
    required String childId,
    required int doctorId,
    required String notes,
  }) async {
    try {
      final headers = await _getHeaders();
      print('📤 Creating referral: ChildID=$childId, Doctor=$doctorId');
      
      // First, get the assessment ID from the server using child_id
      final assessmentResponse = await http.get(
        Uri.parse('$baseUrl/assessments/?child_id=$childId'),
        headers: headers,
      );
      
      if (assessmentResponse.statusCode != 200) {
        print('❌ Failed to find assessment: ${assessmentResponse.statusCode}');
        return false;
      }
      
      final assessmentData = jsonDecode(assessmentResponse.body);
      final results = assessmentData['results'] ?? assessmentData;
      
      if (results.isEmpty) {
        print('❌ No assessment found for child_id: $childId');
        return false;
      }
      
      final assessmentId = results[0]['id'];
      print('✓ Found assessment ID: $assessmentId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/referrals/'),
        headers: headers,
        body: jsonEncode({
          'assessment': assessmentId,
          'referred_to': doctorId,
          'referral_notes': notes,
          'urgency': 'HIGH',
          'status': 'PENDING',
        }),
      );

      print('📥 Referral response: ${response.statusCode}');
      if (response.statusCode == 201) {
        print('✅ Referral created successfully');
        return true;
      } else {
        print('❌ Referral failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Create referral error: $e');
      return false;
    }
  }
}

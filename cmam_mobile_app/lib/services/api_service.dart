import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/child_assessment.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://api.deaglefarm.com/api'; // Production EC2

  static Future<String?> _getToken() async {
    return await AuthService.getAccessToken();
  }

  static Future<Map<String, String>> _getHeaders() async {
    return await AuthService.getAuthHeaders();
  }

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    return await AuthService.login(username, password);
  }

  static Future<bool> _handleTokenRefresh() async {
    final refreshed = await AuthService.refreshToken();
    if (!refreshed) {
      await logout();
      return false;
    }
    return true;
  }

  static Future<Map<String, dynamic>?> syncAssessment(ChildAssessment assessment) async {
    try {
      var headers = await _getHeaders();
      final token = await _getToken();

      if (token == null) {
        print('ERROR Sync failed: No authentication token found');
        return null;
      }

      final payload = assessment.toApiMap();

      // Convert facility name to ID if needed
      if (payload['facility'] != null && payload['facility'] is String) {
        final facilityId = await _getFacilityIdByName(payload['facility']);
        if (facilityId != null) {
          payload['facility'] = facilityId;
        } else {
          payload.remove('facility');
        }
      }

      var response = await http.post(
        Uri.parse('$baseUrl/assessments/'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 401) {
        final refreshed = await _handleTokenRefresh();
        if (!refreshed) {
          print('ERROR Sync failed: Session expired, please login again');
          return null;
        }
        headers = await _getHeaders();
        response = await http.post(
          Uri.parse('$baseUrl/assessments/'),
          headers: headers,
          body: jsonEncode(payload),
        );
      }

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      print('ERROR Sync failed [${response.statusCode}]: ${response.body}');
      return null;
    } catch (e) {
      print('ERROR Sync error: $e');
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
      print('ERROR Facility lookup failed: $e');
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
      print('ERROR Fetch assessments failed [${response.statusCode}]: ${response.body}');
      return [];
    } catch (e) {
      print('ERROR Fetch assessments error: $e');
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
      var headers = await _getHeaders();

      var response = await http.get(
        Uri.parse('$baseUrl/referrals/active_doctors/'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        final refreshed = await _handleTokenRefresh();
        if (!refreshed) {
          print('ERROR Fetch doctors failed: Session expired, please login again');
          return [];
        }
        headers = await _getHeaders();
        response = await http.get(
          Uri.parse('$baseUrl/referrals/active_doctors/'),
          headers: headers,
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      print('ERROR Fetch doctors failed [${response.statusCode}]: ${response.body}');
      return [];
    } catch (e) {
      print('ERROR Fetch doctors error: $e');
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

      final assessmentResponse = await http.get(
        Uri.parse('$baseUrl/assessments/?child_id=$childId'),
        headers: headers,
      );

      if (assessmentResponse.statusCode != 200) {
        print('ERROR Create referral failed: Could not find assessment for child $childId [${assessmentResponse.statusCode}]');
        return false;
      }

      final assessmentData = jsonDecode(assessmentResponse.body);
      final results = assessmentData['results'] ?? assessmentData;

      if (results.isEmpty) {
        print('ERROR Create referral failed: No assessment found for child_id $childId');
        return false;
      }

      final assessmentId = results[0]['id'];

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

      if (response.statusCode == 201) {
        return true;
      }
      print('ERROR Create referral failed [${response.statusCode}]: ${response.body}');
      return false;
    } catch (e) {
      print('ERROR Create referral error: $e');
      return false;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'database_service.dart';
import '../models/referral.dart';

class SyncService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  static Future<int?> _getFacilityIdByName(String name) async {
    try {
      final headers = await AuthService.getAuthHeaders();
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

  static Future<Map<String, dynamic>> syncAssessments() async {
    try {
      final unsyncedAssessments = await DatabaseService.instance.getUnsyncedAssessments();
      
      if (unsyncedAssessments.isEmpty) {
        return {'success': true, 'message': 'No assessments to sync', 'count': 0};
      }
      
      final headers = await AuthService.getAuthHeaders();
      int successCount = 0;
      
      for (var assessment in unsyncedAssessments) {
        try {
          final payload = assessment.toApiMap();
          
          // Convert facility name to ID
          if (payload['facility'] != null && payload['facility'] is String) {
            final facilityId = await _getFacilityIdByName(payload['facility']);
            if (facilityId != null) {
              payload['facility'] = facilityId;
            } else {
              payload.remove('facility');
            }
          }
          
          print('📦 Syncing: ${jsonEncode(payload)}');
          
          final response = await http.post(
            Uri.parse('$baseUrl/assessments/'),
            headers: headers,
            body: jsonEncode(payload),
          );
          
          print('📥 Response ${response.statusCode}: ${response.body}');
          
          if (response.statusCode == 201) {
            if (assessment.id != null) {
              await DatabaseService.instance.markAsSynced(int.parse(assessment.id!));
            }
            successCount++;
          }
        } catch (e) {
          print('❌ Failed to sync assessment ${assessment.childId}: $e');
        }
      }
      
      return {
        'success': successCount > 0,
        'message': 'Synced $successCount of ${unsyncedAssessments.length} assessments',
        'count': successCount
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Sync error: $e',
        'count': 0
      };
    }
  }
  
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> syncReferrals() async {
    try {
      final unsyncedReferrals = await DatabaseService.instance.getUnsyncedReferrals();
      
      if (unsyncedReferrals.isEmpty) {
        return {'success': true, 'message': 'No referrals to sync', 'count': 0};
      }
      
      final headers = await AuthService.getAuthHeaders();
      final referralsData = unsyncedReferrals.map((r) => r.toApiMap()).toList();
      
      final response = await http.post(
        Uri.parse('$baseUrl/referrals/bulk_create/'),
        headers: headers,
        body: jsonEncode(referralsData),
      );
      
      if (response.statusCode == 201) {
        for (var referral in unsyncedReferrals) {
          if (referral.id != null) {
            await DatabaseService.instance.markReferralAsSynced(int.parse(referral.id!));
          }
        }
        return {'success': true, 'message': 'Referrals synced', 'count': unsyncedReferrals.length};
      } else {
        return {'success': false, 'message': 'Sync failed: ${response.statusCode}', 'count': 0};
      }
    } catch (e) {
      return {'success': false, 'message': 'Sync error: $e', 'count': 0};
    }
  }
}

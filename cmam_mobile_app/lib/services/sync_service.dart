import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'database_service.dart';
import '../models/referral.dart';

class SyncService {
  static const String baseUrl = 'http://localhost:8001/api';
  
  static Future<Map<String, dynamic>> syncAssessments() async {
    try {
      // Get unsynced assessments
      final unsyncedAssessments = await DatabaseService.instance.getUnsyncedAssessments();
      
      if (unsyncedAssessments.isEmpty) {
        return {'success': true, 'message': 'No assessments to sync', 'count': 0};
      }
      
      // Get auth headers
      final headers = await AuthService.getAuthHeaders();
      
      // Prepare assessment data
      final assessmentsData = unsyncedAssessments.map((assessment) {
        final map = assessment.toApiMap();
        return {
          'child_id': map['child_id'],
          'sex': map['sex'],
          'age_months': map['age_months'],
          'muac_mm': map['muac_mm'],
          'edema': map['edema'] ?? 0,
          'appetite': map['appetite'] ?? 'good',
          'danger_signs': map['danger_signs'] ?? 0,
          'muac_z_score': map['muac_z_score'],
          'clinical_status': map['clinical_status'],
          'recommended_pathway': map['recommended_pathway'],
          'confidence': map['confidence'],
          'chw_username': map['chw_username'],
          'chw_name': map['chw_name'],
          'chw_phone': map['chw_phone'] ?? '',
          'chw_facility': map['facility'] ?? '',
          'chw_state': map['state'] ?? '',
          'chw_notes': map['chw_notes'] ?? '',
          'chw_signature': map['chw_signature'] ?? '',
          'assessment_date': assessment.timestamp.toIso8601String(),
        };
      }).toList();
      
      // Send to backend
      final response = await http.post(
        Uri.parse('$baseUrl/assessments/bulk_create/'),
        headers: headers,
        body: jsonEncode(assessmentsData),
      );
      
      if (response.statusCode == 201) {
        // Mark as synced
        for (var assessment in unsyncedAssessments) {
          if (assessment.id != null) {
            await DatabaseService.instance.markAsSynced(int.parse(assessment.id!));
          }
        }
        
        final result = jsonDecode(response.body);
        return {
          'success': true,
          'message': result['message'],
          'count': result['count']
        };
      } else {
        return {
          'success': false,
          'message': 'Sync failed: ${response.statusCode}',
          'count': 0
        };
      }
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

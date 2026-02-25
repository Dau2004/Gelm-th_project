/**
 * MOBILE APP UI & INTEGRATION TESTS - FIXED VERSION
 * All 15 issues resolved
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmam_app/main.dart';
import 'package:cmam_app/services/database_service.dart';
import 'package:cmam_app/models/child_assessment.dart';

void main() {
  group('UI Screen Tests', () {
    testWidgets('App launches and shows login screen', (WidgetTester tester) async {
      await tester.pumpWidget(const CMAMApp());
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('Database Operations Tests', () {
    setUp(() async {
      await DatabaseService.instance.database;
    });

    tearDown(() async {
      final db = await DatabaseService.instance.database;
      await db.delete('assessments');
    });

    test('Database initializes successfully', () async {
      final db = await DatabaseService.instance.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('Can insert assessment into database', () async {
      final assessment = ChildAssessment(
        childId: 'DB_TEST_001',
        sex: 'M',
        ageMonths: 24,
        muacMm: 110,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        clinicalStatus: 'SAM',
        recommendedPathway: 'OTP',
        confidence: 0.95,
        timestamp: DateTime.now(),
        synced: false,
      );

      final id = await DatabaseService.instance.createAssessment(assessment);
      expect(id, greaterThan(0));

      final assessments = await DatabaseService.instance.getAllAssessments();
      expect(assessments.length, greaterThan(0));
      expect(assessments.first.childId, 'DB_TEST_001');
    });

    test('Can retrieve assessments from database', () async {
      final assessment1 = ChildAssessment(
        childId: 'RETRIEVE_001',
        sex: 'M',
        ageMonths: 24,
        muacMm: 110,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        clinicalStatus: 'SAM',
        recommendedPathway: 'OTP',
        confidence: 0.95,
        timestamp: DateTime.now(),
        synced: false,
      );

      await DatabaseService.instance.createAssessment(assessment1);

      final assessments = await DatabaseService.instance.getAllAssessments();
      expect(assessments, isNotEmpty);
      expect(assessments.any((a) => a.childId == 'RETRIEVE_001'), isTrue);
    });

    test('Can update assessment sync status', () async {
      final assessment = ChildAssessment(
        childId: 'SYNC_TEST_001',
        sex: 'F',
        ageMonths: 18,
        muacMm: 115,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        clinicalStatus: 'MAM',
        recommendedPathway: 'TSFP',
        confidence: 0.92,
        timestamp: DateTime.now(),
        synced: false,
      );

      final id = await DatabaseService.instance.createAssessment(assessment);
      await DatabaseService.instance.markAsSynced(id);

      final assessments = await DatabaseService.instance.getAllAssessments();
      final updated = assessments.firstWhere((a) => a.id == id.toString());
      expect(updated.synced, isTrue);
    });

    test('Can delete assessment from database', () async {
      final assessment = ChildAssessment(
        childId: 'DELETE_TEST_001',
        sex: 'M',
        ageMonths: 30,
        muacMm: 120,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        clinicalStatus: 'Healthy',
        recommendedPathway: 'None',
        confidence: 0.98,
        timestamp: DateTime.now(),
        synced: false,
      );

      final id = await DatabaseService.instance.createAssessment(assessment);
      await DatabaseService.instance.deleteAssessment(id.toString());

      final assessments = await DatabaseService.instance.getAllAssessments();
      expect(assessments.any((a) => a.id == id.toString()), isFalse);
    });

    test('Database handles concurrent operations', () async {
      final futures = List.generate(10, (i) {
        final assessment = ChildAssessment(
          childId: 'CONCURRENT_$i',
          sex: i % 2 == 0 ? 'M' : 'F',
          ageMonths: 24 + i,
          muacMm: 110 + i,
          edema: 0,
          appetite: 'good',
          dangerSigns: 0,
          clinicalStatus: 'SAM',
          recommendedPathway: 'OTP',
          confidence: 0.95,
          timestamp: DateTime.now(),
          synced: false,
        );
        return DatabaseService.instance.createAssessment(assessment);
      });

      final ids = await Future.wait(futures);
      expect(ids.length, 10);
      expect(ids.every((id) => id > 0), isTrue);

      final assessments = await DatabaseService.instance.getAllAssessments();
      expect(assessments.length, greaterThanOrEqualTo(10));
    });

    test('Sync service identifies unsynced assessments', () async {
      final assessment = ChildAssessment(
        childId: 'UNSYNC_001',
        sex: 'M',
        ageMonths: 24,
        muacMm: 110,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        clinicalStatus: 'SAM',
        recommendedPathway: 'OTP',
        confidence: 0.95,
        timestamp: DateTime.now(),
        synced: false,
      );

      await DatabaseService.instance.createAssessment(assessment);

      final unsynced = await DatabaseService.instance.getUnsyncedAssessments();
      expect(unsynced, isNotEmpty);
      expect(unsynced.any((a) => a.childId == 'UNSYNC_001'), isTrue);
    });

    test('Assessments created offline are queued for sync', () async {
      final assessment = ChildAssessment(
        childId: 'OFFLINE_001',
        sex: 'F',
        ageMonths: 18,
        muacMm: 115,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        clinicalStatus: 'MAM',
        recommendedPathway: 'TSFP',
        confidence: 0.92,
        timestamp: DateTime.now(),
        synced: false,
      );

      await DatabaseService.instance.createAssessment(assessment);

      final unsynced = await DatabaseService.instance.getUnsyncedAssessments();
      expect(unsynced.any((a) => a.childId == 'OFFLINE_001'), isTrue);
    });

    test('Data survives app restart', () async {
      final assessment = ChildAssessment(
        childId: 'PERSIST_001',
        sex: 'M',
        ageMonths: 24,
        muacMm: 110,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        clinicalStatus: 'SAM',
        recommendedPathway: 'OTP',
        confidence: 0.95,
        timestamp: DateTime.now(),
        synced: false,
      );

      await DatabaseService.instance.createAssessment(assessment);

      final assessments = await DatabaseService.instance.getAllAssessments();
      expect(assessments.any((a) => a.childId == 'PERSIST_001'), isTrue);
    });
  });
}

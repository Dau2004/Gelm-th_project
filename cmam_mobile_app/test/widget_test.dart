import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmam_app/main.dart';
import 'package:cmam_app/screens/assessment_screen.dart';
import 'package:cmam_app/screens/result_screen.dart';
import 'package:cmam_app/services/zscore_service.dart';
import 'package:cmam_app/models/child_assessment.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ZScoreService.loadLMSData();
  });

  group('Mobile UI Smoke Tests', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const CMAMApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Assessment screen renders', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AssessmentScreen()));
      await tester.pumpAndSettle();
      
      expect(find.text('Age (months)'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Assessment form has required fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AssessmentScreen()));
      await tester.pumpAndSettle();
      
      expect(find.text('Age (months)'), findsOneWidget);
      expect(find.text('MUAC (mm)'), findsOneWidget);
    });

    testWidgets('Result screen displays data', (WidgetTester tester) async {
      final testAssessment = ChildAssessment(
        childId: 'TEST_001',
        sex: 'M',
        ageMonths: 24,
        muacMm: 105,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        clinicalStatus: 'SAM',
        recommendedPathway: 'SC_ITP',
        confidence: 0.95,
        muacZScore: -3.5,
      );

      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          assessment: testAssessment,
          reasoning: 'Child has severe acute malnutrition based on MUAC < 115mm',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('TEST_001'), findsOneWidget);
      expect(find.textContaining('SAM'), findsOneWidget);
    });

    testWidgets('Form validation triggers on empty submit', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AssessmentScreen()));
      await tester.pumpAndSettle();

      final submitButton = find.text('Calculate Pathway');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsWidgets);
    });
  });
}

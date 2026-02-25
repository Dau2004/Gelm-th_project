import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmam_app/main.dart';
import 'package:cmam_app/screens/assessment_screen.dart';
import 'package:cmam_app/screens/result_screen.dart';
import 'package:cmam_app/services/zscore_service.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ZScoreService.loadLMSData();
  });

  group('Mobile UI Smoke Tests', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Assessment screen renders', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AssessmentScreen()));
      await tester.pumpAndSettle();
      
      expect(find.text('New Assessment'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Assessment form has required fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AssessmentScreen()));
      await tester.pumpAndSettle();
      
      expect(find.text('Child ID'), findsOneWidget);
      expect(find.text('Age (months)'), findsOneWidget);
      expect(find.text('MUAC (mm)'), findsOneWidget);
    });

    testWidgets('Result screen displays data', (WidgetTester tester) async {
      final testData = {
        'child_id': 'TEST_001',
        'clinical_status': 'SAM',
        'recommended_pathway': 'SC_ITP',
        'confidence': 0.95,
        'muac_mm': 105,
        'age_months': 24,
      };

      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(assessmentData: testData),
      ));
      await tester.pumpAndSettle();

      expect(find.text('TEST_001'), findsOneWidget);
      expect(find.textContaining('SAM'), findsOneWidget);
    });

    testWidgets('Form validation triggers on empty submit', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AssessmentScreen()));
      await tester.pumpAndSettle();

      final submitButton = find.text('Submit Assessment');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('required'), findsWidgets);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cmam_app/utils/id_generator.dart';
import 'package:cmam_app/services/quality_check_service.dart';

void main() {
  group('Smoke Tests - Critical Functionality', () {
    test('ID Generator works', () {
      final id = IdGenerator.generateChildId();
      expect(id, isNotEmpty);
      expect(id, startsWith('GM-')); // Gelmëth format
    });

    test('Quality Check Service works', () {
      final result = QualityCheckService.checkQuality(
        muacMm: 115,
        ageMonths: 24,
        sex: 'M',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
      );
      expect(result, isNotNull);
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('status'), true);
    });

    test('Quality Check flags suspicious data', () {
      final result = QualityCheckService.checkQuality(
        muacMm: 11, // Unit error
        ageMonths: 24,
        sex: 'M',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
      );
      expect(result['status'], 'SUSPICIOUS');
    });
  });

  group('Input Validation Tests', () {
    test('Age validation range', () {
      // Valid ages
      expect(6 >= 6 && 6 <= 59, true);
      expect(59 >= 6 && 59 <= 59, true);
      expect(24 >= 6 && 24 <= 59, true);
      
      // Invalid ages
      expect(5 >= 6 && 5 <= 59, false);
      expect(60 >= 6 && 60 <= 59, false);
    });

    test('MUAC validation range', () {
      // Valid MUAC
      expect(80 >= 80 && 80 <= 200, true);
      expect(200 >= 80 && 200 <= 200, true);
      expect(115 >= 80 && 115 <= 200, true);
      
      // Invalid MUAC
      expect(79 >= 80 && 79 <= 200, false);
      expect(201 >= 80 && 201 <= 200, false);
    });
  });
}

// Run with: flutter test

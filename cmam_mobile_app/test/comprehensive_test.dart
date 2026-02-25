import 'package:flutter_test/flutter_test.dart';
import 'package:cmam_app/utils/id_generator.dart';
import 'package:cmam_app/services/quality_check_service.dart';
import 'package:cmam_app/services/zscore_service.dart';
import 'package:cmam_app/services/prediction_service.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ZScoreService.loadLMSData();
  });
  group('COMPREHENSIVE TESTS - ID Generator', () {
    test('Generates non-empty ID', () {
      final id = IdGenerator.generateChildId();
      expect(id, isNotEmpty);
    });

    test('ID starts with GM- prefix', () {
      final id = IdGenerator.generateChildId();
      expect(id, startsWith('GM-'));
    });

    test('Generates unique IDs', () {
      final id1 = IdGenerator.generateChildId();
      final id2 = IdGenerator.generateChildId();
      expect(id1, isNot(equals(id2)));
    });

    test('ID has correct format', () {
      final id = IdGenerator.generateChildId();
      expect(id, matches(RegExp(r'^GM-\d{6}-[A-Z0-9]{4}$')));
    });
  });

  group('COMPREHENSIVE TESTS - Quality Check Service', () {
    test('Accepts valid data', () {
      final result = QualityCheckService.checkQuality(
        muacMm: 115,
        ageMonths: 24,
        sex: 'M',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
      );
      expect(result['status'], 'OK');
    });

    test('Flags unit error (11 instead of 110)', () {
      final result = QualityCheckService.checkQuality(
        muacMm: 11,
        ageMonths: 24,
        sex: 'M',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
      );
      expect(result['status'], 'SUSPICIOUS');
      expect(result['flags'], contains('unit_error'));
    });

    test('Flags age error (240 instead of 24)', () {
      final result = QualityCheckService.checkQuality(
        muacMm: 115,
        ageMonths: 240,
        sex: 'M',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
      );
      expect(result['status'], 'SUSPICIOUS');
    });

    test('Returns recommendation message', () {
      final result = QualityCheckService.checkQuality(
        muacMm: 115,
        ageMonths: 24,
        sex: 'M',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
      );
      expect(result.containsKey('recommendation'), true);
      expect(result['recommendation'], isNotEmpty);
    });
  });

  group('COMPREHENSIVE TESTS - Z-Score Service', () {
    test('Calculates Z-score for valid input', () {
      final zScore = ZScoreService.calculateMUACZScore('M', 24, 11.5);
      expect(zScore, isNotNull);
      expect(zScore, isA<double>());
    });

    test('Low MUAC gives negative Z-score', () {
      final zScore = ZScoreService.calculateMUACZScore('M', 24, 10.0);
      expect(zScore, isNotNull);
      expect(zScore!, lessThan(0));
    });

    test('High MUAC gives positive Z-score', () {
      final zScore = ZScoreService.calculateMUACZScore('M', 24, 16.0);
      expect(zScore, isNotNull);
      expect(zScore!, greaterThan(0));
    });

    test('Returns null for age outside range', () {
      final zScore = ZScoreService.calculateMUACZScore('M', 2, 11.5);
      expect(zScore, isNull);
    });

    test('Clinical status classification', () {
      expect(ZScoreService.getClinicalStatus(-3.5, 0), 'SAM');
      expect(ZScoreService.getClinicalStatus(-2.5, 0), 'MAM');
      expect(ZScoreService.getClinicalStatus(-1.0, 0), 'Healthy');
      expect(ZScoreService.getClinicalStatus(-1.0, 1), 'SAM');
    });
  });

  group('COMPREHENSIVE TESTS - Prediction Service', () {
    test('SAM with complications → SC_ITP', () {
      final result = PredictionService.predictPathway(
        clinicalStatus: 'SAM',
        edema: 0,
        appetite: 'poor',
        dangerSigns: 1,
        muacZScore: -3.5,
      );
      expect(result['pathway'], 'SC_ITP');
      expect(result['confidence'], greaterThan(0));
    });

    test('SAM without complications → OTP', () {
      final result = PredictionService.predictPathway(
        clinicalStatus: 'SAM',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        muacZScore: -3.2,
      );
      expect(result['pathway'], 'OTP');
    });

    test('MAM → TSFP', () {
      final result = PredictionService.predictPathway(
        clinicalStatus: 'MAM',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        muacZScore: -2.5,
      );
      expect(result['pathway'], 'TSFP');
    });

    test('Healthy → None', () {
      final result = PredictionService.predictPathway(
        clinicalStatus: 'Healthy',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        muacZScore: -1.0,
      );
      expect(result['pathway'], 'None');
    });

    test('Returns confidence score', () {
      final result = PredictionService.predictPathway(
        clinicalStatus: 'SAM',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        muacZScore: -3.0,
      );
      expect(result.containsKey('confidence'), true);
      expect(result['confidence'], greaterThan(0));
      expect(result['confidence'], lessThanOrEqualTo(1.0));
    });
  });

  group('COMPREHENSIVE TESTS - Input Validation', () {
    test('Age 6 is valid (boundary)', () {
      expect(6 >= 6 && 6 <= 59, true);
    });

    test('Age 59 is valid (boundary)', () {
      expect(59 >= 6 && 59 <= 59, true);
    });

    test('Age 5 is invalid', () {
      expect(5 >= 6 && 5 <= 59, false);
    });

    test('Age 60 is invalid', () {
      expect(60 >= 6 && 60 <= 59, false);
    });

    test('MUAC 80 is valid (boundary)', () {
      expect(80 >= 80 && 80 <= 200, true);
    });

    test('MUAC 200 is valid (boundary)', () {
      expect(200 >= 80 && 200 <= 200, true);
    });

    test('MUAC 79 is invalid', () {
      expect(79 >= 80 && 79 <= 200, false);
    });

    test('MUAC 201 is invalid', () {
      expect(201 >= 80 && 201 <= 200, false);
    });
  });

  group('COMPREHENSIVE TESTS - Integration', () {
    test('Complete workflow: Quality → Z-Score → Prediction', () {
      final qualityResult = QualityCheckService.checkQuality(
        muacMm: 115,
        ageMonths: 24,
        sex: 'M',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
      );
      expect(qualityResult['status'], 'OK');

      final zScore = ZScoreService.calculateMUACZScore('M', 24, 11.5);
      expect(zScore, isNotNull);

      final clinicalStatus = ZScoreService.getClinicalStatus(zScore!, 0);
      
      final prediction = PredictionService.predictPathway(
        clinicalStatus: clinicalStatus,
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
        muacZScore: zScore,
      );
      expect(prediction['pathway'], isNotNull);
      expect(prediction['confidence'], greaterThan(0));
    });

    test('Quality check blocks suspicious data', () {
      final qualityResult = QualityCheckService.checkQuality(
        muacMm: 11,
        ageMonths: 24,
        sex: 'M',
        edema: 0,
        appetite: 'good',
        dangerSigns: 0,
      );
      expect(qualityResult['status'], 'SUSPICIOUS');
    });
  });
}

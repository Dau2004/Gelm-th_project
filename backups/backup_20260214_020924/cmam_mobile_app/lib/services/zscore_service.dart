import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lms_reference.dart';

class ZScoreService {
  static final Map<String, List<LMSReference>> _lmsData = {
    'M': [],
    'F': [],
  };

  static Future<void> loadLMSData() async {
    final boysJson = await rootBundle.loadString('assets/lms/boys_lms.json');
    final girlsJson = await rootBundle.loadString('assets/lms/girls_lms.json');
    
    final boysList = json.decode(boysJson) as List;
    final girlsList = json.decode(girlsJson) as List;
    
    _lmsData['M'] = boysList.map((item) => LMSReference.fromMap(item)).toList();
    _lmsData['F'] = girlsList.map((item) => LMSReference.fromMap(item)).toList();
  }

  static double? calculateMUACZScore(String sex, int ageMonths, double muacCm) {
    if (ageMonths < 3 || ageMonths > 60) return null;
    
    final lmsTable = _lmsData[sex];
    if (lmsTable == null || lmsTable.isEmpty) return null;

    // Find closest age match
    LMSReference? lms;
    for (var ref in lmsTable) {
      if (ref.month >= ageMonths) {
        lms = ref;
        break;
      }
    }
    lms ??= lmsTable.last;

    // Calculate Z-score using LMS method
    final l = lms.l;
    final m = lms.m;
    final s = lms.s;

    double zScore;
    if (l != 0) {
      zScore = (pow(muacCm / m, l) - 1) / (l * s);
    } else {
      zScore = log(muacCm / m) / s;
    }

    return double.parse(zScore.toStringAsFixed(2));
  }

  static String getClinicalStatus(double? zScore, int edema) {
    if (zScore == null) return 'Unknown';
    
    if (zScore < -3 || edema == 1) {
      return 'SAM';
    } else if (zScore >= -3 && zScore < -2) {
      return 'MAM';
    } else {
      return 'Healthy';
    }
  }
}

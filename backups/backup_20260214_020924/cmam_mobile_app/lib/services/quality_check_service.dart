/// Model 2: Quality Check Service
/// Validates measurement quality before pathway prediction

class QualityCheckService {
  /// Check if measurement is OK or SUSPICIOUS
  static Map<String, dynamic> checkQuality({
    required int muacMm,
    required int ageMonths,
    required String sex,
    required int edema,
    required String appetite,
    required int dangerSigns,
  }) {
    List<String> flags = [];
    String status = 'OK';
    String recommendation = 'Measurement appears valid';
    
    // Rule 1: Unit errors (MUAC too small or too large)
    if (muacMm < 50 || muacMm > 200) {
      flags.add('unit_error');
      status = 'SUSPICIOUS';
      recommendation = '⚠️ Please verify MUAC unit (mm vs cm)';
    }
    
    // Rule 2: Age out of range
    if (ageMonths < 6 || ageMonths > 59) {
      flags.add('age_out_of_range');
      status = 'SUSPICIOUS';
      recommendation = '⚠️ Please verify child age (6-59 months)';
    }
    
    // Rule 3: Invalid appetite
    if (!['good', 'poor', 'failed'].contains(appetite)) {
      flags.add('invalid_appetite');
      status = 'SUSPICIOUS';
      recommendation = '⚠️ Please verify appetite assessment';
    }
    
    // Rule 4: Invalid edema
    if (edema < 0 || edema > 3) {
      flags.add('invalid_edema');
      status = 'SUSPICIOUS';
      recommendation = '⚠️ Please verify edema grade (0-3)';
    }
    
    // Rule 5: Impossible combinations
    if (muacMm > 130 && edema >= 2) {
      flags.add('impossible_combo');
      status = 'SUSPICIOUS';
      recommendation = '⚠️ High MUAC with severe edema is unusual - please re-check';
    }
    
    // Rule 6: Extreme MUAC values
    if (muacMm < 80 && edema == 0) {
      flags.add('extreme_low');
      status = 'SUSPICIOUS';
      recommendation = '⚠️ Very low MUAC - please re-measure carefully';
    }
    
    // Rule 7: Near threshold (borderline cases - just flag, don't block)
    bool nearThreshold = muacMm >= 113 && muacMm <= 117;
    if (nearThreshold && status == 'OK') {
      flags.add('near_threshold');
      recommendation = 'ℹ️ MUAC near threshold - consider re-measuring for accuracy';
    }
    
    return {
      'status': status,
      'flags': flags,
      'recommendation': recommendation,
      'near_threshold': nearThreshold,
    };
  }
  
  /// Get user-friendly message for quality status
  static String getQualityMessage(String status) {
    switch (status) {
      case 'OK':
        return '✅ Measurement quality: Good';
      case 'SUSPICIOUS':
        return '⚠️ Measurement quality: Needs verification';
      default:
        return 'Unknown status';
    }
  }
  
  /// Check if should block progression to pathway prediction
  static bool shouldBlock(Map<String, dynamic> qualityResult) {
    String status = qualityResult['status'];
    List<String> flags = qualityResult['flags'];
    
    // Block if critical errors
    List<String> criticalFlags = ['unit_error', 'age_out_of_range', 'impossible_combo'];
    bool hasCriticalError = flags.any((flag) => criticalFlags.contains(flag));
    
    return status == 'SUSPICIOUS' && hasCriticalError;
  }
  
  /// Get detailed explanation for flags
  static String getDetailedExplanation(List<String> flags) {
    if (flags.isEmpty) {
      return 'All checks passed';
    }
    
    Map<String, String> explanations = {
      'unit_error': 'MUAC value suggests possible unit conversion error (mm vs cm)',
      'age_out_of_range': 'Age is outside CMAM target range (6-59 months)',
      'invalid_appetite': 'Appetite value is not recognized',
      'invalid_edema': 'Edema grade is invalid',
      'impossible_combo': 'High MUAC with severe edema is clinically unusual',
      'extreme_low': 'MUAC is extremely low - verify measurement',
      'near_threshold': 'MUAC is near classification threshold',
    };
    
    return flags.map((flag) => '• ${explanations[flag] ?? flag}').join('\n');
  }
}

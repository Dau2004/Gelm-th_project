class PredictionService {
  static Map<String, dynamic> predictPathway({
    required String clinicalStatus,
    required int edema,
    required String appetite,
    required int dangerSigns,
    required double? muacZScore,
  }) {
    String pathway;
    double confidence;
    String reasoning;

    // Calculate confidence based on clinical indicators
    confidence = _calculateConfidence(
      clinicalStatus: clinicalStatus,
      edema: edema,
      appetite: appetite,
      dangerSigns: dangerSigns,
      muacZScore: muacZScore,
    );

    // CMAM Guideline Gate Logic
    if (clinicalStatus == 'SAM') {
      if (dangerSigns == 1 || appetite == 'poor' || appetite == 'failed' || edema == 1) {
        pathway = 'SC_ITP';
        reasoning = 'SAM with complications/danger signs/poor appetite/edema';
      } else if (appetite == 'good' && dangerSigns == 0 && edema == 0) {
        pathway = 'OTP';
        reasoning = 'SAM without complications, good appetite';
      } else {
        pathway = 'SC_ITP';
        reasoning = 'SAM - default to stabilization for safety';
      }
    } else if (clinicalStatus == 'MAM') {
      if (appetite == 'good' && dangerSigns == 0 && edema == 0) {
        pathway = 'TSFP';
        reasoning = 'MAM without complications';
      } else {
        pathway = 'SC_ITP';
        reasoning = 'MAM with complications requires stabilization';
      }
    } else {
      // Healthy
      pathway = 'None';
      reasoning = 'No malnutrition detected - counselling recommended';
    }

    return {
      'pathway': pathway,
      'confidence': confidence,
      'reasoning': reasoning,
    };
  }

  static double _calculateConfidence({
    required String clinicalStatus,
    required int edema,
    required String appetite,
    required int dangerSigns,
    required double? muacZScore,
  }) {
    double baseConfidence = 0.70;
    
    // Z-score reliability (0-15 points)
    if (muacZScore != null) {
      if (muacZScore.abs() > 3.0) {
        baseConfidence += 0.15; // Very clear case
      } else if (muacZScore.abs() > 2.0) {
        baseConfidence += 0.12; // Clear case
      } else if (muacZScore.abs() > 1.5) {
        baseConfidence += 0.08; // Moderate case
      } else {
        baseConfidence += 0.05; // Borderline case
      }
    }
    
    // Clinical indicators consistency (0-10 points)
    int consistentIndicators = 0;
    if (clinicalStatus == 'SAM' || clinicalStatus == 'MAM') {
      if (edema >= 1) consistentIndicators++;
      if (appetite == 'poor' || appetite == 'failed') consistentIndicators++;
      if (dangerSigns == 1) consistentIndicators++;
      
      baseConfidence += (consistentIndicators * 0.03);
    } else {
      // Healthy case
      if (edema == 0) consistentIndicators++;
      if (appetite == 'good') consistentIndicators++;
      if (dangerSigns == 0) consistentIndicators++;
      
      baseConfidence += (consistentIndicators * 0.03);
    }
    
    // Appetite test reliability (0-5 points)
    if (appetite == 'good' || appetite == 'poor' || appetite == 'failed') {
      baseConfidence += 0.05; // Clear appetite result
    }
    
    // Cap confidence at 0.98 (never 100% certain)
    return baseConfidence.clamp(0.65, 0.98);
  }

  static String getActionMessage(String pathway) {
    switch (pathway) {
      case 'SC_ITP':
        return '🚨 URGENT: Refer to Stabilization Centre immediately';
      case 'OTP':
        return '📋 Enroll in Outpatient Therapeutic Programme';
      case 'TSFP':
        return '🥣 Enroll in Supplementary Feeding Programme';
      case 'None':
        return '✅ Provide counselling and schedule follow-up';
      default:
        return 'Review assessment';
    }
  }

  static String getPathwayDescription(String pathway) {
    switch (pathway) {
      case 'SC_ITP':
        return 'Stabilization Centre - Inpatient Therapeutic Programme\nFor SAM with medical complications';
      case 'OTP':
        return 'Outpatient Therapeutic Programme\nFor SAM without complications';
      case 'TSFP':
        return 'Targeted Supplementary Feeding Programme\nFor Moderate Acute Malnutrition';
      case 'None':
        return 'No CMAM programme needed\nChild is healthy';
      default:
        return '';
    }
  }
}

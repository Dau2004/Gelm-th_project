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

    // CMAM Guideline Gate Logic
    if (clinicalStatus == 'SAM') {
      if (dangerSigns == 1 || appetite == 'poor' || appetite == 'failed' || edema == 1) {
        pathway = 'SC_ITP';
        confidence = 0.95;
        reasoning = 'SAM with complications/danger signs/poor appetite/edema';
      } else if (appetite == 'good' && dangerSigns == 0 && edema == 0) {
        pathway = 'OTP';
        confidence = 0.90;
        reasoning = 'SAM without complications, good appetite';
      } else {
        pathway = 'SC_ITP';
        confidence = 0.75;
        reasoning = 'SAM - default to stabilization for safety';
      }
    } else if (clinicalStatus == 'MAM') {
      if (appetite == 'good' && dangerSigns == 0 && edema == 0) {
        pathway = 'TSFP';
        confidence = 0.92;
        reasoning = 'MAM without complications';
      } else {
        pathway = 'SC_ITP';
        confidence = 0.80;
        reasoning = 'MAM with complications requires stabilization';
      }
    } else {
      // Healthy
      pathway = 'None';
      confidence = 0.95;
      reasoning = 'No malnutrition detected - counselling recommended';
    }

    return {
      'pathway': pathway,
      'confidence': confidence,
      'reasoning': reasoning,
    };
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

class ChildAssessment {
  final String? id;
  final String childId;
  final String sex;
  final int ageMonths;
  final int muacMm;
  final int edema;
  final String appetite;
  final int dangerSigns;
  final double? muacZScore;
  final String? clinicalStatus;
  final String? recommendedPathway;
  final double? confidence;
  final DateTime timestamp;
  final bool synced;
  
  // Location & CHW Information
  final String? facility;
  final String? state;
  final String? county;
  final String? chwName;
  final String? chwPhone;
  final String? chwNotes;
  final String? chwSignature;
  final String? chwUsername;

  ChildAssessment({
    this.id,
    required this.childId,
    required this.sex,
    required this.ageMonths,
    required this.muacMm,
    required this.edema,
    required this.appetite,
    required this.dangerSigns,
    this.muacZScore,
    this.clinicalStatus,
    this.recommendedPathway,
    this.confidence,
    DateTime? timestamp,
    this.synced = false,
    this.facility,
    this.state,
    this.county,
    this.chwName,
    this.chwPhone,
    this.chwNotes,
    this.chwSignature,
    this.chwUsername,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'child_id': childId,
      'sex': sex,
      'age_months': ageMonths,
      'muac_mm': muacMm,
      'edema': edema,
      'appetite': appetite,
      'danger_signs': dangerSigns,
      'muac_z_score': muacZScore,
      'clinical_status': clinicalStatus,
      'recommended_pathway': recommendedPathway,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
    
    if (id != null) map['id'] = id;
    
    // Only add non-null optional fields
    if (facility != null) map['facility'] = facility;
    if (state != null) map['state'] = state;
    if (county != null) map['county'] = county;
    if (chwName != null) map['chw_name'] = chwName;
    if (chwPhone != null) map['chw_phone'] = chwPhone;
    if (chwNotes != null) map['chw_notes'] = chwNotes;
    if (chwSignature != null) map['chw_signature'] = chwSignature;
    if (chwUsername != null) map['chw_username'] = chwUsername;
    
    return map;
  }

  Map<String, dynamic> toApiMap() {
    final map = <String, dynamic>{
      'child_id': childId,
      'sex': sex,
      'age_months': ageMonths,
      'muac_mm': muacMm,
      'edema': edema,
      'appetite': appetite,
      'danger_signs': dangerSigns,
      'muac_z_score': muacZScore,
      'clinical_status': clinicalStatus,
      'recommended_pathway': recommendedPathway,
      'confidence': confidence,
    };
    
    // Only add non-null optional fields
    if (facility != null) map['facility'] = facility;
    if (state != null) map['state'] = state;
    if (county != null) map['county'] = county;
    if (chwName != null) map['chw_name'] = chwName;
    if (chwPhone != null) map['chw_phone'] = chwPhone;
    if (chwNotes != null) map['chw_notes'] = chwNotes;
    if (chwSignature != null) map['chw_signature'] = chwSignature;
    if (chwUsername != null) map['chw_username'] = chwUsername;
    
    return map;
  }

  factory ChildAssessment.fromMap(Map<String, dynamic> map) {
    return ChildAssessment(
      id: map['id']?.toString(),
      childId: map['child_id'],
      sex: map['sex'],
      ageMonths: map['age_months'],
      muacMm: map['muac_mm'],
      edema: map['edema'],
      appetite: map['appetite'],
      dangerSigns: map['danger_signs'],
      muacZScore: map['muac_z_score']?.toDouble(),
      clinicalStatus: map['clinical_status'],
      recommendedPathway: map['recommended_pathway'],
      confidence: map['confidence']?.toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
      facility: map['facility'],
      state: map['state'],
      county: map['county'],
      chwName: map['chw_name'],
      chwPhone: map['chw_phone'],
      chwNotes: map['chw_notes'],
      chwSignature: map['chw_signature'],
      chwUsername: map['chw_username'],
    );
  }
}

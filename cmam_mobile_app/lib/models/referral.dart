class Referral {
  final String? id;
  final String assessmentId;
  final String childId;
  final String pathway;
  final String status;
  final String? notes;
  final DateTime timestamp;
  final bool synced;
  final String? chwUsername;

  Referral({
    this.id,
    required this.assessmentId,
    required this.childId,
    required this.pathway,
    this.status = 'pending',
    this.notes,
    DateTime? timestamp,
    this.synced = false,
    this.chwUsername,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assessment_id': assessmentId,
      'child_id': childId,
      'pathway': pathway,
      'status': status,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
      'chw_username': chwUsername,
    };
  }

  Map<String, dynamic> toApiMap() {
    return {
      'child_id': childId,
      'pathway': pathway,
      'status': status,
      'notes': notes,
    };
  }

  factory Referral.fromMap(Map<String, dynamic> map) {
    return Referral(
      id: map['id']?.toString(),
      assessmentId: map['assessment_id'],
      childId: map['child_id'],
      pathway: map['pathway'],
      status: map['status'] ?? 'pending',
      notes: map['notes'],
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
      chwUsername: map['chw_username'],
    );
  }
}

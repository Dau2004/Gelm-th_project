class LMSReference {
  final int month;
  final double l;
  final double m;
  final double s;

  LMSReference({
    required this.month,
    required this.l,
    required this.m,
    required this.s,
  });

  factory LMSReference.fromMap(Map<String, dynamic> map) {
    return LMSReference(
      month: map['Month'],
      l: map['L'].toDouble(),
      m: map['M'].toDouble(),
      s: map['S'].toDouble(),
    );
  }
}

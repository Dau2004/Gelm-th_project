import 'dart:math';

class IdGenerator {
  static String generateChildId() {
    final now = DateTime.now();
    final random = Random();
    
    // Format: GM-YYMMDD-XXXX
    // GM = Gelmath
    // YYMMDD = Date
    // XXXX = Random 4-digit number
    
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final randomNum = (1000 + random.nextInt(9000)).toString();
    
    return 'GM-$year$month$day-$randomNum';
  }
  
  static String generateAssessmentId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    return 'ASS-$timestamp';
  }
}

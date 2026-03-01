import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Privacy Policy & Terms'),
        backgroundColor: const Color(0xFF0E4D34),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(
              '1. Ethical Considerations & Overview',
              'This application is a Community-based Management of Acute Malnutrition (CMAM) System designed to support Community Health Workers (CHWs), doctors, and Ministry of Health officials in identifying and managing acute malnutrition in children aged 6-59 months in South Sudan.\n\nThe system utilizes anthropometric measurements, clinical observations, and WHO-compliant Z-score calculations to generate predictive care pathway recommendations (SC-ITP, OTP, TSFP) and quality assessments of measurements.',
            ),
            _buildSection(
              '2. Data Privacy & Confidentiality',
              'The system processes only essential clinical data:\n\n• Anthropometric: MUAC, Age (6-59 months), Sex\n• Clinical: Edema grade, Appetite status, Danger signs\n• Metadata: Assessment date, location, CHW identifier\n\nChild anonymity is protected through unique Child IDs—no names or national IDs required.\n\nSecurity Measures:\n• Encryption: AES-256 (at rest), TLS 1.3 (in transit)\n• Authentication: PBKDF2-SHA256 password hashing, JWT tokens\n• Access Control: Role-based permissions\n• Offline Security: Local SQLite encryption with secure sync',
            ),
            _buildSection(
              '3. Child Welfare & Clinical Sensitivity',
              'Support, Not Stigmatization: This system is a clinical decision support tool, not a punitive or discriminatory instrument.\n\nKey Principles:\n• Probabilistic Outputs: Confidence scores (0-100%), not absolute diagnoses\n• Clinical Override: Healthcare providers retain full authority to override recommendations\n• Quality Gatekeeper: Model 2 flags suspicious measurements to prevent errors\n• Child Safety First: Danger signs trigger immediate referral protocols',
            ),
            _buildWarningSection(
              '4. Disclaimer & Limitations',
              'CRITICAL: This system is not perfect and should be used with care. The predictions are useful indicators, not absolute medical diagnoses.\n\nNever make clinical decisions based solely on system output. Healthcare providers must use professional judgment, consider complete context, and prioritize child safety over system recommendations.\n\nSpecific Limitations:\n• Measurement Dependency: Accuracy depends on correct MUAC technique\n• Feature Limitations: Does not incorporate household food security or comorbidities\n• Offline Constraints: Static models—cannot learn from new cases without retraining',
            ),
            _buildSection(
              '5. Terms of Use',
              'For Healthcare Providers:\n• Maintain strict confidentiality of all child health data\n• Use predictions as decision support, not replacement for clinical assessment\n• Ensure accurate data entry with calibrated equipment\n• Act promptly on danger signs and severe cases\n• Report system errors or ethical concerns immediately\n\nProhibited Uses:\n• De-anonymization of child identities\n• Unauthorized credential sharing or data export\n• Commercial use without explicit approval\n• Discrimination based on system outputs',
            ),
            _buildSection(
              '6. Contact & Support',
              'Technical Support:\nEmail: support@gelmath-southsudan.org\n\nData Privacy Concerns:\nEmail: privacy@gelmath-southsudan.org\n\nClinical Questions:\nRefer to CMAM Guidelines or facility supervisor\n\nEthical Concerns:\nMinistry of Health Ethics Committee',
            ),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E4D34), Color(0xFF1a7a52)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.shield, color: Colors.white, size: 48),
          SizedBox(height: 12),
          Text(
            'Privacy Policy & Terms of Use',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Gelmëth - CMAM System',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E4D34),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFEF4444), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF991B1B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            'Last Updated: February 14, 2026 | Version: 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '© 2026 Gelmëth. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

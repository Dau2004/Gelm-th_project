import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/zscore_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalAssessments = 0;
  int _samCases = 0;
  int _mamCases = 0;
  int _pendingReferrals = 0;

  @override
  void initState() {
    super.initState();
    _loadLMSData();
    _loadStats();
  }

  Future<void> _loadLMSData() async {
    await ZScoreService.loadLMSData();
  }

  Future<void> _loadStats() async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return;
    
    final username = user['username'];
    if (username == null || username.isEmpty) return;
    
    final assessments = await DatabaseService.instance.getAssessmentsByUsername(username);
    final referrals = await DatabaseService.instance.getReferralsByUsername(username);
    
    setState(() {
      _totalAssessments = assessments.length;
      _samCases = assessments.where((a) => a.clinicalStatus == 'SAM').length;
      _mamCases = assessments.where((a) => a.clinicalStatus == 'MAM').length;
      _pendingReferrals = referrals.where((r) => r.status == 'pending').length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CMAM Care Pathway',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5F3F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Community Health Worker Dashboard',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/child_image.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total', _totalAssessments.toString(), Icons.assessment)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('SAM', _samCases.toString(), Icons.warning)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard('MAM', _mamCases.toString(), Icons.info)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Referrals', _pendingReferrals.toString(), Icons.local_hospital)),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D5F3F)),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'Screen New Child',
                'Assess malnutrition status',
                Icons.child_care,
                () => Navigator.pushNamed(context, '/assessment'),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                'View Referrals',
                'Manage pending cases',
                Icons.local_hospital,
                () => Navigator.pushNamed(context, '/referrals'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      color: const Color(0xFF2D5F3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: const Color(0xFF2D5F3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

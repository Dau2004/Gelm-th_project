import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/referral.dart';
import '../models/child_assessment.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  List<Referral> _referrals = [];
  Map<String, ChildAssessment> _assessments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService.getCurrentUser();
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final username = user['username'];
    if (username == null || username.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    
    final referrals = await DatabaseService.instance.getReferralsByUsername(username);
    final assessments = await DatabaseService.instance.getAssessmentsByUsername(username);
    
    final assessmentMap = <String, ChildAssessment>{};
    for (var assessment in assessments) {
      assessmentMap[assessment.id ?? ''] = assessment;
    }
    
    setState(() {
      _referrals = referrals;
      _assessments = assessmentMap;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    await DatabaseService.instance.updateReferralStatus(id, status);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _referrals.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _referrals.length,
                  itemBuilder: (context, index) {
                    final referral = _referrals[index];
                    final assessment = _assessments[referral.assessmentId];
                    return _buildReferralCard(referral, assessment);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_hospital_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No referrals yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildReferralCard(Referral referral, ChildAssessment? assessment) {
    final isUrgent = referral.pathway == 'SC_ITP';
    final statusColor = referral.status == 'pending' ? Colors.orange : Colors.green;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  referral.childId,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    referral.pathway,
                    style: TextStyle(
                      color: isUrgent ? Colors.red[900] : Colors.blue[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (assessment != null) ...[
              Row(
                children: [
                  _buildInfoChip(Icons.person, assessment.sex == 'M' ? 'Boy' : 'Girl'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.calendar_today, '${assessment.ageMonths}m'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.straighten, '${assessment.muacMm}mm'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Z-Score: ${assessment.muacZScore?.toStringAsFixed(2) ?? 'N/A'} | ${assessment.clinicalStatus}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            if (referral.notes != null) ...[
              const SizedBox(height: 8),
              Text(referral.notes!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      referral.status.toUpperCase(),
                      style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  DateFormat('MMM dd, HH:mm').format(referral.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (referral.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateStatus(referral.id!, 'completed'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Complete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateStatus(referral.id!, 'cancelled'),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

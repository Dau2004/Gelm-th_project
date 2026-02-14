import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/child_assessment.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'medical_document_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ChildAssessment> _assessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
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
    
    final assessments = await DatabaseService.instance.getAssessmentsByUsername(username);
    setState(() {
      _assessments = assessments;
      _isLoading = false;
    });
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all assessment records? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clearHistory();
    }
  }

  Future<void> _clearHistory() async {
    setState(() => _isLoading = true);
    
    for (final assessment in _assessments) {
      if (assessment.id != null) {
        await DatabaseService.instance.deleteAssessment(assessment.id!);
      }
    }
    
    await _loadAssessments();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _assessments.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  if (_assessments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: _confirmClearHistory,
                            icon: const Icon(Icons.delete_sweep, color: Colors.red),
                            label: const Text('Clear History', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _assessments.length,
                      itemBuilder: (context, index) {
                        return _buildAssessmentCard(_assessments[index]);
                      },
                    ),
                  ),
                ],
              );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No assessments yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(ChildAssessment assessment) {
    final pathway = assessment.recommendedPathway ?? 'None';
    final isUrgent = pathway == 'SC_ITP';
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicalDocumentScreen(
                assessment: assessment,
                reasoning: _getReasoningText(assessment),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  assessment.childId,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pathway,
                    style: TextStyle(
                      color: isUrgent ? Colors.red[900] : Colors.green[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  Icons.person,
                  assessment.sex == 'M' ? 'Boy' : 'Girl',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.calendar_today,
                  '${assessment.ageMonths}m',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.straighten,
                  '${assessment.muacMm}mm',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Z-Score: ${assessment.muacZScore?.toStringAsFixed(2) ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  assessment.clinicalStatus ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(assessment.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      assessment.synced ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: assessment.synced ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      assessment.synced ? 'Synced' : 'Local',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _getReasoningText(ChildAssessment assessment) {
    final status = assessment.clinicalStatus ?? 'Unknown';
    final pathway = assessment.recommendedPathway ?? 'None';
    
    if (status == 'SAM') {
      if (pathway == 'SC_ITP') {
        return 'SAM with complications/danger signs/poor appetite/edema';
      } else {
        return 'SAM without complications, good appetite';
      }
    } else if (status == 'MAM') {
      return 'MAM without complications';
    } else {
      return 'No malnutrition detected - counselling recommended';
    }
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

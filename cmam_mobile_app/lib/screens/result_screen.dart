import 'package:flutter/material.dart';
import '../models/child_assessment.dart';
import '../services/prediction_service.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../models/referral.dart';

class ResultScreen extends StatefulWidget {
  final ChildAssessment assessment;
  final String reasoning;

  const ResultScreen({
    super.key,
    required this.assessment,
    required this.reasoning,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _syncToBackend();
  }

  Future<void> _syncToBackend() async {
    setState(() => _isSyncing = true);
    final result = await ApiService.syncAssessment(widget.assessment);
    setState(() => _isSyncing = false);
    
    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Assessment synced to MoH Dashboard'),
            backgroundColor: Color(0xFF2ECC71),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠ Sync failed - Please login first'),
            backgroundColor: Color(0xFFE67E22),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pathway = widget.assessment.recommendedPathway ?? 'None';
    final isUrgent = pathway == 'SC_ITP';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Assessment Result'),
        automaticallyImplyLeading: false,
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(isUrgent),
            const SizedBox(height: 24),
            _buildInfoCard('Child Information', [
              _buildInfoRow('Child ID', widget.assessment.childId),
              _buildInfoRow('Sex', widget.assessment.sex == 'M' ? 'Boy' : 'Girl'),
              _buildInfoRow('Age', '${widget.assessment.ageMonths} months'),
              _buildInfoRow('MUAC', '${widget.assessment.muacMm} mm (${(widget.assessment.muacMm / 10).toStringAsFixed(1)} cm)'),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Clinical Assessment', [
              _buildInfoRow('MUAC Z-Score', widget.assessment.muacZScore?.toStringAsFixed(2) ?? 'N/A'),
              _buildInfoRow('Status', widget.assessment.clinicalStatus ?? 'Unknown'),
              _buildInfoRow('Edema', widget.assessment.edema == 1 ? 'Yes' : 'No'),
              _buildInfoRow('Appetite', widget.assessment.appetite),
              _buildInfoRow('Danger Signs', widget.assessment.dangerSigns == 1 ? 'Yes' : 'No'),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Recommendation', [
              _buildInfoRow('Programme', pathway),
              _buildInfoRow('Confidence', '${(widget.assessment.confidence! * 100).toStringAsFixed(0)}%'),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2ECC71), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF2ECC71),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Reasoning',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0E4D34),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.reasoning,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(context, pathway, isUrgent),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF0E4D34), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 16, color: Color(0xFF0E4D34), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isUrgent) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71)).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71)).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUrgent ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              size: 64,
              color: isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.assessment.recommendedPathway ?? 'None',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF0E4D34),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PredictionService.getPathwayDescription(widget.assessment.recommendedPathway ?? 'None'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E4D34),
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String pathway, bool isUrgent) {
    return ElevatedButton(
      onPressed: () async {
        if (pathway != 'None') {
          final referral = Referral(
            assessmentId: widget.assessment.id ?? '',
            childId: widget.assessment.childId,
            pathway: pathway,
            notes: widget.reasoning,
          );
          await DatabaseService.instance.createReferral(referral);
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(PredictionService.getActionMessage(pathway)),
              backgroundColor: isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF0E4D34),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF0E4D34),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        pathway != 'None' ? 'Create Referral' : 'Complete Assessment',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}

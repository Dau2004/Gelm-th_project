import 'package:flutter/material.dart';
import '../models/child_assessment.dart';
import '../models/referral.dart';
import '../services/database_service.dart';
import '../services/zscore_service.dart';
import '../services/prediction_service.dart';
import '../services/quality_check_service.dart';
import '../services/auth_service.dart';
import 'medical_document_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final int ageMonths;
  final int muacMm;
  final String sex;
  final int edema;
  final String appetite;
  final int dangerSigns;
  final String childId;
  final String? facility;
  final String? state;
  final String? chwName;
  final String? chwPhone;

  const ProcessingScreen({
    super.key,
    required this.ageMonths,
    required this.muacMm,
    required this.sex,
    required this.edema,
    required this.appetite,
    required this.dangerSigns,
    required this.childId,
    this.facility,
    this.state,
    this.chwName,
    this.chwPhone,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int _currentStep = 0;
  String _currentMessage = 'Initializing...';
  Map<String, dynamic>? _qualityResult;
  double? _zScore;
  String? _clinicalStatus;
  Map<String, dynamic>? _pathwayResult;

  @override
  void initState() {
    super.initState();
    _processAssessment();
  }

  Future<void> _processAssessment() async {
    // Step 1: Quality Check
    setState(() {
      _currentStep = 1;
      _currentMessage = 'Running quality check on measurements...';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    
    final qualityCheck = QualityCheckService.checkQuality(
      muacMm: widget.muacMm,
      ageMonths: widget.ageMonths,
      sex: widget.sex,
      edema: widget.edema,
      appetite: widget.appetite,
      dangerSigns: widget.dangerSigns,
    );
    
    setState(() => _qualityResult = qualityCheck);
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 2: Z-Score Calculation
    setState(() {
      _currentStep = 2;
      _currentMessage = 'Calculating MUAC Z-score from WHO tables...';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    
    final muacCm = widget.muacMm / 10.0;
    final zScore = ZScoreService.calculateMUACZScore(widget.sex, widget.ageMonths, muacCm);
    
    setState(() => _zScore = zScore);
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 3: Clinical Status
    setState(() {
      _currentStep = 3;
      _currentMessage = 'Determining clinical status...';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    
    final clinicalStatus = ZScoreService.getClinicalStatus(zScore, widget.edema);
    
    setState(() => _clinicalStatus = clinicalStatus);
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 4: Pathway Recommendation
    setState(() {
      _currentStep = 4;
      _currentMessage = 'AI model recommending care pathway...';
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final prediction = PredictionService.predictPathway(
      clinicalStatus: clinicalStatus,
      edema: widget.edema,
      appetite: widget.appetite,
      dangerSigns: widget.dangerSigns,
      muacZScore: zScore,
    );
    
    setState(() => _pathwayResult = prediction);
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 5: Save to Database
    setState(() {
      _currentStep = 5;
      _currentMessage = 'Saving assessment...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    final assessment = ChildAssessment(
      childId: widget.childId,
      sex: widget.sex,
      ageMonths: widget.ageMonths,
      muacMm: widget.muacMm,
      edema: widget.edema,
      appetite: widget.appetite,
      dangerSigns: widget.dangerSigns,
      muacZScore: zScore,
      clinicalStatus: clinicalStatus,
      recommendedPathway: prediction['pathway'],
      confidence: prediction['confidence'],
      facility: widget.facility,
      state: widget.state,
      chwName: widget.chwName,
      chwPhone: widget.chwPhone,
      chwUsername: (await AuthService.getCurrentUser())?['username'],
    );

    final id = await DatabaseService.instance.createAssessment(assessment);
    
    // Auto-create referral for SC_ITP cases
    if (prediction['pathway'] == 'SC_ITP') {
      final referral = Referral(
        assessmentId: id.toString(),
        childId: widget.childId,
        pathway: 'SC_ITP',
        status: 'pending',
        notes: 'URGENT: SAM with complications - requires immediate stabilization centre admission',
        timestamp: DateTime.now(),
      );
      await DatabaseService.instance.createReferral(referral);
    }
    
    final assessmentWithId = ChildAssessment(
      id: id.toString(),
      childId: assessment.childId,
      sex: assessment.sex,
      ageMonths: assessment.ageMonths,
      muacMm: assessment.muacMm,
      edema: assessment.edema,
      appetite: assessment.appetite,
      dangerSigns: assessment.dangerSigns,
      muacZScore: assessment.muacZScore,
      clinicalStatus: assessment.clinicalStatus,
      recommendedPathway: assessment.recommendedPathway,
      confidence: assessment.confidence,
      timestamp: assessment.timestamp,
      synced: assessment.synced,
      facility: assessment.facility,
      state: assessment.state,
      county: assessment.county,
      chwName: assessment.chwName,
      chwPhone: assessment.chwPhone,
      chwUsername: assessment.chwUsername,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MedicalDocumentScreen(
            assessment: assessmentWithId,
            reasoning: prediction['reasoning'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Assessment'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5F3F)),
            ),
            const SizedBox(height: 32),
            Text(
              _currentMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Expanded(
              child: ListView(
                children: [
                  _buildStep(
                    1,
                    'Quality Check',
                    'Validating measurement quality',
                    _qualityResult != null ? '✓ ${_qualityResult!['status']}' : null,
                  ),
                  _buildStep(
                    2,
                    'WHO Z-Score',
                    'Calculating MUAC-for-age Z-score',
                    _zScore != null ? '✓ Z-score: ${_zScore!.toStringAsFixed(2)}' : null,
                  ),
                  _buildStep(
                    3,
                    'Clinical Status',
                    'Determining nutritional status',
                    _clinicalStatus != null ? '✓ $_clinicalStatus' : null,
                  ),
                  _buildStep(
                    4,
                    'AI Recommendation',
                    'Predicting care pathway',
                    _pathwayResult != null ? '✓ ${_pathwayResult!['pathway']}' : null,
                  ),
                  _buildStep(
                    5,
                    'Save Assessment',
                    'Storing to local database',
                    _currentStep > 4 ? '✓ Saved' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step, String title, String subtitle, String? result) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    
    return Card(
      elevation: isActive ? 4 : 1,
      color: isActive ? const Color(0xFF2D5F3F).withOpacity(0.1) : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted 
              ? Colors.green 
              : isActive 
                  ? const Color(0xFF2D5F3F) 
                  : Colors.grey[300],
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text(
                  step.toString(),
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFF2D5F3F) : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (result != null) ...[
              const SizedBox(height: 4),
              Text(
                result,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        trailing: isActive
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
      ),
    );
  }
}

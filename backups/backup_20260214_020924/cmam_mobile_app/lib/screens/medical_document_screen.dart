import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/child_assessment.dart';
import '../services/database_service.dart';
import 'doctor_selection_screen.dart';

class MedicalDocumentScreen extends StatefulWidget {
  final ChildAssessment assessment;
  final String reasoning;

  const MedicalDocumentScreen({
    super.key,
    required this.assessment,
    required this.reasoning,
  });

  @override
  State<MedicalDocumentScreen> createState() => _MedicalDocumentScreenState();
}

class _MedicalDocumentScreenState extends State<MedicalDocumentScreen> {
  late TextEditingController _pathwayController;
  late TextEditingController _notesController;
  late TextEditingController _chwNotesController;
  late TextEditingController _chwNameController;
  late TextEditingController _chwSignatureController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pathwayController = TextEditingController(text: widget.assessment.recommendedPathway);
    _notesController = TextEditingController(text: widget.reasoning);
    _chwNotesController = TextEditingController(text: widget.assessment.chwNotes ?? '');
    _chwNameController = TextEditingController(text: widget.assessment.chwName ?? '');
    _chwSignatureController = TextEditingController(text: widget.assessment.chwSignature ?? '');
  }

  @override
  void dispose() {
    _pathwayController.dispose();
    _notesController.dispose();
    _chwNotesController.dispose();
    _chwNameController.dispose();
    _chwSignatureController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    
    final chwNotesValue = _chwNotesController.text.trim();
    final chwSignatureValue = _chwSignatureController.text.trim();
    final chwNameValue = _chwNameController.text.trim();
    
    // Update assessment with CHW notes and signature
    final updatedAssessment = ChildAssessment(
      id: widget.assessment.id,
      childId: widget.assessment.childId,
      sex: widget.assessment.sex,
      ageMonths: widget.assessment.ageMonths,
      muacMm: widget.assessment.muacMm,
      edema: widget.assessment.edema,
      appetite: widget.assessment.appetite,
      dangerSigns: widget.assessment.dangerSigns,
      muacZScore: widget.assessment.muacZScore,
      clinicalStatus: widget.assessment.clinicalStatus,
      recommendedPathway: _pathwayController.text,
      confidence: widget.assessment.confidence,
      timestamp: widget.assessment.timestamp,
      synced: false,
      facility: widget.assessment.facility,
      state: widget.assessment.state,
      county: widget.assessment.county,
      chwName: chwNameValue.isEmpty ? widget.assessment.chwName : chwNameValue,
      chwPhone: widget.assessment.chwPhone,
      chwNotes: chwNotesValue.isEmpty ? null : chwNotesValue,
      chwSignature: chwSignatureValue.isEmpty ? null : chwSignatureValue,
    );

    await DatabaseService.instance.updateAssessment(updatedAssessment);
    
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medical Documentation'),
          backgroundColor: const Color(0xFF2D5F3F),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
            },
          ),
          actions: [
          if (_isEditing)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveChanges,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2D5F3F), const Color(0xFF1A3A28)],
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.description, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Gelmäth ASSESSMENT FORM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'South Sudan CMAM Guidelines 2017',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document Info
                  _buildSection(
                    'DOCUMENT INFORMATION',
                    [
                      _buildInfoRow('Assessment ID', widget.assessment.id?.toString() ?? 'N/A'),
                      _buildInfoRow('Date & Time', DateFormat('dd MMM yyyy, HH:mm').format(widget.assessment.timestamp)),
                      _buildInfoRow('Facility', widget.assessment.facility ?? 'Not specified'),
                      _buildInfoRow('State', widget.assessment.state ?? 'Not specified'),
                      _buildInfoRow('CHW Name', widget.assessment.chwName ?? 'Not specified'),
                      _buildInfoRow('CHW Phone', widget.assessment.chwPhone ?? 'Not specified'),
                    ],
                  ),

                  const Divider(height: 40, thickness: 2),

                  // Patient Information
                  _buildSection(
                    'PATIENT INFORMATION',
                    [
                      _buildInfoRow('Child ID', widget.assessment.childId, highlight: true),
                      _buildInfoRow('Age', '${widget.assessment.ageMonths} months'),
                      _buildInfoRow('Sex', widget.assessment.sex == 'M' ? 'Male' : 'Female'),
                    ],
                  ),

                  const Divider(height: 40, thickness: 2),

                  // Anthropometric Measurements
                  _buildSection(
                    'ANTHROPOMETRIC MEASUREMENTS',
                    [
                      _buildInfoRow('MUAC', '${widget.assessment.muacMm} mm (${(widget.assessment.muacMm / 10).toStringAsFixed(1)} cm)'),
                      _buildInfoRow('MUAC Z-Score', widget.assessment.muacZScore?.toStringAsFixed(2) ?? 'N/A'),
                      _buildInfoRow('Edema', _getEdemaText(widget.assessment.edema)),
                    ],
                  ),

                  const Divider(height: 40, thickness: 2),

                  // Clinical Assessment
                  _buildSection(
                    'CLINICAL ASSESSMENT',
                    [
                      _buildInfoRow('Appetite Test', _getAppetiteText(widget.assessment.appetite)),
                      _buildInfoRow('Danger Signs', widget.assessment.dangerSigns == 1 ? 'Present' : 'Absent'),
                      _buildInfoRow('Clinical Status', widget.assessment.clinicalStatus ?? 'N/A', 
                        statusColor: _getStatusColor(widget.assessment.clinicalStatus)),
                    ],
                  ),

                  const Divider(height: 40, thickness: 2),

                  // AI Recommendation
                  _buildSection(
                    'AI-ASSISTED RECOMMENDATION',
                    [
                      _buildInfoRow('Confidence', '${((widget.assessment.confidence ?? 0) * 100).toStringAsFixed(1)}%'),
                      _buildInfoRow('Reasoning', widget.reasoning, multiline: true),
                    ],
                  ),

                  const Divider(height: 40, thickness: 2),

                  // Final Recommendation (Editable)
                  _buildEditableSection(
                    'FINAL CARE PATHWAY',
                    [
                      _buildEditableField(
                        'Recommended Pathway',
                        _pathwayController,
                        _isEditing,
                        widget.assessment.recommendedPathway ?? 'N/A',
                        pathwayColor: _getPathwayColor(widget.assessment.recommendedPathway),
                      ),
                      _buildInfoRow('Action Required', _getActionMessage(widget.assessment.recommendedPathway ?? ''), 
                        multiline: true),
                    ],
                  ),

                  const Divider(height: 40, thickness: 2),

                  // CHW Notes (Editable)
                  _buildEditableSection(
                    'COMMUNITY HEALTH WORKER NOTES',
                    [
                      _buildEditableField(
                        'Additional Observations',
                        _chwNotesController,
                        _isEditing,
                        _chwNotesController.text.isEmpty ? 'No additional notes' : _chwNotesController.text,
                        maxLines: 5,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Signature Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'CERTIFICATION',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            if (_isEditing) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.edit, size: 16, color: Color(0xFF2D5F3F)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'I certify that this assessment was conducted according to CMAM guidelines and the information provided is accurate to the best of my knowledge.',
                          style: TextStyle(fontSize: 11, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CHW Name:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  _isEditing
                                      ? TextField(
                                          controller: _chwNameController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your name',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          style: const TextStyle(fontSize: 13),
                                        )
                                      : Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: const BoxDecoration(
                                            border: Border(bottom: BorderSide(color: Colors.black)),
                                          ),
                                          child: Text(
                                            _chwNameController.text.isEmpty ? '_______________' : _chwNameController.text,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Signature:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  _isEditing
                                      ? TextField(
                                          controller: _chwSignatureController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter signature',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                        )
                                      : Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: const BoxDecoration(
                                            border: Border(bottom: BorderSide(color: Colors.black)),
                                          ),
                                          child: Text(
                                            _chwSignatureController.text.isEmpty ? '_______________' : _chwSignatureController.text,
                                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  if (widget.assessment.recommendedPathway == 'SC_ITP') ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorSelectionScreen(assessment: widget.assessment),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_hospital),
                      label: const Text('Refer to Doctor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                          },
                          icon: const Icon(Icons.home),
                          label: const Text('Back to Home'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement print/export
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Export feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Print'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D5F3F),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Color(0xFF2D5F3F),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildEditableSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Color(0xFF2D5F3F),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(width: 8),
              const Icon(Icons.edit, size: 16, color: Color(0xFF2D5F3F)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false, Color? statusColor, Color? pathwayColor, bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: highlight ? const Color(0xFF2D5F3F).withOpacity(0.1) : 
                       statusColor != null ? statusColor.withOpacity(0.1) :
                       pathwayColor != null ? pathwayColor.withOpacity(0.1) :
                       Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: highlight ? const Color(0xFF2D5F3F) :
                         statusColor ?? pathwayColor ?? Colors.grey[300]!,
                  width: highlight ? 2 : 1,
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                  color: statusColor ?? pathwayColor ?? Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool isEditing, String displayValue, {Color? pathwayColor, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          isEditing
              ? TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: pathwayColor != null ? pathwayColor.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: pathwayColor ?? Colors.grey[300]!,
                      width: pathwayColor != null ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: pathwayColor != null ? FontWeight.bold : FontWeight.normal,
                      color: pathwayColor ?? Colors.black87,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _getEdemaText(int edema) {
    switch (edema) {
      case 0: return 'Absent';
      case 1: return 'Present (+)';
      case 2: return 'Present (++)';
      case 3: return 'Present (+++)';
      default: return 'Unknown';
    }
  }

  String _getAppetiteText(String appetite) {
    switch (appetite) {
      case 'good': return 'Good';
      case 'poor': return 'Poor';
      case 'failed': return 'Failed appetite test';
      default: return appetite;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'SAM': return Colors.red;
      case 'MAM': return Colors.orange;
      case 'Healthy': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getPathwayColor(String? pathway) {
    switch (pathway) {
      case 'SC_ITP': return Colors.red;
      case 'OTP': return Colors.orange;
      case 'TSFP': return Colors.blue;
      case 'None': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getActionMessage(String pathway) {
    switch (pathway) {
      case 'SC_ITP':
        return '🚨 URGENT: Refer to Stabilization Centre immediately for inpatient care';
      case 'OTP':
        return '📋 Enroll in Outpatient Therapeutic Programme - Weekly RUTF distribution';
      case 'TSFP':
        return '🥣 Enroll in Targeted Supplementary Feeding Programme';
      case 'None':
        return '✅ Provide counselling on infant and young child feeding practices';
      default:
        return 'Review assessment';
    }
  }
}

import 'package:flutter/material.dart';
import '../models/child_assessment.dart';
import '../services/database_service.dart';
import '../services/zscore_service.dart';
import '../services/prediction_service.dart';
import '../services/quality_check_service.dart';
import '../services/auth_service.dart';
import '../utils/id_generator.dart';
import '../utils/constants.dart';
import 'processing_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _muacController = TextEditingController();
  final _chwNameController = TextEditingController();
  final _chwPhoneController = TextEditingController();
  late String _childId;

  String _sex = 'M';
  int _edema = 0;
  String _appetite = 'good';
  int _dangerSigns = 0;
  bool _isLoading = false;
  
  String? _selectedState;
  String? _selectedFacility;
  List<String> _availableFacilities = [];

  @override
  void initState() {
    super.initState();
    _childId = IdGenerator.generateChildId();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        _selectedState = user['state'];
        _selectedFacility = user['facility'];
        _chwNameController.text = user['full_name'] ?? '';
        _chwPhoneController.text = user['phone'] ?? '';
        if (_selectedState != null) {
          _availableFacilities = AppConstants.getFacilities(_selectedState!);
        }
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _muacController.dispose();
    _chwNameController.dispose();
    _chwPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submitAssessment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final ageMonths = int.parse(_ageController.text);
    final muacMm = int.parse(_muacController.text);
    final muacCm = muacMm / 10.0;

    // ========================================
    // STEP 1: MODEL 2 - QUALITY CHECK (GATEKEEPER)
    // ========================================
    final qualityCheck = QualityCheckService.checkQuality(
      muacMm: muacMm,
      ageMonths: ageMonths,
      sex: _sex,
      edema: _edema,
      appetite: _appetite,
      dangerSigns: _dangerSigns,
    );

    // If quality check fails with critical errors, show warning and STOP
    if (QualityCheckService.shouldBlock(qualityCheck)) {
      setState(() => _isLoading = false);
      _showQualityWarning(qualityCheck);
      return;
    }

    // If near threshold, show info but allow continue
    if (qualityCheck['near_threshold'] == true && qualityCheck['status'] == 'OK') {
      final shouldContinue = await _showNearThresholdDialog(qualityCheck);
      if (!shouldContinue) {
        setState(() => _isLoading = false);
        return;
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessingScreen(
            ageMonths: ageMonths,
            muacMm: muacMm,
            sex: _sex,
            edema: _edema,
            appetite: _appetite,
            dangerSigns: _dangerSigns,
            childId: _childId,
            facility: _selectedFacility,
            state: _selectedState,
            chwName: _chwNameController.text.trim(),
            chwPhone: _chwPhoneController.text.trim(),
          ),
        ),
      );
    }
  }

  void _showQualityWarning(Map<String, dynamic> qualityCheck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Measurement Quality Issue'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              qualityCheck['recommendation'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              QualityCheckService.getDetailedExplanation(qualityCheck['flags']),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK, I\'ll Re-check'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showNearThresholdDialog(Map<String, dynamic> qualityCheck) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text('Near Threshold'),
          ],
        ),
        content: Text(
          qualityCheck['recommendation'],
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Re-measure'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Auto-generated Child ID Display
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0E4D34), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0E4D34).withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E4D34).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.badge,
                              color: Color(0xFF0E4D34),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Child ID (Auto-generated)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _childId,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0E4D34),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: AppConstants.states.map((state) {
                        return DropdownMenuItem(value: state, child: Text(state));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                          _selectedFacility = null;
                          _availableFacilities = AppConstants.getFacilities(value!);
                        });
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedFacility,
                      decoration: const InputDecoration(
                        labelText: 'Health Facility',
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      isExpanded: true,
                      items: _availableFacilities.map((facility) {
                        return DropdownMenuItem(
                          value: facility,
                          child: Text(
                            facility,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedFacility = value),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildTextField(
                      controller: _chwNameController,
                      label: 'Your Name (CHW)',
                      hint: 'Enter your full name',
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildTextField(
                      controller: _chwPhoneController,
                      label: 'Your Phone Number',
                      hint: '+211...',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildSexSelector(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _ageController,
                      label: 'Age (months)',
                      hint: '3-60',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        final age = int.tryParse(v!);
                        if (age == null || age < 3 || age > 60) {
                          return 'Age must be 3-60 months';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _muacController,
                      label: 'MUAC (mm)',
                      hint: '90-200',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        final muac = int.tryParse(v!);
                        if (muac == null || muac < 90 || muac > 200) {
                          return 'MUAC must be 90-200 mm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildEdemaSelector(),
                    const SizedBox(height: 20),
                    _buildAppetiteSelector(),
                    const SizedBox(height: 20),
                    _buildDangerSignsSelector(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitAssessment,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Calculate Pathway',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildSexSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sex',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip('Boy', 'M'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceChip('Girl', 'F'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, String value) {
    final isSelected = _sex == value;
    return InkWell(
      onTap: () => setState(() => _sex = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E4D34) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0E4D34) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEdemaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edema (bilateral pitting)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildOptionChip('No', 0, _edema, (v) => setState(() => _edema = v)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionChip('Yes', 1, _edema, (v) => setState(() => _edema = v)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppetiteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appetite Test',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _appetite,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'good', child: Text('Good')),
            DropdownMenuItem(value: 'poor', child: Text('Poor')),
            DropdownMenuItem(value: 'failed', child: Text('Failed')),
          ],
          onChanged: (v) => setState(() => _appetite = v!),
        ),
      ],
    );
  }

  Widget _buildDangerSignsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danger Signs / Complications',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildOptionChip('No', 0, _dangerSigns, (v) => setState(() => _dangerSigns = v)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionChip('Yes', 1, _dangerSigns, (v) => setState(() => _dangerSigns = v)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionChip(String label, int value, int currentValue, Function(int) onTap) {
    final isSelected = currentValue == value;
    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E4D34) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0E4D34) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

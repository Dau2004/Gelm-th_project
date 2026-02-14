import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/child_assessment.dart';

class DoctorSelectionScreen extends StatefulWidget {
  final ChildAssessment assessment;

  const DoctorSelectionScreen({super.key, required this.assessment});

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedDoctor;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    
    print('🔍 Loading doctors...');
    final doctors = await ApiService.getActiveDoctors();
    print('📋 Doctors received: ${doctors.length}');
    
    if (doctors.isEmpty) {
      print('⚠️ No doctors found - check authentication');
    }
    
    setState(() {
      _doctors = doctors;
      _isLoading = false;
    });
  }

  Future<void> _submitReferral() async {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor')),
      );
      return;
    }

    final success = await ApiService.createReferral(
      childId: widget.assessment.childId,
      doctorId: _selectedDoctor!['id'],
      notes: _notesController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Referral sent successfully'),
            backgroundColor: Color(0xFF2ECC71),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send referral'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Select Doctor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE74C3C), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'URGENT REFERRAL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Child ${widget.assessment.childId} requires immediate medical attention',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Doctor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_doctors.isEmpty)
                    const Center(
                      child: Text('No active doctors available'),
                    )
                  else
                    ..._doctors.map((doctor) => _buildDoctorCard(doctor)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Referral Notes',
                      hintText: 'Add any additional notes for the doctor...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitReferral,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Send Referral',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final isSelected = _selectedDoctor?['id'] == doctor['id'];
    
    return GestureDetector(
      onTap: () => setState(() => _selectedDoctor = doctor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0E4D34) : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0E4D34).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: const Color(0xFF0E4D34),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['full_name'] ?? doctor['username'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (doctor['facility_name'] != null)
                    Text(
                      doctor['facility_name'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (doctor['phone'] != null)
                    Text(
                      doctor['phone'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0E4D34), size: 28),
          ],
        ),
      ),
    );
  }
}

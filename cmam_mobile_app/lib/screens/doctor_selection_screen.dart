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
    
    print('[SEARCH] Loading doctors...');
    final doctors = await ApiService.getActiveDoctors();
    print('[LIST] Doctors received: ${doctors.length}');
    
    if (doctors.isEmpty) {
      print('WARNING No doctors found - check authentication');
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
            content: Text('OK Referral sent successfully'),
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

  String _buildDoctorDisplayName(Map<String, dynamic> doctor) {
    // Use display_name_for_referral if available
    if (doctor['display_name_for_referral'] != null && 
        doctor['display_name_for_referral'].toString().isNotEmpty) {
      return doctor['display_name_for_referral'].toString();
    }
    
    // Build name from components
    String name = '';
    
    // Add title if available
    if (doctor['doctor_title'] != null && doctor['doctor_title'].toString().isNotEmpty) {
      name += doctor['doctor_title'].toString() + ' ';
    }
    
    // Add first and last name
    if (doctor['first_name'] != null && doctor['last_name'] != null) {
      name += '${doctor['first_name']} ${doctor['last_name']}';
    } else if (doctor['username'] != null) {
      name += doctor['username'].toString();
    }
    
    return name.trim().isNotEmpty ? name.trim() : 'Unknown Doctor';
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
                    _buildDoctorDisplayName(doctor),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (doctor['doctor_specialization'] != null && doctor['doctor_specialization'].toString().isNotEmpty)
                    Text(
                      doctor['doctor_specialization'].toString(),
                      style: TextStyle(fontSize: 13, color: Colors.blue[700], fontWeight: FontWeight.w500),
                    ),
                  if (doctor['facility'] != null && doctor['facility'].toString().isNotEmpty)
                    Text(
                      doctor['facility'].toString(),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (doctor['phone'] != null && doctor['phone'].toString().isNotEmpty)
                    Text(
                      doctor['phone'].toString(),
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

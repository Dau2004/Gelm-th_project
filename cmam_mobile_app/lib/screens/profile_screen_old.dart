import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _chwName = 'Community Health Worker';
  String _facility = 'Health Facility';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _chwName = prefs.getString('chw_name') ?? 'Community Health Worker';
      _facility = prefs.getString('facility') ?? 'Health Facility';
      _phone = prefs.getString('phone') ?? '';
    });
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _chwName);
    final facilityController = TextEditingController(text: _facility);
    final phoneController = TextEditingController(text: _phone);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: facilityController,
              decoration: const InputDecoration(labelText: 'Facility'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chw_name', nameController.text);
      await prefs.setString('facility', facilityController.text);
      await prefs.setString('phone', phoneController.text);
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF2D5F3F),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _chwName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _facility,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            if (_phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_phone, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
            const SizedBox(height: 32),
            _buildInfoCard('App Information', [
              _buildInfoRow('Version', '1.0.0'),
              _buildInfoRow('Guidelines', 'South Sudan CMAM 2017'),
              _buildInfoRow('WHO Standards', 'ACFA 3-60 months'),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('About', [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'CMAM Care Pathway mobile application for Community Health Workers. '
                  'Screen children for malnutrition using MUAC measurements and WHO standards.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

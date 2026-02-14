import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _fullName = 'Community Health Worker';
  String _facility = 'Health Facility';
  String _state = '';
  String _phone = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        _username = user['username'] ?? '';
        _fullName = user['full_name'] ?? 'Community Health Worker';
        _facility = user['facility'] ?? 'Health Facility';
        _state = user['state'] ?? '';
        _phone = user['phone'] ?? '';
        _role = user['role'] ?? '';
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _syncData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final assessmentResult = await SyncService.syncAssessments();
    final referralResult = await SyncService.syncReferrals();

    if (mounted) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sync Complete'),
          content: Text(
            'Assessments: ${assessmentResult['message']}\n'
            'Referrals: ${referralResult['message']}'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
              _fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '@$_username',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _facility,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (_state.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_state, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
            if (_phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_phone, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _syncData,
              icon: const Icon(Icons.sync),
              label: const Text('Sync Data to Server'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5F3F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2D5F3F),
                side: const BorderSide(color: Color(0xFF2D5F3F)),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard('User Information', [
              _buildInfoRow('Username', _username),
              _buildInfoRow('Full Name', _fullName),
              _buildInfoRow('Role', _role == 'CHW' ? 'Community Health Worker' : _role),
              _buildInfoRow('Facility', _facility),
              _buildInfoRow('State', _state),
              if (_phone.isNotEmpty) _buildInfoRow('Phone', _phone),
            ]),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('Sign out of your account'),
                onTap: _logout,
              ),
            ),
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
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

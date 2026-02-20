import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../services/locale_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  double _textSize = 1.0;
  String _username = '';
  String _fullName = 'Community Health Worker';
  String _facility = 'Health Facility';
  String _state = '';
  String _phone = '';
  String _role = '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await AuthService.getCurrentUser();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _textSize = prefs.getDouble('text_size') ?? 1.0;
      if (user != null) {
        _username = user['username'] ?? '';
        _fullName = user['full_name'] ?? 'Community Health Worker';
        _facility = user['facility'] ?? 'Health Facility';
        _state = user['state'] ?? '';
        _phone = user['phone'] ?? '';
        _role = user['role'] ?? '';
      }
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() => _isDarkMode = value);
    if (mounted) {
      final provider = SettingsProvider.of(context);
      provider?.onSettingsChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Theme updated')),
      );
    }
  }

  Future<void> _saveTextSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_size', value);
    setState(() => _textSize = value);
    if (mounted) {
      final provider = SettingsProvider.of(context);
      provider?.onSettingsChanged();
    }
  }



  Future<void> _syncData() async {
    setState(() => _isSyncing = true);
    
    try {
      final result = await SyncService.syncAssessments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
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
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final l10n = AppLocalizations(locale.languageCode);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF2D5F3F),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(_fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('@$_username', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(_facility, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                if (_state.isNotEmpty) Text(_state, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (_phone.isNotEmpty) Text(_phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                if (_role.isNotEmpty) 
                  Chip(
                    label: Text(_role == 'CHW' ? 'Community Health Worker' : _role),
                    backgroundColor: const Color(0xFF2D5F3F).withOpacity(0.1),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('App Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: _isDarkMode,
                activeColor: const Color(0xFF2D5F3F),
                onChanged: _saveDarkMode,
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Text Size'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: _textSize,
                      min: 0.8,
                      max: 1.5,
                      divisions: 7,
                      activeColor: const Color(0xFF2D5F3F),
                      label: '${(_textSize * 100).round()}%',
                      onChanged: _saveTextSize,
                    ),
                    Text(
                      'Current: ${(_textSize * 100).round()}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(l10n.translate('language')),
                subtitle: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
                trailing: DropdownButton<String>(
                  value: locale.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                  onChanged: (code) {
                    if (code != null) {
                      Provider.of<LocaleProvider>(context, listen: false).setLocale(code);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Data Sync', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: _isSyncing 
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload, color: Color(0xFF2D5F3F)),
                title: const Text('Sync Assessments'),
                subtitle: const Text('Upload unsynced data to server'),
                trailing: _isSyncing ? null : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isSyncing ? null : _syncData,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('App Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(height: 24),
                _buildInfoRow('Version', '1.0.0'),
                _buildInfoRow('Guidelines', 'South Sudan CMAM 2017'),
                _buildInfoRow('WHO Standards', 'ACFA 3-60 months'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text('Sign out of your account'),
            onTap: _logout,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

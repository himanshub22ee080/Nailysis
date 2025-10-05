import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Nailysis/providers/theme_provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/providers/app_state_provider.dart';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _dataExportEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedUnits = 'g/dL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            MedicalCard(
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: 'Profile Information',
                    subtitle: 'Update your personal details',
                    onTap: () => context.go('/home/profile'),
                    showArrow: true,
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    subtitle: 'Manage your account security',
                    onTap: () => _showPrivacyDialog(context),
                    showArrow: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Preferences Section
            _buildSectionHeader('Preferences'),
            MedicalCard(
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Use dark theme',
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Receive measurement reminders',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.fingerprint,
                    title: 'Biometric Authentication',
                    subtitle: 'Use fingerprint or face ID',
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Measurement Settings
            _buildSectionHeader('Measurement Settings'),
            MedicalCard(
              child: Column(
                children: [
                  _buildDropdownTile(
                    icon: Icons.straighten,
                    title: 'Units',
                    subtitle: 'Hemoglobin measurement units',
                    value: _selectedUnits,
                    options: ['g/dL', 'mmol/L'],
                    onChanged: (value) {
                      setState(() {
                        _selectedUnits = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.schedule,
                    title: 'Reminder Schedule',
                    subtitle: 'Set measurement reminders',
                    onTap: () => _showReminderDialog(context),
                    showArrow: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data & Sync
            _buildSectionHeader('Data & Sync'),
            MedicalCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Auto Sync',
                    subtitle: 'Automatically sync your data',
                    value: _dataExportEnabled,
                    onChanged: (value) {
                      setState(() {
                        _dataExportEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    subtitle: 'Download your measurement history',
                    onTap: () => _showExportDialog(context),
                    showArrow: true,
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Clear Data',
                    subtitle: 'Remove all stored measurements',
                    onTap: () => _showClearDataDialog(context),
                    showArrow: true,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Developer Options Section
            _buildSectionHeader('Developer Options'),
            MedicalCard(
              child: Column(
                children: [
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return _buildSwitchTile(
                        icon: Icons.science_outlined,
                        title: 'Research Mode',
                        subtitle: 'Enable video capture for datasets',
                        value: appState.isResearchMode,
                        onChanged: (value) {
                          appState.setResearchMode(value);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support & About
            _buildSectionHeader('Support & About'),
            MedicalCard(
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help using Nailysis',
                    onTap: () => _showHelpDialog(context),
                    showArrow: true,
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    onTap: () => _showTermsDialog(context),
                    showArrow: true,
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Learn how we protect your data',
                    onTap: () => _showPrivacyPolicyDialog(context),
                    showArrow: true,
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'About Nailysis',
                    subtitle: 'Version 1.0.0',
                    onTap: () => _showAboutDialog(context),
                    showArrow: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = false,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppTheme.primaryTeal,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      trailing: showArrow
          ? Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            )
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryTeal,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryTeal,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryTeal,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<PatientProvider>(context, listen: false).logout();
                context.go('/login');
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    _showInfoDialog(
      context,
      'Privacy & Security',
      'Your health data is encrypted and stored securely on your device. We use industry-standard security measures to protect your information.',
    );
  }

  void _showReminderDialog(BuildContext context) {
    _showInfoDialog(
      context,
      'Reminder Schedule',
      'Set up regular reminders to take your hemoglobin measurements. This helps maintain consistent health monitoring.',
    );
  }

  void _showExportDialog(BuildContext context) {
    _showInfoDialog(
      context,
      'Export Data',
      'Export your measurement history as a CSV file that you can share with your healthcare provider.',
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete all your measurement history. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Clear data logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data cleared successfully')),
                );
              },
              child: const Text(
                'Clear Data',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    _showInfoDialog(
      context,
      'Help & Support',
      'For assistance with Nailysis, please visit our support website or contact our customer service team.',
    );
  }

  void _showTermsDialog(BuildContext context) {
    _showInfoDialog(
      context,
      'Terms of Service',
      'By using Nailysis, you agree to our terms of service. Please read our full terms on our website.',
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    _showInfoDialog(
      context,
      'Privacy Policy',
      'We are committed to protecting your privacy. Read our full privacy policy to learn how we handle your data.',
    );
  }

  void _showAboutDialog(BuildContext context) {
    _showInfoDialog(
      context,
      'About Nailysis',
      'Nailysis is a non-invasive hemoglobin monitoring app designed to help you track your health conveniently and accurately.\n\nVersion: 1.0.0\nDeveloped with ❤️ for better health monitoring.',
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
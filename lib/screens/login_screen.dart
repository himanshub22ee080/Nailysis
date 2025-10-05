import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/models/patient_data.dart';
import 'package:Nailysis/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _handleLogin(BuildContext context) {
    // Create Nailysis user for login
    final demoPatient = PatientData(
      id: 'Nailysis-patient',
      firstName: 'Demo',
      lastName: 'User',
      email: 'Nailysis@nailysis.com',
      phone: '+1 (555) 123-4567',
      dateOfBirth: '1990-01-01',
      gender: 'other',
      medicalId: 'NAL123456',
    );

    Provider.of<PatientProvider>(context, listen: false).login(demoPatient);
    context.go('/home');
  }

  void _handleSignUp(BuildContext context) {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/nailysis_logo.jpg',
                    width: 48,
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_hospital,
                        size: 36,
                        color: AppTheme.primaryTeal,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App name
              const Text(
                'Nailysis',
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 48),

              // Feature cards
              Expanded(
                child: ListView(
                  children: [
                    _buildFeatureCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.favorite_outline,
                      iconColor: AppTheme.secondaryTeal,
                      backgroundColor: const Color(0xFFE0F2F1),
                      title: 'Non-invasive Testing',
                      subtitle:
                          'Quick Hemoglobin Screening Without Needles or Blood Samples',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.flash_on_outlined,
                      iconColor: const Color(0xFF1976D2),
                      backgroundColor: const Color(0xFFE3F2FD),
                      title: 'Instant Results',
                      subtitle:
                          'Get Accurate Measurements In Seconds With Our Advanced Technology',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF7B1FA2),
                      backgroundColor: const Color(0xFFF3E5F5),
                      title: 'Clinical Grade',
                      subtitle:
                          'Medical-Grade Accuracy Tested By Healthcare Professionals',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Sign up button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _handleSignUp(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    side: const BorderSide(color: Colors.transparent),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home/capture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.normalTriage,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Try an Instant Test',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? iconColor.withOpacity(0.2) : backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

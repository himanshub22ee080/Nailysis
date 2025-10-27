import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/models/patient_data.dart';
import 'package:Nailysis/theme/app_theme.dart';
import 'package:Nailysis/services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = SupabaseService();
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _supabase.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        final profile = await _supabase.fetchProfile();

        if (profile != null) {
          if (!mounted) return;
          final patient = PatientData.fromMap(profile);
          // wait for provider to persist the login state
          await Provider.of<PatientProvider>(context, listen: false)
              .login(patient);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile not found')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

              // Login form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _isObscured = !_isObscured);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
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

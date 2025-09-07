import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Nailysis/providers/app_state_provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/widgets/status_chip.dart';
import 'package:Nailysis/widgets/patient_profile.dart';
import 'package:Nailysis/widgets/notification_banner.dart';
import 'package:Nailysis/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateProvider, PatientProvider>(
      builder: (context, appState, patientProvider, child) {
        final patient = patientProvider.currentPatient;
        // Always show settings icon, even if patient is null
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppTheme.primaryTeal,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryTeal, AppTheme.secondaryTeal],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nailysis',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      patient != null
                                          ? 'Welcome back, ${patient.firstName}!'
                                          : 'Welcome!',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () => context.go('/home/settings'),
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Sync Status Card
                            MedicalCard(
                              color: Colors.white.withOpacity(0.1),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        appState.isConnected
                                            ? Icons.wifi
                                            : Icons.wifi_off,
                                        color: appState.isConnected
                                            ? Colors.green[400]
                                            : Colors.red[400],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            appState.isConnected
                                                ? 'Connected'
                                                : 'Offline',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Last sync: ${appState.formatLastSync()}',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  StatusChip(
                                    status: appState.isConnected
                                        ? StatusType.synced
                                        : StatusType.offline,
                                    size: StatusSize.small,
                                    text: appState.isConnected
                                        ? 'Synced'
                                        : 'Offline',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Body Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Profile Section
                      const Text(
                        'Your Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (patient != null)
                        GestureDetector(
                          onTap: () => context.go('/home/profile'),
                          child: PatientProfile(
                            patient: patient,
                            compact: true,
                            clickable: true,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.person_outline,
                                  size: 40, color: Colors.grey),
                              SizedBox(width: 16),
                              Text(
                                'No profile loaded',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Quick Actions Section
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // New Measurement Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/home/capture'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/nailysis_logo.png',
                                    width: 32,
                                    height: 32,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 24,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'New Measurement',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Start screening',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action Grid
                      Row(
                        children: [
                          Expanded(
                            child: MedicalCard(
                              onTap: () => context.go('/home/measurements'),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    color: AppTheme.primaryTeal,
                                    size: 32,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'My Measurements',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'View history',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MedicalCard(
                              onTap: () => context.go('/home/settings'),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: AppTheme.primaryTeal,
                                    size: 32,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Settings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Configure app',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Recent Measurements Section
                      const Text(
                        'Recent Measurements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (appState.recentMeasurements.isNotEmpty)
                        MedicalCard(
                          child: Column(
                            children:
                                appState.recentMeasurements.map((measurement) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Hemoglobin Test',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            _formatTime(measurement.timestamp),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusChip(
                                      status: _getStatusFromMeasurement(
                                          measurement.status),
                                      size: StatusSize.small,
                                      text:
                                          '${measurement.hemoglobin.toStringAsFixed(1)} g/dL',
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      else
                        MedicalCard(
                          child: const Column(
                            children: [
                              Icon(
                                Icons.bar_chart,
                                color: Colors.grey,
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No measurements yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Take your first measurement to get started',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // System Alerts
                      if (!appState.isConnected)
                        const NotificationBanner(
                          type: NotificationType.warning,
                          title: 'Device Offline',
                          message:
                              'Some features may be limited. Check your connection.',
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  StatusType _getStatusFromMeasurement(dynamic status) {
    switch (status.toString()) {
      case 'MeasurementStatus.severe':
        return StatusType.severe;
      case 'MeasurementStatus.moderate':
        return StatusType.moderate;
      case 'MeasurementStatus.mild':
        return StatusType.mild;
      default:
        return StatusType.normal;
    }
  }
}

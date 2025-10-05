import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:Nailysis/providers/app_state_provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/widgets/status_chip.dart';
import 'package:Nailysis/models/measurement_result.dart';
import 'package:Nailysis/theme/app_theme.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateProvider, PatientProvider>(
      builder: (context, appState, patientProvider, child) {
        final result = appState.currentMeasurement;
        final patient = patientProvider.currentPatient;

        if (result == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (patientProvider.isAuthenticated) {
              context.go('/home');
            } else {
              context.go('/login');
            }
          });
          return const Scaffold();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Measurement Results'),
            leading: IconButton(
              onPressed: () => _handleSave(context, appState),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Result Card
                _buildMainResultCard(result),

                const SizedBox(height: 24),

                if (patient != null) ...[
                  // Patient Info
                  _buildPatientInfoCard(patient),
                  const SizedBox(height: 24),
                ],

                // Interpretation
                _buildInterpretationCard(result),

                const SizedBox(height: 24),

                // Actions
                _buildActionButtons(context, appState),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainResultCard(MeasurementResult result) {
    final status = result.status;
    final color = _getColorForStatus(status);

    return MedicalCard(
      child: Column(
        children: [
          // Status icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              _getIconForStatus(status),
              color: color,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          // Hemoglobin value
          Text(
            '${result.hemoglobin.toStringAsFixed(1)} g/dL',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          // Status label
          StatusChip(
            status: _getStatusTypeFromMeasurement(status),
            size: StatusSize.large,
            text: _getStatusLabel(status),
          ),

          const SizedBox(height: 16),

          // Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Measured at ${_formatTime(result.timestamp)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard(patient) {
    return MedicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoRow('Name', patient.fullName),
          _buildInfoRow('Medical ID', patient.medicalId),
          _buildInfoRow('Date of Birth', _formatDate(patient.dateOfBirth)),
          _buildInfoRow('Gender', _formatGender(patient.gender)),
        ],
      ),
    );
  }

  Widget _buildInterpretationCard(MeasurementResult result) {
    final status = result.status;
    final interpretation = _getInterpretation(status, result.hemoglobin);

    return MedicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinical Interpretation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            interpretation.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getColorForStatus(status),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            interpretation.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (interpretation.recommendations.isNotEmpty) ...[
            const Text(
              'Recommendations:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...interpretation.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppStateProvider appState) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleSave(context, appState),
            icon: const Icon(Icons.save),
            label: const Text('Save Measurement'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 56),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/home/capture'),
                icon: const Icon(Icons.refresh),
                label: const Text('New Test'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/home/measurements'),
                icon: const Icon(Icons.history),
                label: const Text('View History'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave(BuildContext context, AppStateProvider appState) {
    final measurement = appState.currentMeasurement;
    if (measurement != null) {
      appState.addMeasurement(measurement);
      appState.clearCurrentMeasurement();
    }
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    if (patientProvider.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  Color _getColorForStatus(MeasurementStatus status) {
    switch (status) {
      case MeasurementStatus.severe:
        return AppTheme.severeTriage;
      case MeasurementStatus.moderate:
        return AppTheme.moderateTriage;
      case MeasurementStatus.mild:
        return AppTheme.mildTriage;
      case MeasurementStatus.normal:
        return AppTheme.normalTriage;
    }
  }

  IconData _getIconForStatus(MeasurementStatus status) {
    switch (status) {
      case MeasurementStatus.severe:
        return Icons.warning;
      case MeasurementStatus.moderate:
        return Icons.info;
      case MeasurementStatus.mild:
        return Icons.info_outline;
      case MeasurementStatus.normal:
        return Icons.check_circle;
    }
  }

  StatusType _getStatusTypeFromMeasurement(MeasurementStatus status) {
    switch (status) {
      case MeasurementStatus.severe:
        return StatusType.severe;
      case MeasurementStatus.moderate:
        return StatusType.moderate;
      case MeasurementStatus.mild:
        return StatusType.mild;
      case MeasurementStatus.normal:
        return StatusType.normal;
    }
  }

  String _getStatusLabel(MeasurementStatus status) {
    switch (status) {
      case MeasurementStatus.severe:
        return 'Severe Anemia';
      case MeasurementStatus.moderate:
        return 'Moderate Anemia';
      case MeasurementStatus.mild:
        return 'Mild Anemia';
      case MeasurementStatus.normal:
        return 'Normal';
    }
  }

  InterpretationData _getInterpretation(MeasurementStatus status, double hb) {
    switch (status) {
      case MeasurementStatus.severe:
        return InterpretationData(
          title: 'Severe Anemia Detected',
          description:
              'Hemoglobin level is significantly below normal range. This indicates severe anemia that requires immediate medical attention.',
          recommendations: [
            'Seek immediate medical consultation',
            'Follow up with your healthcare provider',
            'Consider iron supplementation as prescribed',
            'Monitor for symptoms like fatigue, shortness of breath',
          ],
        );
      case MeasurementStatus.moderate:
        return InterpretationData(
          title: 'Moderate Anemia Detected',
          description:
              'Hemoglobin level is moderately below normal range. This suggests moderate anemia that should be addressed promptly.',
          recommendations: [
            'Schedule appointment with healthcare provider',
            'Consider dietary changes to include iron-rich foods',
            'Monitor symptoms and energy levels',
            'Follow up in 2-4 weeks',
          ],
        );
      case MeasurementStatus.mild:
        return InterpretationData(
          title: 'Mild Anemia Detected',
          description:
              'Hemoglobin level is slightly below normal range. This indicates mild anemia that may benefit from lifestyle modifications.',
          recommendations: [
            'Increase iron-rich foods in diet',
            'Consider vitamin C to enhance iron absorption',
            'Monitor symptoms regularly',
            'Follow up with routine care',
          ],
        );
      case MeasurementStatus.normal:
        return InterpretationData(
          title: 'Normal Hemoglobin Level',
          description:
              'Hemoglobin level is within the normal range. This indicates healthy iron levels and oxygen-carrying capacity.',
          recommendations: [
            'Maintain balanced diet',
            'Continue regular health monitoring',
            'Stay active and hydrated',
            'Follow routine screening schedule',
          ],
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return 'Not specified';
    }
  }
}

class InterpretationData {
  final String title;
  final String description;
  final List<String> recommendations;

  InterpretationData({
    required this.title,
    required this.description,
    required this.recommendations,
  });
}

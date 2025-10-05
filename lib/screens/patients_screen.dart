import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Nailysis/providers/app_state_provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/widgets/status_chip.dart';
import 'package:Nailysis/models/measurement_result.dart';
import 'package:Nailysis/theme/app_theme.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateProvider, PatientProvider>(
      builder: (context, appState, patientProvider, child) {
        final patient = patientProvider.currentPatient;
        final measurements = appState.measurementHistory;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient != null ? 'My Measurements' : 'Session History',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Track your health over time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            leading: IconButton(
              onPressed: () {
                if (patientProvider.isAuthenticated) {
                  context.go('/home');
                } else {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: measurements.isEmpty
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryCards(measurements),

                      const SizedBox(height: 24),

                      // Chart Section
                      if (measurements.length > 1) ...[
                        _buildChartSection(measurements),
                        const SizedBox(height: 24),
                      ],

                      // Measurements List
                      _buildMeasurementsList(measurements),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go('/home/capture'),
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Test'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.bar_chart,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Measurements Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start monitoring your health by taking your first hemoglobin measurement.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home/capture'),
              icon: const Icon(Icons.add),
              label: const Text('Take First Measurement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<MeasurementResult> measurements) {
    final latest = measurements.isNotEmpty ? measurements.first : null;
    final average = measurements.isNotEmpty
        ? measurements.map((m) => m.hemoglobin).reduce((a, b) => a + b) /
            measurements.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: MedicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      color: latest != null
                          ? _getColorForStatus(latest.status)
                          : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Latest',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  latest != null
                      ? '${latest.hemoglobin.toStringAsFixed(1)} g/dL'
                      : '--',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  latest != null
                      ? _formatDateTime(latest.timestamp)
                      : 'No data',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MedicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppTheme.primaryTeal,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Average',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  average > 0 ? '${average.toStringAsFixed(1)} g/dL' : '--',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${measurements.length} measurements',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(List<MeasurementResult> measurements) {
    return MedicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hemoglobin Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < measurements.length) {
                          final date =
                              measurements.reversed.toList()[index].timestamp;
                          return Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: measurements.reversed
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      return FlSpot(
                          entry.key.toDouble(), entry.value.hemoglobin);
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primaryTeal,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryTeal,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 6,
                maxY: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsList(List<MeasurementResult> measurements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Measurements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...measurements.map((measurement) {
          return MedicalCard(
            child: Row(
              children: [
                // Date and time
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(measurement.timestamp),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(measurement.timestamp),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Hemoglobin value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${measurement.hemoglobin.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getColorForStatus(measurement.status),
                        ),
                      ),
                      const Text(
                        'g/dL',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status
                StatusChip(
                  status: _getStatusTypeFromMeasurement(measurement.status),
                  size: StatusSize.small,
                  text: _getStatusLabel(measurement.status),
                ),
              ],
            ),
          );
        }),
      ],
    );
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
        return 'Severe';
      case MeasurementStatus.moderate:
        return 'Moderate';
      case MeasurementStatus.mild:
        return 'Mild';
      case MeasurementStatus.normal:
        return 'Normal';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

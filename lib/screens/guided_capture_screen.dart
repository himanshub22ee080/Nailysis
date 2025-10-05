import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'package:Nailysis/providers/app_state_provider.dart';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/providers/patient_provider.dart';
import 'package:Nailysis/models/measurement_result.dart';
import 'package:uuid/uuid.dart';
import 'package:Nailysis/theme/app_theme.dart';

enum CaptureStep {
  prepare,
  capture,
  processing,
}

class GuidedCaptureScreen extends StatefulWidget {
  const GuidedCaptureScreen({super.key});

  @override
  State<GuidedCaptureScreen> createState() => _GuidedCaptureScreenState();
}

class _GuidedCaptureScreenState extends State<GuidedCaptureScreen>
    with TickerProviderStateMixin {
  CaptureStep _currentStep = CaptureStep.prepare;
  int _timer = 0;
  double _progress = 0.0;
  bool _isCapturing = false;
  Timer? _captureTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final int _captureTime = 15; // 15 seconds

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCapture() {
    setState(() {
      _currentStep = CaptureStep.capture;
      _isCapturing = true;
      _timer = 0;
      _progress = 0.0;
    });

    _captureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timer++;
        _progress = (_timer / _captureTime) * 100;
      });

      if (_timer >= _captureTime) {
        _completeCapture();
      }
    });
  }

  void _completeCapture() {
    _captureTimer?.cancel();
    setState(() {
      _isCapturing = false;
      _currentStep = CaptureStep.processing;
    });

    // Simulate processing time
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _generateResult();
      }
    });
  }

  void _generateResult() {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final patientId = patientProvider.currentPatient?.id ?? 'guest-patient';

    // Generate a realistic hemoglobin value
    final random = Random();
    final hemoglobin = 11.2 + (random.nextDouble() * 2); // 11.2 - 13.2 range

    final result = MeasurementResult(
      id: const Uuid().v4(),
      hemoglobin: hemoglobin,
      timestamp: DateTime.now(),
      patientId: patientId,
    );

    // Save to app state
    Provider.of<AppStateProvider>(context, listen: false)
        .setCurrentMeasurement(result);

    // Navigate to results
    context.go('/home/results');
  }

  void _resetCapture() {
    _captureTimer?.cancel();
    setState(() {
      _currentStep = CaptureStep.prepare;
      _isCapturing = false;
      _timer = 0;
      _progress = 0.0;
    });
  }

  void _navigateBack(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    if (patientProvider.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guided Measurement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Follow the instructions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => _navigateBack(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Camera Preview
            _buildCameraPreview(),

            const SizedBox(height: 16),

            // Progress indicator (only during capture)
            if (_currentStep == CaptureStep.capture) _buildProgressCard(),

            const SizedBox(height: 16),

            // Instructions
            _buildInstructionsCard(),

            const SizedBox(height: 24),

            // Controls
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: MedicalCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Camera placeholder
              const Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 64,
                  color: Colors.grey,
                ),
              ),

              // Capture circle overlay
              if (_currentStep == CaptureStep.capture)
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(64),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.primaryTeal,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Timer display
              if (_currentStep == CaptureStep.capture)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_captureTime - _timer}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Hold steady',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return MedicalCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Capturing...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_progress.round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return MedicalCard(
      child: Column(
        children: [
          _buildStepContent(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case CaptureStep.prepare:
        return _buildPrepareContent();
      case CaptureStep.capture:
        return _buildCaptureContent();
      case CaptureStep.processing:
        return _buildProcessingContent();
    }
  }

  Widget _buildPrepareContent() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(
            Icons.camera_alt,
            color: AppTheme.primaryTeal,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Prepare for Measurement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Ensure good lighting conditions'),
            SizedBox(height: 4),
            Text('• Clean the device sensor'),
            SizedBox(height: 4),
            Text('• Position finger correctly'),
            SizedBox(height: 4),
            Text('• Keep device steady during capture'),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptureContent() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.green,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Capturing Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Keep your finger steady on the sensor. Do not move until the timer completes.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProcessingContent() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Processing Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Analyzing your measurement data...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        if (_currentStep == CaptureStep.prepare)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startCapture,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Measurement'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 56),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        if (_currentStep == CaptureStep.capture)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetCapture,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 56),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        if (_currentStep != CaptureStep.processing) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _navigateBack(context),
              child: const Text('Cancel'),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 48),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

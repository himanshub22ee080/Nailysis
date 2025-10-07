// lib/screens/guided_capture_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import 'package:Nailysis/main.dart';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/theme/app_theme.dart';
import 'package:Nailysis/services/api_service.dart';
import 'package:Nailysis/models/measurement_result.dart';
import 'package:Nailysis/providers/app_state_provider.dart';
import 'package:Nailysis/providers/patient_provider.dart';

class GuidedCaptureScreen extends StatefulWidget {
  const GuidedCaptureScreen({super.key});

  @override
  State<GuidedCaptureScreen> createState() => _GuidedCaptureScreenState();
}

class _GuidedCaptureScreenState extends State<GuidedCaptureScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;

  final ApiService _apiService = ApiService();
  final int _captureTime = 15;
  int _timerSeconds = 0;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: true);
    try {
      await _controller.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startRecording() async {
    if (!_isCameraInitialized || _isRecording || _isProcessing) return;
    try {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _timerSeconds = 0;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _timerSeconds++);
        if (_timerSeconds >= _captureTime) {
          _stopAndProcess();
        }
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  void _stopAndProcess() async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();

    try {
      final XFile videoFile = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video captured. Analyzing...')),
      );

      final double? hemoglobinValue = await _apiService.uploadVideoForPrediction(videoFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (hemoglobinValue != null) {
          _showResults(hemoglobinValue);
        } else {
          _handleError('Failed to get prediction. Check server connection.');
        }
      }
    } catch (e) {
      if (mounted) _handleError('An error occurred during processing.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showResults(double hemoglobinValue) {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final patientId = patientProvider.currentPatient?.id ?? 'guest-patient';

    final result = MeasurementResult(
      id: const Uuid().v4(),
      hemoglobin: hemoglobinValue,
      timestamp: DateTime.now(),
      patientId: patientId,
    );

    Provider.of<AppStateProvider>(context, listen: false).setCurrentMeasurement(result);
    context.go('/home/results');
  }

  String _formatTimer(int totalSeconds) {
    final remaining = _captureTime - totalSeconds;
    return '${remaining < 0 ? 0 : remaining}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided Measurement'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCameraPreview(),
            const SizedBox(height: 16),
            _buildInstructionsCard(),
            const SizedBox(height: 24),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    // This UI is identical to the one from research_capture_screen
    // A good refactor would be to extract this into a shared widget.
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: MedicalCard(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isCameraInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.previewSize!.height,
                      height: _controller.value.previewSize!.width,
                      child: CameraPreview(_controller),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return MedicalCard(
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(Icons.camera_alt, color: AppTheme.primaryTeal, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Prepare for Measurement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            _isProcessing
                ? 'Uploading and analyzing video...'
                : 'Hold finger steady and start the measurement. The process will take 15 seconds.',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (_isRecording) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _timerSeconds / _captureTime),
            const SizedBox(height: 8),
            Text(_formatTimer(_timerSeconds), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }

  Widget _buildControls() {
    if (_isProcessing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isRecording ? _stopAndProcess : _startRecording,
        icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
        label: Text(_isRecording ? 'Capturing...' : 'Start Measurement'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRecording ? Colors.red : AppTheme.primaryTeal,
          minimumSize: const Size(0, 56),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
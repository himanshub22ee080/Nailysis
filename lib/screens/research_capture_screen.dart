import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/theme/app_theme.dart';

class ResearchCaptureScreen extends StatefulWidget {
  const ResearchCaptureScreen({super.key});

  @override
  State<ResearchCaptureScreen> createState() => _ResearchCaptureScreenState();
}

class _ResearchCaptureScreenState extends State<ResearchCaptureScreen> {
  bool _isRecording = false;
  int _timerSeconds = 0;
  Timer? _recordingTimer;
  double _progress = 0.0;
  final int _captureTime = 15; // 15 seconds capture time

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _timerSeconds = 0;
      _progress = 0.0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timerSeconds++;
        _progress = (_timerSeconds / _captureTime) * 100;
      });

      if (_timerSeconds >= _captureTime) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    if (!_isRecording) return; // Prevent multiple calls

    setState(() {
      _isRecording = false;
    });

    // Simulate saving the video
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Video saved successfully! (Duration: $_captureTime seconds)'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back home after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  void _cancelRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _timerSeconds = 0;
      _progress = 0.0;
    });
  }

  String _formatTimer(int totalSeconds) {
    final remaining = _captureTime - totalSeconds;
    if (remaining < 0) return '0s';
    return '${remaining}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Video Capture'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
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
            if (_isRecording) _buildProgressCard(),

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
      aspectRatio: 9 / 16, // Video aspect ratio
      child: MedicalCard(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Camera placeholder
              const Center(
                child: Icon(
                  Icons.videocam,
                  size: 64,
                  color: Colors.grey,
                ),
              ),

              // Recording indicator
              if (_isRecording)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'REC',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Timer display
              if (_isRecording)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatTimer(_timerSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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

  Widget _buildProgressCard() {
    return MedicalCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recording...',
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.science_outlined,
              color: AppTheme.primaryTeal,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Video Recording for Research',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Please record a clear, steady video of the fingernail. Ensure good lighting conditions for the best quality.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    if (_isRecording) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _cancelRecording,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel Recording'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            minimumSize: const Size(0, 56),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startRecording,
        icon: const Icon(Icons.videocam),
        label: const Text('Start Recording'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryTeal,
          minimumSize: const Size(0, 56),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
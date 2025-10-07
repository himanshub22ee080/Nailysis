// lib/screens/research_capture_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:async';

import 'package:Nailysis/main.dart';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/theme/app_theme.dart';

class ResearchCaptureScreen extends StatefulWidget {
  const ResearchCaptureScreen({super.key});

  @override
  State<ResearchCaptureScreen> createState() => _ResearchCaptureScreenState();
}

class _ResearchCaptureScreenState extends State<ResearchCaptureScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  
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
    if (!_isCameraInitialized || _isRecording) return;
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
          _stopAndSave();
        }
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  void _stopAndSave() async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();

    try {
      final XFile videoFile = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'research_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String filePath = p.join(directory.path, fileName);
      
      await videoFile.saveTo(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video saved for research!\nPath: $filePath'),
            duration: const Duration(seconds: 5),
          ),
        );
        // Navigate back home after saving
        context.go('/home');
      }
    } catch (e) {
      print('Error stopping or saving video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving video: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatTimer(int totalSeconds) {
    final remaining = _captureTime - totalSeconds;
    return '${remaining < 0 ? 0 : remaining}s';
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
            child: Icon(Icons.science_outlined, color: AppTheme.primaryTeal, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Video Recording for Research', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text(
            'Record a 15-second video to be saved locally for dataset creation.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isRecording ? _stopAndSave : _startRecording,
        icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
        label: Text(_isRecording ? 'Recording...' : 'Start Recording'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRecording ? Colors.red : AppTheme.primaryTeal,
          minimumSize: const Size(0, 56),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
// lib/screens/pi_capture_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:Nailysis/services/pi_camera_services.dart';

class PiCaptureScreen extends StatefulWidget {
  const PiCaptureScreen({Key? key}) : super(key: key);

  @override
  _PiCaptureScreenState createState() => _PiCaptureScreenState();
}

class _PiCaptureScreenState extends State<PiCaptureScreen> {
  final PiCameraService _piService = PiCameraService();
  bool _isRecording = false;
  bool _isLoading = false;
  bool _isPiConnected = false;
  String _statusMessage = 'Logging into Pi...';

  // --- State for MJPEG Streaming ---
  http.Client? _httpClient;
  StreamSubscription<List<int>>? _streamSubscription;
  Uint8List? _latestFrame;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    // The Pi server now starts the stream after login.
    // The app just needs to connect to it.
    _piService.login('IITJ', 'BTP2025').then((success) {
      if (mounted) {
        setState(() {
          _isPiConnected = success;
          _statusMessage = success ? 'Pi Connected. Starting stream...' : 'Pi Login Failed.';
        });
        if (success) {
          _startMjpegStream();
        }
      }
    });
  }

  @override
  void dispose() {
    _stopMjpegStream();
    super.dispose();
  }

  // ✅ --- THIS LOGIC IS NOW MUCH SIMPLER ---
  // We no longer need to stop/start the stream. It runs continuously.
  Future<void> _onStart() async {
    setState(() => { _isLoading = true, _statusMessage = 'Starting recording...' });
    bool success = await _piService.startRecording();
    setState(() {
      _isLoading = false;
      if (success) {
        _isRecording = true;
        _statusMessage = 'Recording! Live preview continues.';
      } else {
        _statusMessage = 'Error: Could not start recording.';
      }
    });
  }

  // ✅ --- THIS LOGIC IS NOW MUCH SIMPLER ---
  Future<void> _onStop() async {
    setState(() => { _isLoading = true, _statusMessage = 'Processing video...' });
    try {
      final prediction = await _piService.stopAndPredict();
      if (mounted) {
        setState(() => _statusMessage = 'Prediction Complete!');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Prediction Result'),
            content: Text('Hemoglobin: ${prediction['hemoglobin']}\nConfidence: ${prediction['confidence']}'),
            actions: [ TextButton(child: const Text('OK'), onPressed: () => Navigator.of(ctx).pop()) ],
          ),
        );
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => { _isLoading = false, _isRecording = false });
      }
    }
  }

  // --- MANUAL MJPEG STREAMING IMPLEMENTATION (UNCHANGED) ---
  // This code is correct and robust for parsing the stream data.

  void _startMjpegStream() async {
    if (_isStreaming) return;
    print('Starting manual MJPEG stream...');
    _isStreaming = true;
    _httpClient = http.Client();
    final request = http.Request('GET', Uri.parse(_piService.videoStreamUrl));
    
    // The new pi_server.py doesn't require a cookie for the video feed,
    // so this header is optional but harmless.
    if (_piService.sessionCookie != null) {
      request.headers['cookie'] = _piService.sessionCookie!;
    }

    try {
      final response = await _httpClient!.send(request);
      if (response.statusCode != 200) {
        print('Stream failed with status: ${response.statusCode}');
        _stopMjpegStream();
        return;
      }
      
      final contentType = response.headers['content-type'] ?? '';
      final boundary = contentType.contains('boundary=') ? contentType.split('boundary=')[1] : 'frame';
      final boundaryBytes = utf8.encode('--$boundary');
      List<int> buffer = [];

      _streamSubscription = response.stream.listen(
        (chunk) {
          buffer.addAll(chunk);
          while (true) {
            final start = _indexOfSequence(buffer, boundaryBytes, 0);
            if (start == -1) break;

            final end = _indexOfSequence(buffer, boundaryBytes, start + boundaryBytes.length);
            if (end == -1) break;

            final frameBlock = buffer.sublist(start + boundaryBytes.length, end);
            final soi = _indexOfSequence(frameBlock, [0xFF, 0xD8], 0);
            if (soi != -1) {
              final eoi = _indexOfSequence(frameBlock, [0xFF, 0xD9], soi);
              if (eoi != -1) {
                final frame = frameBlock.sublist(soi, eoi + 2);
                if(mounted) {
                  setState(() => _latestFrame = Uint8List.fromList(frame));
                }
              }
            }
            buffer = buffer.sublist(end);
          }
        },
        onDone: () => _stopMjpegStream(),
        onError: (error) => _stopMjpegStream(),
        cancelOnError: true,
      );
    } catch (e) {
      print('Error starting MJPEG stream: $e');
      _stopMjpegStream();
    }
  }

  void _stopMjpegStream() {
    if (!_isStreaming) return;
    print('Stopping manual MJPEG stream...');
    _isStreaming = false;
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _httpClient?.close();
    _httpClient = null;
    if (mounted) setState(() => _latestFrame = null);
  }

  int _indexOfSequence(List<int> data, List<int> seq, int start) {
    if (seq.isEmpty) return -1;
    final limit = data.length - seq.length + 1;
    for (var i = start; i < limit; i++) {
      var found = true;
      for (var j = 0; j < seq.length; j++) {
        if (data[i + j] != seq[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }
  
  // --- BUILD METHOD (UNCHANGED) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pi Camera Capture')),
      body: Center(
        child: SingleChildScrollView( // Good for layout flexibility
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                width: 400,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _latestFrame != null
                      ? Image.memory(
                          _latestFrame!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text(
                                _isPiConnected ? 'Connecting to stream...' : 'Logging into Pi...',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(_statusMessage, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 20),
              if (!_isRecording)
                ElevatedButton(
                  onPressed: _isLoading || !_isPiConnected ? null : _onStart,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Start Recording'),
                ),
              if (_isRecording)
                ElevatedButton(
                  onPressed: _isLoading ? null : _onStop,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Stop & Predict'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
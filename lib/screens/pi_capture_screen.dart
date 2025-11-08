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
  String _statusMessage = 'Connecting to Pi...';

  // State variables for manual streaming are back
  http.Client? _httpClient;
  StreamSubscription<List<int>>? _streamSubscription;
  Uint8List? _latestFrame;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _piService.login('IITJ', 'BTP2025').then((success) {
      if (mounted) {
        if (success) {
          setState(() {
            _statusMessage = 'Pi Connected. Streaming preview...';
            _isPiConnected = true;
          });
          // Start the manual stream after successful login
          _startMjpegStream();
        } else {
          setState(() {
            _statusMessage = 'Pi Login Failed. Check connection.';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Crucial to stop the stream and prevent memory leaks
    _stopMjpegStream();
    super.dispose();
  }

  Future<void> _onStart() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting...';
    });
    // Stop the preview stream to free up the camera for high-res recording
    _stopMjpegStream(); 
    
    bool success = await _piService.startRecording();
    setState(() {
      _isLoading = false;
      if (success) {
        _isRecording = true;
        _statusMessage = 'Recording! Press Stop to get prediction.';
      } else {
        _statusMessage = 'Error: Could not start recording.';
        // If recording fails, restart the preview stream
        _startMjpegStream(); 
      }
    });
  }

  Future<void> _onStop() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Processing video and running model...';
    });
    try {
      final prediction = await _piService.stopAndPredict();
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Prediction Result'),
            content: Text(
              'Hemoglobin: ${prediction['hemoglobin']}\n'
              'Confidence: ${prediction['confidence']}',
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      }
      setState(() => _statusMessage = 'Ready');
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRecording = false;
        });
        // Restart the preview stream after prediction is done
        _startMjpegStream();
      }
    }
  }

  // =========================================================
  // ✅ ROBUST MANUAL STREAMING IMPLEMENTATION
  // =========================================================

  void _startMjpegStream() async {
    if (_isStreaming) return;
    
    print('Starting manual MJPEG stream...');
    _isStreaming = true;
    _httpClient = http.Client();
    final request = http.Request('GET', Uri.parse(_piService.videoStreamUrl));
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
      
      // Get the boundary string from the content-type header
      final contentType = response.headers['content-type'] ?? '';
      final boundary = contentType.contains('boundary=')
          ? contentType.split('boundary=')[1]
          : 'frame';
      final boundaryBytes = utf8.encode('--$boundary');
      
      List<int> buffer = []; // <-- THIS IS THE PERSISTENT BUFFER

      _streamSubscription = response.stream.listen(
        (chunk) {
          // Add incoming data to the buffer
          buffer.addAll(chunk);

          // Continuously search for frames in the buffer
          while (true) {
            // Find the start and end of a frame using the boundary markers
            final start = _indexOfSequence(buffer, boundaryBytes, 0);
            if (start == -1) break; // Not enough data for a start boundary

            final end = _indexOfSequence(buffer, boundaryBytes, start + boundaryBytes.length);
            if (end == -1) break; // Not enough data for a full frame yet

            // Extract the block containing one frame's data
            final frameBlock = buffer.sublist(start + boundaryBytes.length, end);
            
            // Find the actual JPEG image data (SOI and EOI markers) within the block
            final soi = _indexOfSequence(frameBlock, [0xFF, 0xD8], 0);
            if (soi != -1) {
              final eoi = _indexOfSequence(frameBlock, [0xFF, 0xD9], soi);
              if (eoi != -1) {
                final frame = frameBlock.sublist(soi, eoi + 2);
                if(mounted) {
                  setState(() {
                    _latestFrame = Uint8List.fromList(frame);
                  });
                }
              }
            }

            // Remove the processed frame from the buffer to prepare for the next one
            buffer = buffer.sublist(end);
          }
        },
        onDone: () {
          print('MJPEG stream closed');
          _stopMjpegStream();
        },
        onError: (error) {
          print('MJPEG stream error: $error');
          _stopMjpegStream();
        },
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
    if (mounted) {
      setState(() {
        _latestFrame = null;
      });
    }
  }

  // Helper function to find a sequence of bytes in a list
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
  
  // =========================================================
  // END OF STREAMING IMPLEMENTATION
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pi Camera Capture')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isPiConnected)
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
                  // This widget will now be updated correctly by the new parser
                  child: _latestFrame != null
                      ? Image.memory(
                          _latestFrame!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true, // Prevents flickering
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text(
                                'Connecting to stream...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            Text(_statusMessage, textAlign: TextAlign.center),
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
    );
  }
}
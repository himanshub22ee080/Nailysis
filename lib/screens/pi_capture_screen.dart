import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
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

  String? _streamUrl;
  http.Client? _httpClient;
  StreamSubscription<List<int>>? _streamSubscription;
  Uint8List? _latestFrame;
  bool _isStreaming = false;
  int _frameCount = 0;

  @override
  void initState() {
    super.initState();
    _piService.login('IITJ', 'BTP2025').then((success) {
      if (success) {
        setState(() {
          _statusMessage = 'Pi Connected. Ready to record.';
          _isPiConnected = true;
          _streamUrl = _piService.videoStreamUrl;
          _startMjpegStream();
        });
      } else {
        setState(() {
          _statusMessage = 'Pi Login Failed. Check connection.';
        });
      }
    });
  }

  @override
  void dispose() {
    _stopMjpegStream();
    super.dispose();
  }

  Future<void> _onStart() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting...';
    });
    bool success = await _piService.startRecording();
    setState(() {
      _isLoading = false;
      if (success) {
        _isRecording = true;
        _statusMessage = 'Recording! Press Stop to get prediction.';
        _stopMjpegStream();
      } else {
        _statusMessage = 'Error: Could not start recording.';
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
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Prediction Result'),
          content: Text(
            'Hemoglobin: ${prediction['hemoglobin']}\n'
            'Confidence: ${prediction['confidence']}',
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
      setState(() => _statusMessage = 'Ready');
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
        _isRecording = false;
        _startMjpegStream();
      });
    }
  }

  // ==============================
  // 📷 START MJPEG STREAM (patched)
  // ==============================
  void _startMjpegStream() async {
    if (_isStreaming || _streamUrl == null) return;

    _httpClient = http.Client();
    final req = http.Request('GET', Uri.parse(_streamUrl!));

    if (_piService.sessionCookie != null) {
      req.headers['cookie'] = _piService.sessionCookie!;
    }

    print('Fetching MJPEG from $_streamUrl with cookie: ${_piService.sessionCookie}');
    
    http.StreamedResponse? resp;
    try {
      resp = await _httpClient!.send(req).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('MJPEG connection error: $e');
      setState(() => _statusMessage = 'Preview connection error: $e');
      _httpClient?.close();
      _httpClient = null;
      return;
    }

if (resp!.statusCode != 200) {
  final snippet = await resp.stream.transform(utf8.decoder).join();
  print('Stream failed (${resp.statusCode}): $snippet');
  setState(() => _statusMessage = 'Stream failed (${resp!.statusCode})');
  _httpClient?.close();
  _httpClient = null;
  return;
}

    print('✅ MJPEG stream connected');
    print('Response headers: ${resp.headers}');
    setState(() => _statusMessage = 'Streaming preview...');
    _isStreaming = true;

    final ct = resp.headers['content-type'];
    final boundary = ct != null && ct.contains('boundary=')
        ? ct.split('boundary=')[1]
        : 'frame';
    print('Detected boundary: $boundary');
    final boundaryBytes = utf8.encode('--$boundary');

    List<int> buffer = [];

    _streamSubscription = resp.stream.listen((chunk) {
      print('Received chunk of size: ${chunk.length}');
      buffer.addAll(chunk);

      // check if JPEG markers exist in chunk (for debugging)
      if (chunk.contains(0xFF) && chunk.contains(0xD8)) {
        print('Chunk contains JPEG start marker!');
      }

      bool foundFrame = false;

      while (true) {
        final start = _indexOfSequence(buffer, boundaryBytes, 0);
        if (start < 0) break;

        final next =
            _indexOfSequence(buffer, boundaryBytes, start + boundaryBytes.length);
        if (next < 0) break;

        final frameBlock = buffer.sublist(start + boundaryBytes.length, next);
        buffer = buffer.sublist(next);

        final soi = _indexOfSequence(frameBlock, [0xFF, 0xD8], 0);
        final eoi = _indexOfSequence(frameBlock, [0xFF, 0xD9], soi + 2);
        if (soi >= 0 && eoi > soi) {
          final frame = frameBlock.sublist(soi, eoi + 2);
          _latestFrame = Uint8List.fromList(frame);
          _frameCount++;
          foundFrame = true;
          if ((_frameCount % 10) == 0) {
            print('✅ Frames received: $_frameCount');
          }
          if (mounted) setState(() {});
        } else {
          print('⚠️ Frame block had no JPEG markers.');
        }
      }

      // fallback if no boundary found but JPEG exists
      if (!foundFrame) {
        final soi = _indexOfSequence(buffer, [0xFF, 0xD8], 0);
        final eoi = _indexOfSequence(buffer, [0xFF, 0xD9], soi + 2);
        if (soi >= 0 && eoi > soi) {
          final frame = buffer.sublist(soi, eoi + 2);
          buffer = buffer.sublist(eoi + 2);
          _latestFrame = Uint8List.fromList(frame);
          _frameCount++;
          print('✅ Fallback frame parsed (#$_frameCount)');
          if (mounted) setState(() {});
        }
      }
    }, onDone: () {
      print('MJPEG stream closed');
      _isStreaming = false;
      _httpClient?.close();
      _httpClient = null;
    }, onError: (e) {
      print('Stream error: $e');
      _isStreaming = false;
      _httpClient?.close();
      _httpClient = null;
    }, cancelOnError: true);
  }

  void _stopMjpegStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    try {
      _httpClient?.close();
    } catch (_) {}
    _httpClient = null;
    _isStreaming = false;
  }

  // helper to find a byte sequence
  int _indexOfSequence(List<int> data, List<int> seq, int start) {
    final sl = seq.length;
    final limit = data.length - sl + 1;
    for (var i = start; i < limit; i++) {
      var ok = true;
      for (var j = 0; j < sl; j++) {
        if (data[i + j] != seq[j]) {
          ok = false;
          break;
        }
      }
      if (ok) return i;
    }
    return -1;
  }

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
                  child: _latestFrame != null
                      ? Image.memory(
                          _latestFrame!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            Text(_statusMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            if (!_isRecording)
              ElevatedButton(
                onPressed: _isLoading ? null : _onStart,
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

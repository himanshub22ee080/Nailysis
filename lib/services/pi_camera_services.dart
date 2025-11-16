// lib/services/pi_camera_services.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class PiCameraService {
  // ❗ REMEMBER TO SET YOUR PI's IP ADDRESS HERE
  final String _piUrl = 'http://192.168.137.131:5000';
  String? _sessionCookie;

  String? get sessionCookie => _sessionCookie;
  String get videoStreamUrl => '$_piUrl/app_video_feed';

  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      _sessionCookie = rawCookie.split(';')[0];
    }
  }

  Map<String, String> _getHeaders() {
    // We only need the cookie for authenticated routes
    return {
      if (_sessionCookie != null) 'cookie': _sessionCookie!,
      'Content-Type': 'application/json',
    };
  }

  /// Logs in to the Raspberry Pi server.
  Future<bool> login(String username, String password) async {
    try {
      // ✅ FIX: Use the correct endpoint '/login'
      final response = await http.post(
        Uri.parse('$_piUrl/login'), 
        // ✅ FIX: Send credentials as a JSON object
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        _updateCookie(response);
        return true;
      } else {
        print('Pi Login failed (status: ${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print('Pi Login Error: $e');
      return false;
    }
  }

  /// Tells the Pi to start recording.
  Future<bool> startRecording() async {
    try {
      final response = await http.post(
        Uri.parse('$_piUrl/start_record'),
        headers: _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Pi Start Error: $e');
      return false;
    }
  }

  /// Stops recording and gets the prediction from the DL server.
  Future<Map<String, dynamic>> stopAndPredict() async {
    try {
      final response = await http
          .post(
            Uri.parse('$_piUrl/stop_and_predict'),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode != 200) {
        throw Exception('Failed to get prediction (status: ${response.statusCode}): ${response.body}');
      }
      
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw const FormatException('Unexpected JSON shape from server.');
      }
    } catch (e) {
      print('Pi Predict Error: $e');
      rethrow;
    }
  }
}
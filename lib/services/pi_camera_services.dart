import 'package:http/http.dart' as http;
import 'dart:convert';

class PiCameraService {
  final String _piUrl = 'http://192.168.137.131:5000';
  String? _sessionCookie;

  // ✅ --- ADD THIS GETTER ---
  /// Returns the session cookie needed for authenticated requests.
  String? get sessionCookie => _sessionCookie;

  // ✅ --- ADD THIS GETTER ---
  /// Returns the full URL for the video stream.
  String get videoStreamUrl => '$_piUrl/video_feed';

  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      _sessionCookie = rawCookie.split(';')[0];
    }
  }

  // ... (rest of your file is the same) ...
  Map<String, String> _getHeaders() {
    return {'cookie': _sessionCookie ?? ''};
  }

  /// Logs in to the Raspberry Pi server.
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_piUrl/api/login'),
        body: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        _updateCookie(response);
        return true;
      } else {
        // Log body for easier debugging when login fails
        print(
            'Pi Login failed (status: ${response.statusCode}): ${response.body}');
      }
      return false;
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
        headers: _getHeaders(), // Send the cookie
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
            headers: _getHeaders(), // Send the cookie
          )
          .timeout(const Duration(seconds: 90)); // Give it time

      // Check status code first
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to get prediction (status: ${response.statusCode}): ${_shorten(response.body)}');
      }

      // Verify content-type is JSON before decoding
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        // The server returned HTML (likely an error page) or unexpected content.
        // Provide a helpful error that includes a short snippet of the body.
        throw FormatException(
            'Expected JSON response but got "$contentType". Body snippet: ${_shorten(response.body)}');
      }

      // Decode JSON safely
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        // If it's not the expected shape, surface a clear error
        throw FormatException(
            'Unexpected JSON shape. Expected an object but got: ${decoded.runtimeType}');
      } catch (e) {
        // Rewrap decode errors with body snippet for debugging
        throw FormatException(
            'Failed to parse JSON prediction response: $e. Body snippet: ${_shorten(response.body)}');
      }
    } catch (e) {
      print('Pi Predict Error: $e');
      rethrow;
    }
  }

  // Helper to shorten long response bodies for logs/errors
  String _shorten(String? s, [int max = 500]) {
    if (s == null) return '';
    final clean = s.replaceAll('\n', ' ');
    if (clean.length <= max) return clean;
    return '${clean.substring(0, max)}...';
  }
}

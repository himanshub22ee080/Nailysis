// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // ❗️❗️❗️ CRITICAL: REPLACE WITH YOUR COMPUTER'S IP ADDRESS ❗️❗️❗️
  // Android Emulator: 'http://10.0.2.2:5000'
  // Physical Device on same Wi-Fi: 'http://YOUR_COMPUTER_IP:5000'
  static const String _baseUrl = 'http://172.31.22.100:5000'; 

  Future<double?> uploadVideoForPrediction(String videoPath) async {
    try {
      final uri = Uri.parse('$_baseUrl/predict');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'video', 
          videoPath,
          contentType: MediaType('video', 'mp4'),
        ),
      );

      print('Uploading video to $uri...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Prediction received: $data');
        return data['hemoglobin'].toDouble();
      } else {
        print('Error from server: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Failed to upload video: $e');
      return null;
    }
  }
}
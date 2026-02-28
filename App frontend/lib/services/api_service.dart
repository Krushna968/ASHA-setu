import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // Base URL for the local backend
  // 10.0.2.2 is used for Android emulator to access the host machine's localhost
  // If running on a physical device, replace with your PC's local IP address (e.g., 192.168.1.x)
  static const String baseUrl = 'http://10.75.109.134:5000/api';

  // Include token in header
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication: Generate and Send OTP
  static Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobileNumber': mobileNumber}),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: Failed to connect to backend server'};
    }
  }

  // Authentication: Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobileNumber': mobileNumber, 'otp': otp}),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: Failed to connect to backend server'};
    }
  }

  // Get data (Helpers)
  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    
    if (response.statusCode == 401) {
      // Handle unauthorized (token expired etc)
      await AuthService.logout();
      throw Exception('Unauthorized');
    }
    
    return json.decode(response.body);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'), 
      headers: headers,
      body: json.encode(body)
    );
    
    return json.decode(response.body);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'), 
      headers: headers,
      body: json.encode(body)
    );
    
    return json.decode(response.body);
  }

  // Upload a file using MultipartRequest
  static Future<dynamic> postMultipart(String endpoint, String filePath, String fileField) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return json.decode(response.body);
  }
}

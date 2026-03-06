import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../main.dart'; // Import to use navigatorKey

class ApiService {
  // Base URL for the production backend on Render
  // static const String baseUrl = 'https://asha-setu-backend.onrender.com/api';
  static const String baseUrl = 'http://10.75.109.137:5000/api';

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

  static Future<void> _handleUnauthorized() async {
    // If we're in Mock/Testing mode, don't auto-logout.
    // This allows the app to continue for demo purposes even if calls fail.
    final bool isMock = await AuthService.isMockMode();
    if (isMock) {
       debugPrint('⚠️ Unauthorized call in Mock Mode. Skipping auto-logout.');
       return;
    }

    await AuthService.logout();
    if (navigatorKey.currentContext != null) {
      Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentContext!, '/login', (route) => false);
    }
  }

  // Get AI Itinerary
  static Future<List<dynamic>> getAiItinerary() async {
    try {
      final response = await get('/ai/itinerary');
      if (response != null && response['itinerary'] != null) {
        return response['itinerary'];
      }
      return [];
    } catch (e) {
      debugPrint("Failed to fetch AI itinerary: $e");
      return [];
    }
  }

  // Get data (Helpers)
  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    
    if (response.statusCode == 401) {
      await _handleUnauthorized();
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
    
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception('Unauthorized');
    }
    
    return json.decode(response.body);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'), 
      headers: headers,
      body: json.encode(body)
    );
    
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception('Unauthorized');
    }
    
    return json.decode(response.body);
  }

  static Future<dynamic> postMultipart(String endpoint, String filePath, String fileField) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      throw Exception('Unauthorized');
    }
    
    return json.decode(response.body);
  }
}

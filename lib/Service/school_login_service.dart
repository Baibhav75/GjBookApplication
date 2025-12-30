import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../Model/school_login_model.dart';

class SchoolLoginService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/SchoolLogin/SchoolLogin";
  
  static const Duration _timeoutDuration = Duration(seconds: 20);

  /// Login with mobile number and password
  /// Returns SchoolLoginModel on success
  /// Throws Exception on failure with descriptive message
  static Future<SchoolLoginModel> login({
    required String mobile,
    required String password,
  }) async {
    // Validate input parameters
    if (mobile.trim().isEmpty) {
      throw Exception('Mobile number is required');
    }
    
    if (password.trim().isEmpty) {
      throw Exception('Password is required');
    }

    try {
      // Build URI with proper query parameters encoding
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'MobileNo': mobile.trim(),
        'Password': password.trim(),
      });

      if (kDebugMode) {
        debugPrint('🔐 School Login Request: $uri');
      }

      // Send GET request with timeout
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(_timeoutDuration);

      if (kDebugMode) {
        debugPrint('📡 School Login Response Status: ${response.statusCode}');
        debugPrint('📄 School Login Response Body: ${response.body}');
      }

      // Check HTTP status code
      if (response.statusCode == 200) {
        try {
          // Parse JSON response
          final jsonData = jsonDecode(response.body);
          
          // Validate response is a Map
          if (jsonData is! Map<String, dynamic>) {
            throw Exception('Invalid response format from server');
          }
          
          // Create model from JSON
          final loginModel = SchoolLoginModel.fromJson(jsonData);
          
          if (kDebugMode) {
            debugPrint('✅ School Login Success: ${loginModel.status}');
          }
          
          return loginModel;
        } catch (jsonError) {
          if (kDebugMode) {
            debugPrint('❌ JSON Decode Error: $jsonError');
            debugPrint('Response body: ${response.body}');
          }
          throw Exception('Invalid response format from server');
        }
      } else {
        // Handle non-200 status codes
        if (kDebugMode) {
          debugPrint('❌ Server Error: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('⏱️ Request timeout after $_timeoutDuration');
      }
      throw Exception('Request timeout. Please check your internet connection.');
    } on SocketException {
      if (kDebugMode) {
        debugPrint('🌐 Network error: No internet connection');
      }
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      // Re-throw if it's already an Exception
      if (e is Exception) {
        rethrow;
      }
      // Wrap other errors
      if (kDebugMode) {
        debugPrint('❌ School Login Error: $e');
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}

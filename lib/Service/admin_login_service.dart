import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookworld/Model/login_model.dart';


class AdminLoginService {
  static const String baseUrl = 'https://g17bookworld.com/API/Login';


  Future<LoginModel> performLogin({
    required String mobileNo,
    required String password,
  }) async {
    // Try different methods in sequence
    final methods = [
      _tryGetMethod,
      _tryPostMethod,
      _tryPostWithJson,
    ];

    List<String> errorMessages = [];

    for (var method in methods) {
      try {
        final result = await method(mobileNo, password);
        return result;
      } catch (e) {
        final errorMsg = e.toString();
        errorMessages.add(errorMsg);
        print('Login method failed: $errorMsg');
        // Continue to try next method
        continue;
      }
    }

    // Log all errors for debugging
    print('All login methods failed. Errors: ${errorMessages.join(", ")}');
    
    // Provide more detailed error message
    String errorDetail = errorMessages.isNotEmpty 
        ? errorMessages.first.replaceAll('Exception: ', '')
        : 'Unknown error';
    
    throw Exception('All login methods failed. Error: $errorDetail. Please check your connection and try again.');
  }

  Future<LoginModel> _tryGetMethod(String mobileNo, String password) async {
    final url = Uri.parse('$baseUrl/Login?MobileNo=$mobileNo&Password=$password');

    print('Trying GET: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print('GET Response Status: ${response.statusCode}');
      print('GET Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('GET failed with status: ${response.statusCode}, body: ${response.body}');
      }

      return _parseResponse(response.body);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('GET request failed: ${e.toString()}');
    }
  }

  Future<LoginModel> _tryPostMethod(String mobileNo, String password) async {
    final url = Uri.parse('$baseUrl/Login');

    final body = 'MobileNo=$mobileNo&Password=$password';

    print('Trying POST with form data: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('POST Response Status: ${response.statusCode}');
      print('POST Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('POST form failed with status: ${response.statusCode}, body: ${response.body}');
      }

      return _parseResponse(response.body);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('POST request failed: ${e.toString()}');
    }
  }

  Future<LoginModel> _tryPostWithJson(String mobileNo, String password) async {
    final url = Uri.parse('$baseUrl/Login');

    final body = json.encode({
      'MobileNo': mobileNo,
      'Password': password,
    });

    print('Trying POST with JSON: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('POST JSON Response Status: ${response.statusCode}');
      print('POST JSON Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('POST JSON failed with status: ${response.statusCode}, body: ${response.body}');
      }

      return _parseResponse(response.body);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('POST JSON request failed: ${e.toString()}');
    }
  }

  LoginModel _parseResponse(String responseBody) {
    try {
      final Map<String, dynamic> responseData = json.decode(responseBody);
      return LoginModel.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  bool isValidMobileNumber(String mobileNo) {
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    return mobileRegex.hasMatch(mobileNo);
  }

  bool isValidPassword(String password) {
    return password.length >= 3;
  }
}
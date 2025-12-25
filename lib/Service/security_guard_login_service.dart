import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/security_guard_login_model.dart';

class SecurityGuardLoginService {
  static const String _baseUrl =
      'https://g17bookworld.com/API/AgentLogin/EmployeeLogin';

  static Future<SecurityGuardLoginModel> login({
    required String mobile,
    required String password,
    required String position, // 🔥 NEW
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'MobileNo': mobile,
        'Password': password,
        'Position': position, // 🔥 DYNAMIC
      });

      print("Login Request: $uri");

      final response =
      await http.get(uri).timeout(const Duration(seconds: 20));

      print("Login Response Status: ${response.statusCode}");
      print("Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          return SecurityGuardLoginModel.fromJson(jsonData);
        } catch (jsonError) {
          print("JSON Decode Error: $jsonError");
          throw Exception("Invalid response format from server");
        }
      } else {
        throw Exception('Login failed with status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Login error: $e');
    }
  }
}

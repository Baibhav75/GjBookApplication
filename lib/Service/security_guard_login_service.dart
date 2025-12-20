import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/security_guard_login_model.dart';

class SecurityGuardLoginService {
  static const String _baseUrl =
      'https://g17bookworld.com/API/AgentLogin/EmployeeLogin';

  static Future<SecurityGuardLoginModel> login({
    required String mobile,
    required String password,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'MobileNo': mobile,
      'Password': password,
      'Position': 'SecurityGuard',
    });

    final response =
    await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return SecurityGuardLoginModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception('SecurityGuard login failed');
    }
  }
}

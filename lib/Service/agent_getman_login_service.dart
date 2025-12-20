import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agent_getman_login_model.dart';

class AgentGetManLoginService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/AgentLogin/EmployeeLogin";

  static Future<AgentGetManLoginModel> login({
    required String mobile,
    required String password,
    required String position, // Agent / GetMan
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      "MobileNo": mobile,
      "Password": password,
      "Position": position,
    });

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return AgentGetManLoginModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  }
}

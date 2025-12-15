import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agent_login_model.dart';

class AgentLoginService {
  Future<AgentLoginModel?> login({
    required String mobile,
    required String password,
    required String employeeType,
  }) async {
    try {
      final url =
      Uri.parse("https://g17bookworld.com/API/AgentLogin/EmployeeLogin"
          "?MobileNo=$mobile&Password=$password&EmployeeType=$employeeType");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AgentLoginModel.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      print("Login API Error: $e");
      return null;
    }
  }
}

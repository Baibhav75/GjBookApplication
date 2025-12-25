import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agent_login_model.dart';

class AgentLoginService {
  Future<AgentLoginModel?> login({
    required String mobile,
    required String password,
    required String position,
  }) async {
    try {
      final url =
      Uri.parse("https://g17bookworld.com/API/AgentLogin/EmployeeLogin"
          "?MobileNo=$mobile&Password=$password&Position=$position");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Add the mobile number to the response data
        final modifiedData = Map<String, dynamic>.from(jsonData);
        modifiedData['MobileNo'] = mobile;
        return AgentLoginModel.fromJson(modifiedData);
      } else {
        return null;
      }
    } catch (e) {
      print("Login API Error: $e");
      return null;
    }
  }
}

import 'dart:convert';
import 'package:bookworld/Model/school_agent_Model.dart';
import 'package:http/http.dart' as http;

class SchoolAgentService {
  static const String _baseUrl = 'https://g17bookworld.com/API/SchoolListByAgent/SchoolListAgent';

  Future<schoolAgent_Model?> getSchoolListByAgent(String agentId) async {
    final uri = Uri.parse('$_baseUrl?AgentId=$agentId');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return schoolAgent_Model.fromJson(jsonResponse);
      } else {
        // Handle server errors or non-200 responses
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle network errors
      print('Error fetching school list: $e');
      return null;
    }
  }
}

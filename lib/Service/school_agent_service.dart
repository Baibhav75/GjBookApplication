import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/school_agent_model.dart';

class SchoolAgentService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/SchoolListByAgent/SchoolListAgent";

  Future<List<SchoolAgent>> fetchSchoolsByAgent(String agentId) async {
    final url = Uri.parse("$_baseUrl?AgentId=$agentId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final result = SchoolAgentResponse.fromJson(jsonData);
      return result.data;
    } else {
      throw Exception("Failed to load school list");
    }
  }
}

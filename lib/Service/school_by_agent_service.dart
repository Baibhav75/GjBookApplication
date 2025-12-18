import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/schoolByAgent_model.dart';

class SchoolByAgentService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/SchoolListByAgent/SchoolListAgent";

  Future<List<Data>> fetchSchoolsByAgent(String agentId) async {
    final url = Uri.parse("$_baseUrl?AgentId=$agentId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final model = schoolByAgent_model.fromJson(decoded);
      return model.data ?? [];
    } else {
      throw Exception("Failed to load school list");
    }
  }
}

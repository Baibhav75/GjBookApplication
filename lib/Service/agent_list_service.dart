import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agent_list_model.dart';

class AgentListService {
  static const String _url =
      'https://g17bookworld.com/API/AgentList/GetEmployee';

  static Future<AgentListResponse> fetchAgentList() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return AgentListResponse.fromJson(decoded);
    } else {
      throw Exception("Failed to load agent list");
    }
  }
}

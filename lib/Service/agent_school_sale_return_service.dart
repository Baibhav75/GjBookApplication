import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agent_school_sale_return_model.dart';

class AgentSchoolSaleReturnService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/AgentSaleReturn/AgentSchoolReturn';

  static Future<AgentSchoolSaleReturnResponse> getAgentSchoolReturn({
    required String agentId,
  }) async {
    final uri = Uri.parse("$_baseUrl?agentId=$agentId");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return AgentSchoolSaleReturnResponse.fromJson(decoded);
    } else {
      throw Exception(
        "Server error: ${response.statusCode}",
      );
    }
  }
}

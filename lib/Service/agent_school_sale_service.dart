import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agent_school_sale_model.dart';

class AgentSchoolSaleService {
  static const String _baseUrl =
      "https://g17bookworld.com/api/AgentSaleDetails/AgentSchoolSale";

  static Future<AgentSchoolSaleResponse> getAgentSchoolSale({
    required String agentId,
  }) async {
    final uri = Uri.parse("$_baseUrl?agentId=$agentId");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return AgentSchoolSaleResponse.fromJson(decoded);
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  }
}

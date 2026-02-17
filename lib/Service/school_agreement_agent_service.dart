import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/school_agreement_agent_model.dart';

class SchoolAgreementAgentService {
  static const String apiUrl =
      "https://g17bookworld.com/API/AgentList/GetEmployee";

  Future<List<AgentItem>> fetchAgents() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final model = SchoolAgreementAgentModel.fromJson(decoded);
      return model.employeeList;
    } else {
      throw Exception("Failed to load agents");
    }
  }
}

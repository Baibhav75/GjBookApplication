import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/update_school_by_agent_model.dart';

class UpdateSchoolByAgentService {
  static const String _url =
      "https://g17bookworld.com/api/UpdateSchoolByAgent";

  Future<UpdateSchoolByAgentResponse> updateSchool(
      UpdateSchoolByAgentRequest request) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UpdateSchoolByAgentResponse.fromJson(data);
    } else {
      throw Exception(
        "Failed to update school (Status: ${response.statusCode})",
      );
    }
  }
}

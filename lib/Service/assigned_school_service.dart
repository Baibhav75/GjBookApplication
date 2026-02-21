import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/assigned_school_model.dart';

class AssignedSchoolService {
  static const String baseUrl =
      "https://g17bookworld.com/api/AssignSchoolList/GetSchool";

  Future<RecovertAssignedSchoolModel?> fetchAssignedSchools(String employeeId) async {
    try {
      final cleanId = employeeId.trim();
      final url = "$baseUrl?EmployeeId=$cleanId";
      
      print("Fetching Schools from: $url");
      
      final response = await http.get(Uri.parse(url));

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return RecovertAssignedSchoolModel.fromJson(jsonData);
      } else {
        print("API Error (${response.statusCode}): ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in fetchAssignedSchools: $e");
      return null;
    }
  }
}
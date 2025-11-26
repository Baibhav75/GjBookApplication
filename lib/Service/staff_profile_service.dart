import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/staff_profile_model.dart';

class StaffProfileService {
  final String baseUrl =
      "https://gj.realhomes.co.in/API/EmployeeProfile/EmployeeProfile";

  Future<StaffProfileModel?> fetchProfile(String mobileNo) async {
    final url = Uri.parse("$baseUrl?MobileNo=$mobileNo");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["status"] == "success") {
          return StaffProfileModel.fromJson(jsonData);
        } else {
          return null;
        }
      }
    } catch (e) {
      print("Profile fetch error: $e");
    }
    return null;
  }
}

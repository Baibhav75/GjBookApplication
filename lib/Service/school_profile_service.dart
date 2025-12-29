import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/school_profile_model.dart';

class SchoolProfileService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/SchoolProfile/Profile";

  static Future<SchoolProfileModel> fetchProfile(
      {required String mobileNo}) async {
    final uri = Uri.parse("$_baseUrl?MobileNo=$mobileNo");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['status'] != 'success') {
        throw Exception(decoded['message'] ?? "Failed to load profile");
      }

      return SchoolProfileModel.fromJson(decoded['data']);
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }
}

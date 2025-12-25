import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/getman_profile_model.dart';

class GetManProfileService {
  static const String _baseUrl =
      'https://g17bookworld.com/API/EmployeeProfile/EmployeeProfile';

  Future<GetManProfileModel> fetchProfile(String mobileNo) async {
    final url = Uri.parse('$_baseUrl?MobileNo=$mobileNo');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body['status'] == 'success') {
        return GetManProfileModel.fromJson(body['data']);
      } else {
        throw Exception(body['message']);
      }
    } else {
      throw Exception('Failed to load profile');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/counter_profile_model.dart';

class CounterProfileService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/CounterProfile/Profile";

  static Future<CounterProfileModel> fetchProfile({
    required String mobileNo,
  }) async {
    final uri = Uri.parse("$_baseUrl?MobileNo=$mobileNo");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return CounterProfileModel.fromJson(decoded);
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  }
}

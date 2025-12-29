import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/school_login_model.dart';

class SchoolLoginService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/SchoolLogin/SchoolLogin";

  static Future<SchoolLoginModel> login({
    required String mobile,
    required String password,
  }) async {
    final uri =
    Uri.parse("$_baseUrl?MobileNo=$mobile&Password=$password");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return SchoolLoginModel.fromJson(decoded);
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }
}

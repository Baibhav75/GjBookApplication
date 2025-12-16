import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/hr_login_model.dart';

class HrLoginService {
  static const String _baseUrl =
      'https://g17bookworld.com/API/HRLogin/Login';

  Future<HrLoginModel> hrLogin({
    required String mobile,
    required String password,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?MobileNo=$mobile&Password=$password',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return HrLoginModel.fromJson(data);
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}

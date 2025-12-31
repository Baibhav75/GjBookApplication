import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/counter_login_model.dart';

class CounterLoginService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/CounterLogin/Counter";

  static Future<CounterLoginModel> login({
    required String mobileNo,
    required String password,
  }) async {
    final uri = Uri.parse(
      "$_baseUrl?MobileNo=$mobileNo&Password=$password",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return CounterLoginModel.fromJson(decoded);
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  }
}

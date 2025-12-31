import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/counter_change_password_model.dart';

class CounterChangePasswordService {
  static const String _baseUrl =
      "https://g17bookworld.com/api/CounterChangePassword/ChangePassword";

  static Future<CounterChangePasswordModel> changePassword({
    required String mobileNo,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse(
      "$_baseUrl"
          "?MobileNo=$mobileNo"
          "&OldPassword=$oldPassword"
          "&NewPassword=$newPassword"
          "&ConfirmPassword=$confirmPassword",
    );

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return CounterChangePasswordModel.fromJson(decoded);
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  }
}

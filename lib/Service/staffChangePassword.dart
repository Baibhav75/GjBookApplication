import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/staffChangePassword.dart';

class ChangePasswordService {
  static const String baseUrl =
      "https://gj.realhomes.co.in/API/EmpChangePassword/ChangePassword";

  static Future<ChangePasswordModel> changePassword({
    required String mobileNo,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url =
        "$baseUrl?MobileNo=$mobileNo&OldPassword=$oldPassword&NewPassword=$newPassword&ConfirmPassword=$confirmPassword";

    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return ChangePasswordModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Something went wrong! Status: ${response.statusCode}");
    }
  }
}

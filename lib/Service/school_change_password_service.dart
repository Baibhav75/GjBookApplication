import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/school_change_password_model.dart';

class SchoolChangePasswordService {
  static const String _baseUrl =
      "https://g17bookworld.com/api/SchoolChangePassword/ChangePassword";

  static Future<SchoolChangePasswordModel?> changePassword({
    required String mobileNo,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final Uri url = Uri.parse(
        "$_baseUrl"
            "?MobileNo=$mobileNo"
            "&OldPassword=$oldPassword"
            "&NewPassword=$newPassword"
            "&ConfirmPassword=$confirmPassword",
      );

      final response = await http.post(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return SchoolChangePasswordModel.fromJson(jsonData);
      } else {
        return SchoolChangePasswordModel(
          status: "Error",
          message: "Server error (${response.statusCode})",
        );
      }
    } catch (e) {
      return SchoolChangePasswordModel(
        status: "Error",
        message: "Something went wrong",
      );
    }
  }
}

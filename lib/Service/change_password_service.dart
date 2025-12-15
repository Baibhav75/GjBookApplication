import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookworld/Model/change_password_model.dart';

class ChangePasswordService {
  static const String baseUrl = 'https://g17bookworld.com/api/ChangePass/ChangePassword';

  Future<ChangePasswordModel> changePassword({
    required String mobileNo,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Build URL with query parameters
      final url = Uri.parse(
        '$baseUrl?MobileNo=$mobileNo&OldPassword=$oldPassword&NewPassword=$newPassword&ConfirmPassword=$confirmPassword',
      );

      print('Change Password API Call: $url');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        throw Exception('Failed to change password. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error changing password: $e');
      if (e.toString().contains('TimeoutException') || e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      throw Exception('Failed to change password: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  ChangePasswordModel _parseResponse(String responseBody) {
    try {
      final Map<String, dynamic> responseData = json.decode(responseBody);
      return ChangePasswordModel.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  bool isValidMobileNumber(String mobileNo) {
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    return mobileRegex.hasMatch(mobileNo);
  }

  bool isValidPassword(String password) {
    return password.length >= 3;
  }
}



















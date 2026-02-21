import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/verify_payment_otp_model.dart';

class VerifyPaymentOtpService {

  Future<VerifyPaymentOtpModel?> verifyOtp(
      String schoolId,
      String otp,
      ) async {

    final url = Uri.parse(
        "https://g17bookworld.com/API/VerifyOtp/VerifyPaymentOTP?SchoolId=$schoolId&OTP=$otp"
    );

    final response = await http.post(url);

    print("Verify Response: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return VerifyPaymentOtpModel.fromJson(jsonData);
    }

    return null;
  }
}
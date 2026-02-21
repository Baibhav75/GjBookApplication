import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/send_payment_otp_model.dart';

class SendPaymentOtpService {

  Future<bool> sendOtp(String schoolId, int amount) async {

    final url = Uri.parse(
        "https://g17bookworld.com/API/AddPayment/SendPaymentOTP");

    final body = SendPaymentOtpModel(
      schoolId: schoolId,
      amount: amount,
    ).toJson();

    try {
      print("Sending OTP to URL: $url");
      print("Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = SendPaymentOtpModel.fromResponse(data);

        if (model.status?.toLowerCase() == "success") {
          return true;
        } else {
          print("OTP Error Message: ${model.message}");
        }
      }

      return false;

    } catch (e) {
      print("Exception in SendPaymentOtpService: $e");
      return false;
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Model/school_discount_agreement_model.dart';
import '../Model/school_discount_agreement_response_model.dart';

class SchoolDiscountAgreementService {
  static const String apiUrl =
      "https://g17bookworld.com/api/OrderAgreement/AddAgreement";

  Future<SchoolDiscountAgreementResponseModel> submitAgreement(
      SchoolDiscountAgreementModel model) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: const {
          "Content-Type": "application/json",
        },
        body: jsonEncode(model.toJson()),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return SchoolDiscountAgreementResponseModel.fromJson(decoded);
      } else {
        throw Exception(decoded["message"] ?? "Server Error");
      }
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }
}

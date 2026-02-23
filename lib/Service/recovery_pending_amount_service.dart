import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../Model/RecoveryPendingAmount_Model.dart';

class RecoveryPendingAmountService {
  Future<List<RecoveryPendingAmountModel>> fetchPendingPayments(
      String employeeId) async {
    final url = Uri.parse(
      "https://g17bookworld.com/api/RecoveryPendingAmount/GetPendingPayment?employeeId=$employeeId",
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      log("Pending API Response Status: ${response.statusCode}");
      log("Pending API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        return jsonList
            .map((e) => RecoveryPendingAmountModel.fromJson(e))
            .toList();
      } else {
        log("API Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e, stackTrace) {
      log("Fetch Pending Payments Error: $e", stackTrace: stackTrace);
    }

    return [];
  }
}
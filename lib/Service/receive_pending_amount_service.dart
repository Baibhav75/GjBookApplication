import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/receive_pending_amount_model.dart';

class ReceivePendingAmountService {

  Future<ReceivePendingAmountModel?> fetchAmounts(String employeeId) async {

    final url =
        "https://g17bookworld.com/api/RecoveryPendingOrRecivedAmount/GetRecoveryAmount?employeeId=$employeeId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReceivePendingAmountModel.fromJson(data);
    } else {
      return null;
    }
  }
}
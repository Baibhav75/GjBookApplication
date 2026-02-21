import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/recover_collect_amount_model.dart';

class RecoverCollectAmountService {

  Future<RecoverCollectAmountModel?> fetchDueAmount(String schoolId) async {
    final url =
        "https://g17bookworld.com/api/SchoolDueAmount/GetDueAmount?SchoolId=$schoolId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return RecoverCollectAmountModel.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
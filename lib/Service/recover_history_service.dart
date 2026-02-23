import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/recover_history_list_model.dart';

class RecoverHistoryService {
  Future<List<RecoverHistoryListModel>> fetchRecoveryHistory(
      String employeeId) async {
    final url =
        "https://g17bookworld.com/api/RecivedAmountFromRecovery/GetRecivedPayment?employeeId=$employeeId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => RecoverHistoryListModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load recovery history");
    }
  }
}
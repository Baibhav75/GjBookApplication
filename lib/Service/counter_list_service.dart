import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/counter_recovery_list_model.dart';

class CounterListService {
  static const String baseUrl =
      "https://g17bookworld.com/API/CounetrList/GetCounters";

  Future<List<CounterRecoveryListModel>> fetchCounters() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data
          .map((e) => CounterRecoveryListModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load counters");
    }
  }
}
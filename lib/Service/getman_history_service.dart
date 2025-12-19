import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/getman_history_model.dart';

class GetManHistoryService {
  static const String _url =
      "https://g17bookworld.com/API/InOutList";

  Future<GetManHistoryModel?> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        return GetManHistoryModel.fromJson(
          jsonDecode(response.body),
        );
      }
    } catch (e) {
      print("GetMan History Error: $e");
    }
    return null;
  }
}

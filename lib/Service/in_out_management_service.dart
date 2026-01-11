import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/in_out_management_model.dart';

class InOutManagementService {
  static const String _url =
      "https://g17bookworld.com/API/InOutList";

  static Future<List<InOutManagementModel>> fetchInOutList() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception("Server Error ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);

    if (decoded['Status'] != true) {
      throw Exception(decoded['Message'] ?? "Failed to load data");
    }

    final List list = decoded['Data'] ?? [];

    return list
        .map((e) => InOutManagementModel.fromJson(e))
        .toList();
  }
}

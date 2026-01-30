import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/oder_excelsheet_model.dart';

class OrderExcelSheetService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/ClassWiseBookSummary';

  static Future<OrderExcelSheetModel> fetchOrderExcelSheet(
      String billNo) async {
    final url = Uri.parse('$_baseUrl?billNo=$billNo');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return OrderExcelSheetModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load Order Excel Sheet');
    }
  }
}

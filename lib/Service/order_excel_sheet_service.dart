import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/order_excel_sheet_model.dart';

class OrderExcelSheetService {
  static const String _url =
      "https://g17bookworld.com/api/OrderExcelSheetList/GetOrderExcelSheetList";

  Future<List<OrderExcelSheet>> fetchOrderExcelSheetList() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List list = jsonData['Data'];

      return list
          .map((e) => OrderExcelSheet.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load Order Excel Sheet List");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/Oder_list_dispatch_model.dart';

class OrderListDispatchService {
  static Future<List<OrderListDispatchModel>> fetchOrders() async {
    final response = await http.get(
      Uri.parse(
        "https://g17bookworld.com/api/DispatchOrderList/GetDispatchOrderList",
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List dataList = jsonData['Data'];

      return dataList
          .map((e) => OrderListDispatchModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load dispatch orders");
    }
  }
}
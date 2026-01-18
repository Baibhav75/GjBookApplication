import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/order_list_model.dart';

class OrderListService {
  static const String _url =
      'https://g17bookworld.com/api/OrderList/GetOrderList';

  static Future<OrderListModel> fetchOrderList() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return OrderListModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load order list');
    }
  }
}

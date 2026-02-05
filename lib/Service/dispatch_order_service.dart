import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/dispatch_order_list_model.dart';


class DispatchOrderService {
  static const String _url =
      'https://g17bookworld.com/api/DispatchOrderList/GetDispatchOrderList';

  static Future<List<DispatchOrderListModel>> fetchDispatchOrders() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      final List list = decoded['Data'];

      return list
          .map((e) => DispatchOrderListModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load dispatch order list');
    }
  }
}

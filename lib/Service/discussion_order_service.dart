import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/discussion_order_list_model.dart';


class DiscussionOrderService {
  static const String apiUrl =
      "https://g17bookworld.com/API/DiscussionOrderlist/GetOrderList";

  Future<List<DiscussionOrderListModel>> fetchOrders() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['Status'] == "Success") {
        List list = data['Data'];

        return list
            .map((e) => DiscussionOrderListModel.fromJson(e))
            .toList();
      } else {
        throw Exception("API Error");
      }
    } else {
      throw Exception("Failed to load orders");
    }
  }
}

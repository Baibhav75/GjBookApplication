import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/order_dispatch_invoice_model.dart';

class OrderDispatchInvoiceService {

  static Future<OrderDispatchInvoiceModel> fetchInvoice(String senderId) async {

    final response = await http.get(
      Uri.parse(
        "https://g17bookworld.com/API/DispatchOrderInvoice/GetDispatchInvoice?id=$senderId",
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return OrderDispatchInvoiceModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load invoice");
    }
  }
}

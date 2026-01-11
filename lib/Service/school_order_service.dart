import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/school_order_model.dart';
class OrderFormService {
  final String baseUrl = 'https://g17bookworld.com/api';

  Future<OrderFormInvoice> getInvoiceByBillNo(String billNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/OrdersForm/InvoiceByBillNo?billNo=$billNo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return OrderFormInvoice.fromJson(data);
      } else {
        throw Exception('Failed to load invoice. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }

  Future<OrderFormInvoice> getInvoiceByBillNoWithToken(
      String billNo, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/OrdersForm/InvoiceByBillNo?billNo=$billNo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return OrderFormInvoice.fromJson(data);
      } else {
        throw Exception('Failed to load invoice. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }
}
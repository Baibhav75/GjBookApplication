// OrderFormService.dart - Add this method
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/school_order_model.dart';

class OrderFormService {
  final String baseUrl = 'https://g17bookworld.com/api';
  final http.Client client;

  OrderFormService({http.Client? client})
      : client = client ?? http.Client();

  Future<OrderFormInvoice> getInvoiceByBillNo(String billNo) async {
    try {
      final response = await client.get(
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

  // NEW: Method to fetch all invoices
  Future<List<OrderFormInvoice>> getAllInvoices({String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(
        Uri.parse('$baseUrl/OrdersForm/GetAllInvoices'), // Update with your actual endpoint
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderFormInvoice.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load invoices. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load invoices: $e');
    }
  }

  Future<OrderFormInvoice> getInvoiceByBillNoWithToken(
      String billNo, String token) async {
    try {
      final response = await client.get(
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
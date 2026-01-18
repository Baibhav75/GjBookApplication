import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/billno_invoice_model.dart';

class BillNoInvoiceService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/OrdersForm/InvoiceByBillNo';

  static Future<BillNoInvoiceModel> fetchInvoice(String billNo) async {
    final response =
    await http.get(Uri.parse('$_baseUrl?billNo=$billNo'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return BillNoInvoiceModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load invoice');
    }
  }
}

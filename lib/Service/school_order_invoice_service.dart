import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/school_order_invoice_model.dart';

class SchoolOrderInvoiceService {
  static Future<SchoolOrderInvoiceResponse> fetchInvoice({
    required String ownerMobile,
  }) async {
    final url =
    Uri.parse(
      "https://g17bookworld.com/api/OrderListSchoolWise/InvoiceBySchoolOwner"
          "?ownerMobile=$ownerMobile",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return SchoolOrderInvoiceResponse.fromJson(jsonData);
    } else {
      throw Exception("Failed to load invoice");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/order_agreement_model.dart';

class OrderAgreementService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/OrderAgreementList/GetOrderAgreementList';

  static Future<OrderAgreementResponse> fetchOrderAgreements() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      return OrderAgreementResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Order Agreement List');
    }
  }
}

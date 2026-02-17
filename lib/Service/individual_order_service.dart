import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/individual_order_model.dart';

class IndividualOrderService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/IndividualOrderlist/GetPublicationOrderList';

  Future<List<IndividualOrder>> fetchIndividualOrders() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded['Status'] == 'Success') {
        return IndividualOrder.listFromJson(decoded['Data']);
      } else {
        throw Exception(decoded['Message'] ?? 'Failed to fetch orders');
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}

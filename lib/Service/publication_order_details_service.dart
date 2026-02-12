import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Model/publication_order_details_model.dart';

class PublicationOrderDetailsService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/TrackPublicatonOrder/GetTrackingOrder';

  static Future<PublicationOrderDetailsResponse> fetchOrderDetails(
      String senderId) async {
    final url = '$_baseUrl?id=$senderId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return PublicationOrderDetailsResponse.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Failed to load publication order details');
    }
  }
}

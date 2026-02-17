import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/publication_order_details_model.dart';

class PublicationOrderDetailsService {

  static const String _baseUrl =
      'https://g17bookworld.com/api/TrackPublicatonOrder/GetTrackingOrder';

  static Future<PublicationOrderDetailsResponse> fetchOrderDetails(
      String senderId) async {

    final Uri url = Uri.parse("$_baseUrl?id=$senderId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);

        return PublicationOrderDetailsResponse.fromJson(decoded);

      } else {
        throw Exception(
            "Server Error ${response.statusCode} \n ${response.body}");
      }

    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }
}

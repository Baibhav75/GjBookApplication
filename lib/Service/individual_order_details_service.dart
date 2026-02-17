import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/individual_order_details_model.dart';

class IndividualOrderDetailsService {
  static const String baseUrl =
      "https://g17bookworld.com/api/IndividualorderDetails/GetOrderDetails";

  static Future<IndividualOrderDetailsResponse> fetchDetails(
      String senderId) async {
    final response =
    await http.get(Uri.parse("$baseUrl?SenderId=$senderId"));

    if (response.statusCode == 200) {
      return IndividualOrderDetailsResponse.fromJson(
          json.decode(response.body));
    } else {
      throw Exception("Failed to load order details");
    }
  }
}

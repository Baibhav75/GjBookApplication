import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/order_tracking_detail_model.dart';

class OrderTrackingDetailService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/TrackPublicatonOrder/GetTrackingOrder';

  static Future<OrderTrackingDetailResponse> fetchDetails(
      String senderId) async {
    final url = '$_baseUrl?id=$senderId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return OrderTrackingDetailResponse.fromJson(
          json.decode(response.body));
    } else {
      throw Exception("Failed to load tracking details");
    }
  }
}

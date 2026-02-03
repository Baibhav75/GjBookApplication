import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/tracking_order_model.dart';

class TrackingOrderService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/TrackingOrderList/GetTrackingOrderList';

  Future<List<TrackingOrder>> fetchTrackingOrders() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final trackingResponse =
      TrackingOrderResponse.fromJson(jsonData);
      return trackingResponse.data;
    } else {
      throw Exception('Failed to load tracking orders');
    }
  }
}

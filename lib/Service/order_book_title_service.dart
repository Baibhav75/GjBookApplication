import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/order_book_title_model.dart';

class OrderBookTitleService {
  static Future<OrderBookTitleModel> fetchTitles({
    required String ownerMobile,
    required String series,
  }) async {
    final url =
        'https://g17bookworld.com/api/OrderSubject/SubjectBySeries'
        '?ownerMobile=$ownerMobile&series=$series';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return OrderBookTitleModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load subjects');
    }
  }
}

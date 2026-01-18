import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/order_book_list_model.dart';

class OrderBookListService {
  static Future<OrderBookListModel> fetchBooks({
    required String ownerMobile,
    required String series,
    required String subject,
  }) async {
    final url =
        'https://g17bookworld.com/api/OrderBooks/BooksBySubject'
        '?ownerMobile=$ownerMobile&series=$series&subject=$subject';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return OrderBookListModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load books');
    }
  }
}

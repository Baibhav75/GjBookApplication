import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/book_order_series_model.dart';

class BookOrderSeriesService {
  static Future<BookOrderSeriesModel> fetchSeries({
    required String ownerMobile,
  }) async {
    final url =
        'https://g17bookworld.com/api/OrderSeries/SeriesBySchoolOwner?ownerMobile=$ownerMobile';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return BookOrderSeriesModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load series list');
    }
  }
}

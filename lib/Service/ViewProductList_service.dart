import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookworld/Model/ViewProductList_model.dart';

class ViewProductListService {
  static const String baseUrl = 'https://gj.realhomes.co.in/API/Product';

  Future<ViewProductListResponse> getProductList() async {
    final url = Uri.parse('$baseUrl/GetProductList');

    print('Fetching products from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        throw Exception(
          'Failed to fetch products. Status: ${response.statusCode}, Message: ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  ViewProductListResponse _parseResponse(String responseBody) {
    try {
      final Map<String, dynamic> responseData = json.decode(responseBody);
      return ViewProductListResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }
}
























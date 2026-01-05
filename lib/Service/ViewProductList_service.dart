import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/ViewProductList_model.dart';

class ViewProductListService {
  static const String apiUrl =
      'https://g17bookworld.com/API/Product/GetProductList';

  Future<ViewProductListResponse> getProductList() async {
    try {
      final response = await http
          .get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timeout after 15 seconds');
        },
      );

      if (response.statusCode == 200) {
        // Use compute for large JSON parsing if needed
        final decoded = json.decode(response.body) as Map<String, dynamic>;

        // Normalize response for your model
        final normalized = {
          'Status': decoded['Status'] ?? decoded['status'],
          'Message': decoded['Message'] ?? decoded['message'],
          'ProductList':
              decoded['ProductList'] ?? decoded['Data'] ?? decoded['data'],
        };

        final parsed = ViewProductListResponse.fromJson(normalized);
        return parsed;
      } else {
        throw Exception('Server error ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please check your internet connection.');
    } catch (e) {
      throw Exception('API Error: ${e.toString()}');
    }
  }
}

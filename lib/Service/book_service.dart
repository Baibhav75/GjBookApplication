// book_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../Model/viewbooklist_model.dart';


class BookService {
  static const String _baseUrl = 'https://g17bookworld.com/api';

  Future<BookSummaryResponse> getClassWiseBookSummary(String billNo) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ClassWiseBookSummary?billNo=$billNo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Log the response for debugging
        debugPrint('API Response: ${jsonData.toString()}');

        return BookSummaryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data. Status Code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching book summary: $e');
    }
  }
}
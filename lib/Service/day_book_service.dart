// services/day_book_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/day_book_model.dart';

class DayBookService {
  // Base URL
  static const String baseUrl = 'https://gj.realhomes.co.in/API/AddDayBook';

  final http.Client client;

  DayBookService({http.Client? client}) : client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // CREATE DAY BOOK ENTRY
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> createDayBook(DayBookModel dayBook) async {
    try {
      final url = '$baseUrl/AddLedgerKhata';

      print('🚀 POST: $url');
      print('📦 DATA: ${dayBook.toJson()}');

      final response = await client
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(dayBook.toJson()),
      )
          .timeout(const Duration(seconds: 30));

      print('📡 Status: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        return {
          'success': true,
          'message': json['message'] ?? 'Day book created successfully',
          'data': json,
        };
      }

      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create day book: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // GET DAY BOOK LIST (Used for Today / Week / Month / Date Filter)
  // ---------------------------------------------------------------------------
  Future<List<DayBookModel>> getDayBookList() async {
    try {
      final url = '$baseUrl/GetDayBookList';

      print('📥 GET: $url');

      final response = await client
          .get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 20));

      print('📡 Status: ${response.statusCode}');
      print('📄 Data: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Expected JSON structure:
        // { "success": true, "data": [ ... ] }

        if (jsonData['data'] == null || jsonData['data'] is! List) {
          return [];
        }

        final List<DayBookModel> items = (jsonData['data'] as List)
            .map((e) => DayBookModel.fromJson(e))
            .toList();

        return items;
      }

      throw Exception('Failed to fetch list: Status ${response.statusCode}');
    } catch (e) {
      print('❌ Error loading list: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // TEST CONNECTION
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await client
          .get(Uri.parse('https://gj.realhomes.co.in/'))
          .timeout(const Duration(seconds: 10));

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': response.statusCode == 200
            ? 'Connected to server successfully'
            : 'Server responded with status ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'message': 'Connection failed: $e',
      };
    }
  }

  // ---------------------------------------------------------------------------
  void dispose() {
    client.close();
  }
}

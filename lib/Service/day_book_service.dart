// services/day_book_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/day_book_model.dart';

class DayBookService {
  // Correct Base URL
  static const String baseUrl =
      'https://g17bookworld.com/API/AddDayBook';

  final http.Client client;

  DayBookService({http.Client? client})
      : client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // CREATE LEDGER KHATA (POST) - Updated to Multipart for Image Upload
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> createDayBook(DayBookModel dayBook) async {
    try {
      final url = 'https://g17bookworld.com/API/AddDayBook/AddLedgerKhata';
      
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // 🔹 TEXT FIELDS (Using exact keys from provided JSON response)
      request.fields['ParicularName'] = dayBook.particularName ?? '';
      request.fields['MobileNo'] = dayBook.mobileNo ?? '';
      request.fields['Flag'] = dayBook.type ?? '';
      request.fields['Amount'] = dayBook.amount?.toString() ?? '0';
      request.fields['ExpenceBowcherNo'] = dayBook.expenseVoucherNo ?? '';
      request.fields['ReceiptBowcherNo'] = dayBook.receiptVoucherNo ?? '';
      request.fields['Remarks'] = dayBook.remarks ?? '';
      // Optional/New fields
      if (dayBook.openingBalance != null) request.fields['OpeningBalance'] = dayBook.openingBalance.toString();
      if (dayBook.remark != null) request.fields['Remark'] = dayBook.remark!;

      // 🔹 IMAGE FILRE (ONLY IF PROVIDED)
      if (dayBook.image != null && dayBook.image!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Backend field name
            dayBook.image!,
          ),
        );
      }

      print("Sending fields: ${request.fields}");

      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return {
          'success': json['Status'] ?? false,
          'message': json['Message'] ?? 'Ledger saved successfully',
          'data': json['Data'] != null ? DayBookModel.fromJson(json['Data']) : null,
        };
      }

      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      print("Error creating day book: $e");
      return {
        'success': false,
        'message': 'Failed to create ledger entry: $e',
      };
    }
  }

  // ---------------------------------------------------------------------------
  // GET DAY BOOK LIST
  // ---------------------------------------------------------------------------
  Future<List<DayBookModel>> getDayBookList() async {
    try {
      final url =
          'https://g17bookworld.com/API/AddDayBook/GetDayBookList';

      final response = await client
          .get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final jsonData =
        jsonDecode(response.body);

        if (jsonData['Status'] == true &&
            jsonData['Data'] != null &&
            jsonData['Data'] is List) {
          return (jsonData['Data'] as List)
              .map((e) =>
              DayBookModel.fromJson(e))
              .toList();
        }

        return [];
      }

      return [];
    } catch (e) {
      print('❌ Error loading ledger list: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // TEST CONNECTION
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await client
          .get(
        Uri.parse(
            'https://g17bookworld.com/'),
      )
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

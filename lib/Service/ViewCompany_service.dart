import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/ViewCompany_model.dart';

class ViewCompanyService {
  static const String baseUrl = 'https://g17bookworld.com/API/Publication/GetPublication';
  static const int timeoutSeconds = 30;

  static Future<ViewCompanyModel?> getCompanies() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Log the response for debugging
        print('API Response: ${jsonResponse.containsKey('Status')}');
        print('Message: ${jsonResponse['Message']}');
        print('PublicationList length: ${jsonResponse['PublicationList']?.length ?? 0}');

        if (jsonResponse['PublicationList'] != null) {
          // Debug: Print first item to see actual structure
          if (jsonResponse['PublicationList'].isNotEmpty) {
            print('First item: ${jsonResponse['PublicationList'][0]}');
            print('Discount rate type: ${jsonResponse['PublicationList'][0]['discountRate']?.runtimeType}');
            print('Discount rate value: ${jsonResponse['PublicationList'][0]['discountRate']}');
          }
        }

        return ViewCompanyModel.fromJson(jsonResponse);
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}: Failed to load companies',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Network error: $e', 0);
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: $e', 0);
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
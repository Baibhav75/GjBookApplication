import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agent_invoice_detail_model.dart';

class AgentInvoiceService {
  static const String _baseUrl =
      "https://g17bookworld.com/api/AgentSaleReport";

  static String getApiUrl({
    required String agentId,
    required String billNo,
  }) {
    return "$_baseUrl/AgentInvoiceByBillNo?agentId=$agentId&billNo=$billNo";
  }

  static Future<AgentInvoiceDetailResponse> getInvoiceDetail({
    required String agentId,
    required String billNo,
  }) async {
    try {
      final url = getApiUrl(agentId: agentId, billNo: billNo);
      final uri = Uri.parse(url);

      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timeout. Please check your internet connection.");
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Validate response structure
        if (jsonData is! Map<String, dynamic>) {
          throw Exception("Invalid response format from server");
        }

        return AgentInvoiceDetailResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception("Invoice not found for the given Agent ID and Bill No");
      } else if (response.statusCode >= 500) {
        throw Exception("Server error. Please try again later.");
      } else {
        throw Exception(
          "Failed to load invoice detail. Status code: ${response.statusCode}",
        );
      }
    } on FormatException {
      throw Exception("Invalid response format from server");
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("An unexpected error occurred: $e");
    }
  }
}

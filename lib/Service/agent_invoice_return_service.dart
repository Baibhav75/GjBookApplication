import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agent_invoice_return_detail_model.dart';

class AgentInvoiceReturnService {
  static const String _baseUrl =
      'https://g17bookworld.com/api/AgentSaleReturnReport';

  static String getApiUrl({
    required String agentId,
    required String billNo,
  }) {
    return '$_baseUrl/AgentInvoiceByBillNo?agentId=$agentId&billNo=$billNo';
  }

  static Future<AgentInvoiceReturnDetailResponse> fetchInvoiceDetail({
    required String agentId,
    required String billNo,
  }) async {
    final url = Uri.parse(getApiUrl(agentId: agentId, billNo: billNo));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return AgentInvoiceReturnDetailResponse.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Failed to load invoice return detail');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/publication_ledger_model.dart';


class PublicationLedgerService {
  static const String _baseUrl =
      'https://g17bookworld.com/API/PublicationOrderLedger/GetPublicationOrderLedger';

  static Future<PublicationLedgerResponse> fetchLedger(
      String publicationId) async {
    final url = '$_baseUrl?publicationId=$publicationId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return PublicationLedgerResponse.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Failed to load publication ledger');
    }
  }
}

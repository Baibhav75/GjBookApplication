import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '/Model/order_letter_pad_model.dart';

class OrderLetterPadService {
  static const String _baseUrl =
      'https://g17bookworld.com/API/OrderLaterPadListApi/GetLaterPadList';

  /// Fetch list API
  Future<List<OrderLetterPad>> fetchLetterPadList() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final result = OrderLetterPadResponse.fromJson(decoded);
      return result.data;
    } else {
      throw Exception('Failed to load Order Letter Pad List');
    }
  }

  /// ✅ UNIVERSAL FILE OPENER (PDF / IMAGE / ANY FORMAT)
  Future<void> openFile(String url) async {
    if (url.isEmpty) {
      throw Exception('File URL is empty');
    }

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not open file');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Model/publication_order_management_model.dart';

class PublicationOrderManagementService {
  static const String _url =
      'https://g17bookworld.com/API/TotalPublicationOrder/GetAllPublicationOrder';

  static Future<PublicationOrderManagementResponse>
  fetchPublicationOrderList() async {

    final response = await http.get(Uri.parse(_url));

    print('STATUS CODE: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      return PublicationOrderManagementResponse.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('API failed');
    }
  }

}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookworld/Model/merge_order_details_model.dart';

class MergeOrderDetailsService {
  static Future<List<MergeOrderDetailsModel>> fetchDetails(String publicationId) async {
    final url =
        "https://g17bookworld.com/API/MergeOrderDetails/GetClubOrderDetails?publicationid=$publicationId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map((e) => MergeOrderDetailsModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load details");
    }
  }
}

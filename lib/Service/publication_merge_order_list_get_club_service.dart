import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../Model/publication_merge_order_list_get_club_model.dart';

class PublicationMergeOrderListGetClubService {

  static const String url =
      "https://g17bookworld.com/api/PublicationMergeOrderList/GetClubOrderList";

  static Future<List<PublicationMergeOrderListGetClubModel>>
  fetchClubOrders() async {

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return compute(parseOrders, response.body);
    } else {
      throw Exception("Failed to load data");
    }
  }
}

List<PublicationMergeOrderListGetClubModel> parseOrders(
    String responseBody) {
  final List<dynamic> jsonData = json.decode(responseBody);

  return jsonData
      .map((e) =>
      PublicationMergeOrderListGetClubModel.fromJson(e))
      .toList();
}

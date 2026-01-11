import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/sell_school_list_model.dart';

class SellSchoolListService {
  static const String _url =
      'https://g17bookworld.com/API/SchoolList/GetSchool';

  static Future<SellSchoolListResponse> fetchSchools() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      return SellSchoolListResponse.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Failed to load school list');
    }
  }
}

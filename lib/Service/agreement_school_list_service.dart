import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agreement_school_list_model.dart';

class AgreementSchoolListService {
  static const String apiUrl =
      "https://g17bookworld.com/API/AgreeMentSchoolList/GetAllSchools";

  Future<List<SchoolItem>> fetchSchools() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final model = AgreementSchoolListModel.fromJson(decoded);
      return model.data;
    } else {
      throw Exception("Failed to load schools");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/school_goto_view_model.dart';

class SchoolGotoViewService {
  static const String apiUrl =
      "https://g17bookworld.com/API/SchoolAgreeMentList/GetSchoolAgreementList";

  Future<List<AgreementItem>> fetchAgreements() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final model = SchoolAgreementListModel.fromJson(decoded);
      return model.data;
    } else {
      throw Exception("Failed to load agreement list");
    }
  }
}

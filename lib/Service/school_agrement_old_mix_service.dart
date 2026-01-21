import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/school_agrement_old_mix_model.dart';

class SchoolAgrementOldMixService {
  static const String _url =
      'https://g17bookworld.com/API/SchoolAgrementOldMixReport/GetSchoolAgrementOldMixReportList';

  Future<List<SchoolAgrementOldMix>> fetchList() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final result = SchoolAgrementOldMixResponse.fromJson(decoded);
      return result.data;
    } else {
      throw Exception('Failed to load School Agreement Old Mix Report');
    }
  }
}

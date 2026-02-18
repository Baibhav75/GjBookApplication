import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/SchoolAgreementFullDetailsModel.dart';

class SchoolAgreementFullDetailsService {

  static const String baseUrl =
      "https://g17bookworld.com/API/SchoolAgreeMentDetails/GetSchoolAgreement";

  Future<Data?> fetchAgreementDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl?id=$id"),
        headers: {
          "Accept": "application/json",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = SchoolAgreementFullDetailsModel.fromJson(jsonData);
        
        if (model.status == "success" || model.status == "1") {
          return model.data;
        } else {
          print("API Error: ${model.message}");
          return null;
        }
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("API Fetch Error: $e");
      return null;
    }
  }
}

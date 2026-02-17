import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/agreement_school_address_model.dart';

class AgreementSchoolAddressService {

  Future<AgreementSchoolAddressModel> fetchSchoolAddress(String schoolId) async {

    final url = Uri.parse(
        "https://g17bookworld.com/API/SchoolAddress/GetSchoolAddress?SchoolId=$schoolId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return AgreementSchoolAddressModel.fromJson(
          jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch school address");
    }
  }
}

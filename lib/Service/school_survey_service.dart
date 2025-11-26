import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '/Model/school_survey_model.dart';

class SchoolSurveyService {
  static const String baseUrl =
      "https://gj.realhomes.co.in/API/AddSchollSurvey/AddSchool";

  static Future<bool> submitSurvey(SchoolSurveyModel model) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(baseUrl));

      // Attach normal fields
      model.toJson().forEach((key, value) {
        request.fields[key] = value?.toString() ?? "";
      });

      // Attach image file if exists
      if (model.schoolPhotoPath != null &&
          File(model.schoolPhotoPath!).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "SchoolPhoto",
            model.schoolPhotoPath!,
            contentType: MediaType("image", "jpg"),
          ),
        );
      }

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      print("API Response: $responseString");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error submitting: $e");
      return false;
    }
  }
}

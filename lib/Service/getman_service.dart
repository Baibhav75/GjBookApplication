import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Model/getman_model.dart';

class GetManService {
  static const String _url =
      "https://g17bookworld.com/api/InOutStuff/Add";

  Future<GetManModel?> submitEntry({
    required String name,
    required String information,
    required String itemType,
    required String itemName,
    required String qty,
    required String rate,
    required double amount,
    required String remarks,
    File? imageFile, // 👈 optional image
  }) async {
    try {
      final request =
      http.MultipartRequest('POST', Uri.parse(_url));

      // 🔹 TEXT FIELDS (KEYS MUST MATCH BACKEND)
      request.fields['Name'] = name;
      request.fields['Information'] = information;
      request.fields['ItemType'] = itemType;
      request.fields['ItemName'] = itemName;
      request.fields['QTY'] = qty;
      request.fields['Rate'] = rate;
      request.fields['Amount'] = amount.toString();
      request.fields['Remarks'] = remarks;

      // 🔹 IMAGE (ONLY IF CAPTURED)
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Image', // 🔴 backend field name
            imageFile.path,
          ),
        );
      }

      // 🔍 DEBUG (VERY IMPORTANT)
      print("FIELDS SENT => ${request.fields}");
      print("FILES SENT => ${request.files.map((f) => f.field)}");

      final streamedResponse = await request.send();
      final responseBody =
      await streamedResponse.stream.bytesToString();

      print("STATUS CODE => ${streamedResponse.statusCode}");
      print("RESPONSE BODY => $responseBody");

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return GetManModel.fromJson(jsonDecode(responseBody));
      }
    } catch (e) {
      print("GetMan submit error: $e");
    }
    return null;
  }
}

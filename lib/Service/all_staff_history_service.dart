import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/AllStaffHistory_model.dart';

class AllStaffHistoryService {
  static const String _baseUrl =
      "https://g17bookworld.com/API/EmployeeAttendence/Attendance";

  static Future<List<AllStaffHistory>> getAllStaffHistory({
    required String mobile,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl?Mobile=$mobile");
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);

      if (decoded['status'] != 'success') {
        throw Exception(decoded['message'] ?? 'Failed to load attendance');
      }

      final List list = decoded['data'] ?? [];

      return list
          .map((e) => AllStaffHistory.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception("Unable to fetch staff attendance history");
    }
  }
}

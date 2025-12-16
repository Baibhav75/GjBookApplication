import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/attendance_history_model.dart';

class AttendanceService {
  static const String _url =
      'https://g17bookworld.com/API/AttendanceHistory/GetAttendancehistory';

  static Future<List<Attendance>> getAttendanceHistory(String mobileNo) async {
    final response = await http.get(
      Uri.parse("$_url?mobileNo=$mobileNo"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final parsed = AttendanceResponse.fromJson(data);
      return parsed.records;
    } else {
      throw Exception('Unable to load attendance data');
    }
  }

}

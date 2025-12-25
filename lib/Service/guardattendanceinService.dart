import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '/Model/guardAttendanceCheckin.dart';

class GuardAttendanceService {
  static const String _url =
      "https://g17bookworld.com/API/AttendenceManagement/MarkAttendance";

  Future<GuardCheckInModel> checkIn({
    required String employeeId,
    required String mobile,
    required String location,
    required File image,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_url));

      request.fields.addAll({
        "EmployeeId": employeeId,
        "EmpMobNo": mobile,
        "CheckInLocation": location,
        "Latitude": latitude.toString(),
        "Longitude": longitude.toString(),
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          "CheckInImage",
          image.path,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      final decoded = json.decode(responseBody);

      return GuardCheckInModel.fromJson(decoded);
    } catch (e) {
      return GuardCheckInModel(
        status: false,
        message: "Check-in failed: $e",
      );
    }
  }
}

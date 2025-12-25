import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../Model/hr_attendance_in_model.dart';

class HrAttendanceService {
  static const String _url =
      'https://g17bookworld.com/API/AttendenceManagement/MarkAttendance';

  static Future<HrAttendanceInResponse> markCheckIn({
    required String employeeId,
    required String mobile,
    required String employeeName,
    required Position position,
    required String address,
    required File image,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(_url));

    // ✅ EXACT backend fields only
    request.fields.addAll({
      'EmployeeId': employeeId,
      'EmpMobNo': mobile,
      'Type': 'CheckIn',
      'CheckInLocation': address,
    });

    // ✅ Image key exactly as backend expects
    request.files.add(
      await http.MultipartFile.fromPath(
        'CheckinImage',
        image.path,
      ),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    // ✅ Debug logs (keep in dev)
    print('STATUS CODE: ${streamedResponse.statusCode}');
    print('RESPONSE BODY: $responseBody');

    // ❌ Only throw on HTTP error
    if (streamedResponse.statusCode != 200) {
      throw Exception(
        'Server error (${streamedResponse.statusCode})',
      );
    }

    // ✅ Parse JSON safely
    final Map<String, dynamic> decoded =
    json.decode(responseBody) as Map<String, dynamic>;

    // ✅ Always return parsed response
    return HrAttendanceInResponse.fromJson(decoded);
  }
}

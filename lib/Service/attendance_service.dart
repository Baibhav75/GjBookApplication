import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Model/attendance_checkin_model.dart';

class AttendanceService {
  static const String apiUrl =
      "https://g17bookworld.com/API/AttendenceManagement/MarkAttendance";

  static Future<AttendanceCheckInModel?> markAttendance({
    required String employeeId,
    required String mobile,
    required String checkInTime,
    required String location,
    required File image,
    required String state,
  }) async {
    try {
      // 1. Strict Validation
      if (employeeId.trim().isEmpty) {
        print("API ERROR: Employee ID is missing");
        return AttendanceCheckInModel(
          status: false,
          message: "Employee ID is required",
          type: "validation_error",
        );
      }

      if (mobile.trim().isEmpty) {
        print("API ERROR: Mobile number is missing");
        return AttendanceCheckInModel(
          status: false,
          message: "Mobile number is required",
          type: "validation_error",
        );
      }

      if (checkInTime.trim().isEmpty) {
        print("API ERROR: Check-in time is missing");
        return AttendanceCheckInModel(
          status: false,
          message: "Check-in time is required",
          type: "validation_error",
        );
      }

      if (location.trim().isEmpty) {
        print("API ERROR: Location is missing");
        return AttendanceCheckInModel(
          status: false,
          message: "Location is required",
          type: "validation_error",
        );
      }

      if (state.trim().isEmpty) {
        print("API ERROR: State is missing");
        return AttendanceCheckInModel(
          status: false,
          message: "State is required",
          type: "validation_error",
        );
      }

      if (!image.existsSync()) {
        print("API ERROR: Image file does not exist at path: ${image.path}");
        return AttendanceCheckInModel(
          status: false,
          message: "Image file is missing or invalid",
          type: "validation_error",
        );
      }

      // 2. Prepare Request
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));

      // 3. Add Fields (Exact case-sensitive names required by backend)
      request.fields['EmployeeId'] = employeeId.trim();
      request.fields['EmpMobNo'] = mobile.trim();
      request.fields['CheckInTime'] = checkInTime.trim();
      request.fields['CheckInLocation'] = location.trim();
      request.fields['State'] = state.trim();

      // 4. Add File (Exact name 'CheckinImage')
      request.files.add(await http.MultipartFile.fromPath(
        "CheckinImage",
        image.path,
      ));

      // 5. Debug Logging
      print("🚀 SENDING ATTENDANCE CHECK-IN REQUEST");
      print("   URL: $apiUrl");
      print("   EmployeeId:      '${request.fields['EmployeeId']}'");
      print("   EmpMobNo:        '${request.fields['EmpMobNo']}'");
      print("   CheckInTime:     '${request.fields['CheckInTime']}'");
      print("   CheckInLocation: '${request.fields['CheckInLocation']}'");
      print("   State:           '${request.fields['State']}'");
      print("   CheckinImage:    '${image.path}' (Size: ${await image.length()} bytes)");


      // 6. Send Request
      var response = await request.send();
      var body = await response.stream.bytesToString();

      print("📥 ATTENDANCE RESPONSE");
      print("   Status Code: ${response.statusCode}");
      print("   Body: $body");

      // 7. Handle Responses
      if (body.isEmpty) {
         return AttendanceCheckInModel(
          status: false,
          message: "Server returned empty response",
          type: "server_error",
        );
      }

      if (response.statusCode != 200) {
        return AttendanceCheckInModel(
          status: false,
          message: "Server error: ${response.statusCode}",
          type: "http_error",
        );
      }

      // 8. Parse JSON
      try {
        final jsonRes = jsonDecode(body);
        if (jsonRes is Map<String, dynamic>) {
           return AttendanceCheckInModel.fromJson(jsonRes);
        } else {
           print("API ERROR: JSON is not a Map");
           return AttendanceCheckInModel(
            status: false,
            message: "Invalid server response format",
            type: "parse_error",
          );
        }
      } catch (e) {
        print("API ERROR: JSON Parse failed: $e");
         return AttendanceCheckInModel(
          status: false,
          message: "Failed to parse server response",
          type: "parse_error",
        );
      }
    } catch (e) {
      print("API EXCEPTION: $e");
      return AttendanceCheckInModel(
        status: false,
        message: "An unexpected error occurred: $e",
        type: "exception",
      );
    }
  }
}

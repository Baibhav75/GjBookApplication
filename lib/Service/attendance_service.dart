import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Model/attendance_checkin_model.dart';

class AttendanceService {
  static const String apiUrl =
      "https://gj.realhomes.co.in/API/AttendenceManagement/MarkAttendance";

  static Future<AttendanceCheckInModel?> markAttendance({
    required String employeeId,
    required String mobile,
    required String checkInTime,
    required String location,
    required double latitude,
    required double longitude,
    required File image,
  }) async {
    try {
      // Validate inputs before sending
      if (employeeId.trim().isEmpty) {
        print("API ERROR: EmployeeId is empty");
        return AttendanceCheckInModel(
          status: false,
          message: "Employee ID is required",
          type: "error",
        );
      }

      if (mobile.trim().isEmpty) {
        print("API ERROR: Mobile number is empty");
        return AttendanceCheckInModel(
          status: false,
          message: "Mobile number is required",
          type: "error",
        );
      }

      if (location.trim().isEmpty) {
        print("API ERROR: Location is empty");
        return AttendanceCheckInModel(
          status: false,
          message: "Location is required",
          type: "error",
        );
      }

      if (!image.existsSync()) {
        print("API ERROR: Image file does not exist");
        return AttendanceCheckInModel(
          status: false,
          message: "Image file is missing",
          type: "error",
        );
      }

      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));

      // Ensure all fields are trimmed and non-empty
      request.fields['EmployeeId'] = employeeId.trim();
      request.fields['EmpMobNo'] = mobile.trim();
      request.fields['CheckInTime'] = checkInTime.trim();
      request.fields['CheckInLocation'] = location.trim();
      request.fields['Latitude'] = latitude.toString();
      request.fields['Longitude'] = longitude.toString();
      request.fields['Type'] = "CheckIn";

      request.files.add(await http.MultipartFile.fromPath(
        "CheckinImage",
        image.path,
      ));

      // Debug logging
      print("Sending attendance check-in request:");
      print("EmployeeId: ${request.fields['EmployeeId']}");
      print("EmpMobNo: ${request.fields['EmpMobNo']}");
      print("CheckInTime: ${request.fields['CheckInTime']}");
      print("CheckInLocation: ${request.fields['CheckInLocation']}");
      print("Latitude: ${request.fields['Latitude']}");
      print("Longitude: ${request.fields['Longitude']}");
      print("Type: ${request.fields['Type']}");
      print("Image path: ${image.path}");
      print("Image exists: ${image.existsSync()}");

      var response = await request.send();
      var body = await response.stream.bytesToString();

      // Log response for debugging
      print("API Response Status: ${response.statusCode}");
      print("API Response Body: $body");

      // Validate response body
      if (body.isEmpty || body.trim().isEmpty) {
        print("API ERROR: Empty response body");
        return AttendanceCheckInModel(
          status: false,
          message: "Empty response from server",
          type: "error",
        );
      }

      // Check if response contains error message directly
      if (body.toLowerCase().contains("object reference not set") ||
          body.toLowerCase().contains("null reference")) {
        print("API ERROR: Server returned null reference error");
        return AttendanceCheckInModel(
          status: false,
          message: "Server error: Required information is missing. Please check all fields.",
          type: "error",
        );
      }

      // Check HTTP status code
      if (response.statusCode != 200) {
        print("API ERROR: HTTP ${response.statusCode} - $body");
        return AttendanceCheckInModel(
          status: false,
          message: "Server error: ${response.statusCode}",
          type: "error",
        );
      }

      // Parse JSON with validation
      dynamic jsonRes;
      try {
        jsonRes = jsonDecode(body);
      } catch (jsonError) {
        print("API ERROR: Invalid JSON - $jsonError");
        print("Response body: $body");
        return AttendanceCheckInModel(
          status: false,
          message: "Invalid response format",
          type: "error",
        );
      }

      // Validate that jsonRes is a Map
      if (jsonRes is! Map<String, dynamic>) {
        print("API ERROR: Response is not a Map - ${jsonRes.runtimeType}");
        print("Response body: $body");
        return AttendanceCheckInModel(
          status: false,
          message: "Invalid response structure",
          type: "error",
        );
      }

      return AttendanceCheckInModel.fromJson(jsonRes);
    } catch (e) {
      print("API ERROR: $e");
      return AttendanceCheckInModel(
        status: false,
        message: "Something went wrong: ${e.toString()}",
        type: "error",
      );
    }
  }
}

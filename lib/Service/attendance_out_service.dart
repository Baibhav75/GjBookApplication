import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '/Model/ AttendanceCheckOutModel.dart';

class AttendanceOutService {
  static const String baseUrl =
      "https://gj.realhomes.co.in/API/AttendenceManagement/MarkAttendance";

  Future<AttendanceCheckOutModel?> submitAttendance({
    required String employeeId,
    required String mobile,
    required String type, // CheckOut
    required String? address,
    required DateTime timestamp,
    File? imageFile,
    double? lat,
    double? lng,
  }) async {
    try {
      // Validate inputs before sending
      if (employeeId.trim().isEmpty) {
        print("API ERROR: EmployeeId is empty for checkout");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Employee ID is required",
        );
      }

      if (mobile.trim().isEmpty) {
        print("API ERROR: Mobile number is empty for checkout");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Mobile number is required",
        );
      }

      if (address == null || address.trim().isEmpty) {
        print("API ERROR: Address is empty for checkout");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Location is required",
        );
      }

      if (imageFile != null && !imageFile.existsSync()) {
        print("API ERROR: Image file does not exist");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Image file is missing",
        );
      }

      var request = http.MultipartRequest("POST", Uri.parse(baseUrl));

      // Use same field structure as check-in API
      request.fields['EmployeeId'] = employeeId.trim();
      request.fields['EmpMobNo'] = mobile.trim();
      request.fields['CheckOutTime'] = timestamp.toIso8601String();
      request.fields['CheckOutLocation'] = address.trim();
      request.fields['Latitude'] = lat?.toString() ?? "";
      request.fields['Longitude'] = lng?.toString() ?? "";
      request.fields['Type'] = type; // "CheckOut"

      if (imageFile != null && imageFile.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath(
          'CheckoutImage',
          imageFile.path,
        ));
      }

      // Debug logging
      print("Sending attendance checkout request:");
      print("EmployeeId: ${request.fields['EmployeeId']}");
      print("EmpMobNo: ${request.fields['EmpMobNo']}");
      print("CheckOutTime: ${request.fields['CheckOutTime']}");
      print("CheckOutLocation: ${request.fields['CheckOutLocation']}");
      print("Latitude: ${request.fields['Latitude']}");
      print("Longitude: ${request.fields['Longitude']}");
      print("Type: ${request.fields['Type']}");
      if (imageFile != null) {
        print("Image path: ${imageFile.path}");
        print("Image exists: ${imageFile.existsSync()}");
      }

      var response = await request.send();
      var body = await response.stream.bytesToString();

      // Log response for debugging
      print("API Response Status: ${response.statusCode}");
      print("API Response Body: $body");

      // Validate response body
      if (body.isEmpty || body.trim().isEmpty) {
        print("API ERROR: Empty response body");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Empty response from server",
        );
      }

      // Check if response contains error message directly
      if (body.toLowerCase().contains("object reference not set") ||
          body.toLowerCase().contains("null reference")) {
        print("API ERROR: Server returned null reference error");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Server error: Required information is missing.",
        );
      }

      // Check HTTP status code
      if (response.statusCode != 200) {
        print("API ERROR: HTTP ${response.statusCode} - $body");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Server error: ${response.statusCode}",
        );
      }

      // Parse JSON with validation
      dynamic jsonRes;
      try {
        jsonRes = jsonDecode(body);
      } catch (jsonError) {
        print("API ERROR: Invalid JSON - $jsonError");
        print("Response body: $body");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Invalid response format",
        );
      }

      // Validate that jsonRes is a Map
      if (jsonRes is! Map<String, dynamic>) {
        print("API ERROR: Response is not a Map - ${jsonRes.runtimeType}");
        print("Response body: $body");
        return AttendanceCheckOutModel(
          status: false,
          type: "error",
          message: "Invalid response structure",
        );
      }

      return AttendanceCheckOutModel.fromJson(jsonRes);
    } catch (e) {
      print("API ERROR: $e");
      return AttendanceCheckOutModel(
        status: false,
        type: "error",
        message: "Something went wrong: ${e.toString()}",
      );
    }
  }
}

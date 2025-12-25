import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '/Model/ItAttendanceModel.dart';

class ItattendanceinService {
  static const String apiUrl =
      "https://g17bookworld.com/API/AttendenceManagement/MarkAttendance";

  static Future<AttendanceCheckInModel?> markAttendance({
    required String employeeId,
    required String mobile,
    required String checkInTime,
    required String location,
    required double latitude,
    required double longitude,
    required String? state,
    required File image,
  }) async {
    try {
      // Enhanced input validation
      final errors = <String>[];

      if (employeeId.trim().isEmpty) errors.add("Employee ID");
      if (mobile.trim().isEmpty) errors.add("Mobile number");
      if (location.trim().isEmpty) errors.add("Location");
      if (!image.existsSync()) errors.add("Image file");

      if (errors.isNotEmpty) {
        print("API VALIDATION ERROR: Missing fields: ${errors.join(', ')}");
        return AttendanceCheckInModel(
          status: false,
          message: "Missing required fields: ${errors.join(', ')}",
          type: "validation_error",
          error: "Missing fields: ${errors.join(', ')}",
        );
      }

      // Validate coordinates
      if (latitude.isNaN || longitude.isNaN || latitude.isInfinite || longitude.isInfinite) {
        print("API VALIDATION ERROR: Invalid coordinates");
        return AttendanceCheckInModel(
          status: false,
          message: "Invalid GPS coordinates",
          type: "validation_error",
          error: "Invalid coordinates",
        );
      }

      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));

      // Set all required fields with validation
      request.fields['EmployeeId'] = employeeId.trim();
      request.fields['EmpMobNo'] = mobile.trim();
      request.fields['CheckInTime'] = checkInTime.trim();
      request.fields['CheckInLocation'] = location.trim();
      request.fields['Latitude'] = latitude.toString();
      request.fields['Longitude'] = longitude.toString();
      request.fields['Type'] = "CheckIn";

      // Handle state field properly - never send empty string
      final stateValue = (state != null && state.trim().isNotEmpty) ? state.trim() : 'Not Available';
      request.fields['State'] = stateValue;

      // Add image file with proper content type
      final imageFile = await http.MultipartFile.fromPath(
        "CheckinImage",
        image.path,
        filename: 'checkin_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(imageFile);

      // Add headers for better compatibility
      request.headers['Accept'] = 'application/json';
      request.headers['Connection'] = 'keep-alive';

      // Enhanced debug logging
      print("📤 Sending Attendance Check-In Request:");
      print("├─ EmployeeId: ${employeeId.trim()}");
      print("├─ EmpMobNo: ${mobile.trim()}");
      print("├─ CheckInTime: ${checkInTime.trim()}");
      print("├─ CheckInLocation: ${location.trim()}");
      print("├─ Latitude: $latitude");
      print("├─ Longitude: $longitude");
      print("├─ State: $stateValue");
      print("├─ Type: CheckIn");
      print("└─ Image: ${image.path} (${image.lengthSync()} bytes)");
      print("Full Request Fields: ${request.fields}");

      // Send request with timeout
      final response = await request.send().timeout(const Duration(seconds: 30));
      final body = await response.stream.bytesToString();

      // Enhanced response logging
      print("📥 API Response Received:");
      print("├─ Status Code: ${response.statusCode}");
      print("├─ Response Length: ${body.length} bytes");
      print("└─ Body Preview: ${body.length > 200 ? '${body.substring(0, 200)}...' : body}");

      // Handle empty response
      if (body.isEmpty || body.trim().isEmpty) {
        print("❌ API ERROR: Empty response body");
        return AttendanceCheckInModel(
          status: false,
          message: "Server returned empty response",
          type: "server_error",
          error: "Empty response",
        );
      }

      // Check for common server errors in response text
      final lowerBody = body.toLowerCase();
      if (lowerBody.contains("object reference not set") ||
          lowerBody.contains("null reference") ||
          lowerBody.contains("exception") ||
          lowerBody.contains("error")) {
        print("❌ API ERROR: Server returned error in response");

        // Try to extract error message
        String? errorMessage;
        if (body.contains('"message"')) {
          try {
            final json = jsonDecode(body);
            errorMessage = json['message']?.toString();
          } catch (_) {}
        }

        return AttendanceCheckInModel(
          status: false,
          message: errorMessage ?? "Server error detected in response",
          type: "server_error",
          error: body,
        );
      }

      // Check HTTP status code
      if (response.statusCode != 200) {
        print("❌ API ERROR: HTTP ${response.statusCode}");

        // Try to parse error from response
        String? errorDetail;
        try {
          final errorJson = jsonDecode(body);
          errorDetail = errorJson['message']?.toString() ??
              errorJson['error']?.toString() ??
              errorJson['Message']?.toString() ??
              errorJson['Error']?.toString();
        } catch (_) {
          errorDetail = body.length > 100 ? '${body.substring(0, 100)}...' : body;
        }

        return AttendanceCheckInModel(
          status: false,
          message: "Server returned status ${response.statusCode}: ${errorDetail ?? 'Unknown error'}",
          type: "http_error",
          error: "HTTP ${response.statusCode}: $errorDetail",
        );
      }

      // Parse JSON response
      dynamic jsonRes;
      try {
        jsonRes = jsonDecode(body);
      } catch (jsonError) {
        print("❌ JSON PARSE ERROR: $jsonError");
        print("Raw response: $body");

        // Check if it's HTML error page
        if (body.contains('<!DOCTYPE') || body.contains('<html')) {
          return AttendanceCheckInModel(
            status: false,
            message: "Server returned HTML instead of JSON. Please check API endpoint.",
            type: "parse_error",
            error: "HTML response received",
          );
        }

        return AttendanceCheckInModel(
          status: false,
          message: "Invalid response format from server",
          type: "parse_error",
          error: jsonError.toString(),
        );
      }

      // Ensure response is a Map
      if (jsonRes is! Map<String, dynamic>) {
        print("❌ RESPONSE TYPE ERROR: Expected Map, got ${jsonRes.runtimeType}");
        print("Response value: $jsonRes");

        return AttendanceCheckInModel(
          status: false,
          message: "Unexpected response format",
          type: "format_error",
          error: "Response type: ${jsonRes.runtimeType}",
        );
      }

      // Parse and return the model
      final result = AttendanceCheckInModel.fromJson(jsonRes);

      // Log success/error
      if (result.status) {
        print("✅ Check-In Successful!");
        print("   Message: ${result.message}");
        print("   CheckInTime: ${result.checkInTime}");
        print("   WorkDuration: ${result.workDuration}");
      } else {
        print("❌ Check-In Failed!");
        print("   Message: ${result.message}");
        print("   Type: ${result.type}");
        print("   Error: ${result.error}");
      }

      return result;
    } catch (e) {
      print("❌ UNEXPECTED ERROR: $e");

      // Handle specific error types
      String errorType = "unknown_error";
      String errorMessage = "Something went wrong";

      if (e is SocketException) {
        errorType = "network_error";
        errorMessage = "Network connection failed. Please check your internet.";
      } else if (e is HttpException) {
        errorType = "http_exception";
        errorMessage = "HTTP request failed: $e";
      } else if (e is FormatException) {
        errorType = "format_exception";
        errorMessage = "Data format error: $e";
      } else if (e is TimeoutException) {
        errorType = "timeout_error";
        errorMessage = "Request timed out. Please try again.";
      }

      return AttendanceCheckInModel(
        status: false,
        message: errorMessage,
        type: errorType,
        error: e.toString(),
      );
    }
  }
}
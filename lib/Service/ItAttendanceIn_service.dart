import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '/Model/ItAttendanceModel.dart';

class ItattendanceinService {
  static const String apiUrl =
      "https://g17bookworld.com/API/AttendenceManagement/MarkAttendance";

  /// DEBUG MODE: This will print EVERYTHING for debugging
  static Future<ItAttendanceCheckInModel?> markAttendance({
    required String employeeId,
    required String mobile,
    required String checkInTime,
    required String location,
    required double latitude,
    required double longitude,
    required String? state,
    required File image,
    String? employeeName,
  }) async {
    print("🚨🚨🚨 DEBUG CHECK-IN STARTED 🚨🚨🚨");

    try {
      // 1. Validate ALL inputs with detailed logging
      print("\n=== STEP 1: INPUT VALIDATION ===");
      print("📋 Received Parameters:");
      print("  • employeeId: '$employeeId' (length: ${employeeId.length})");
      print("  • mobile: '$mobile' (length: ${mobile.length})");
      print("  • checkInTime: '$checkInTime' (ISO format: ${checkInTime.contains('T')})");
      print("  • location: '$location' (length: ${location.length})");
      print("  • latitude: $latitude");
      print("  • longitude: $longitude");
      print("  • state: '$state' (is null: ${state == null}, is empty: ${state?.isEmpty ?? true})");
      print("  • image path: '${image.path}'");
      print("  • image exists: ${image.existsSync()}");

      if (image.existsSync()) {
        print("  • image size: ${image.lengthSync()} bytes");
      }

      final errors = <String>[];

      if (employeeId.trim().isEmpty) {
        errors.add("Employee ID");
        print("❌ Employee ID is EMPTY!");
      } else if (employeeId.trim().length < 2) {
        errors.add("Employee ID too short");
        print("❌ Employee ID too short: '${employeeId.trim()}'");
      }

      if (mobile.trim().isEmpty) {
        errors.add("Mobile number");
        print("❌ Mobile number is EMPTY!");
      } else if (mobile.trim().length < 10) {
        errors.add("Mobile number invalid");
        print("❌ Mobile number too short: '${mobile.trim()}'");
      }

      if (location.trim().isEmpty) {
        errors.add("Location");
        print("❌ Location is EMPTY!");
      }

      if (!image.existsSync()) {
        errors.add("Image file not found");
        print("❌ Image file NOT FOUND at: ${image.path}");
      } else if (image.lengthSync() == 0) {
        errors.add("Image file is empty");
        print("❌ Image file is EMPTY (0 bytes)");
      }

      if (errors.isNotEmpty) {
        print("\n❌❌❌ VALIDATION FAILED: ${errors.join(', ')}");
        return ItAttendanceCheckInModel(
          status: false,
          message: "Validation failed: ${errors.join(', ')}",
          type: "validation_error",
        );
      }

      print("✅ All inputs validated successfully");

      // 2. Prepare the request
      print("\n=== STEP 2: PREPARING REQUEST ===");

      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));

      // Prepare state value - CRITICAL
      String stateValue;
      if (state != null && state.trim().isNotEmpty) {
        stateValue = state.trim();
        print("✅ Using provided state: '$stateValue'");
      } else {
        stateValue = 'Maharashtra'; // Default state based on common usage
        print("⚠️ State not provided, using default: '$stateValue'");
      }

      // Ensure state is not empty
      if (stateValue.isEmpty) {
        stateValue = 'Maharashtra';
        print("⚠️ State was empty, set to: '$stateValue'");
      }

      // Set ALL fields that backend might expect
      print("\n📝 Setting request fields:");

      // Required fields (using multiple naming conventions to ensure backend compatibility)
      request.fields['EmployeeId'] = employeeId.trim();
      print("  • EmployeeId: '${employeeId.trim()}'");
      
      // Also send as 'EmpId' for potential backend compatibility
      request.fields['EmpId'] = employeeId.trim();
      print("  • EmpId: '${employeeId.trim()}'");

      request.fields['EmpMobNo'] = mobile.trim();
      print("  • EmpMobNo: '${mobile.trim()}'");
      
      // Also send as 'Mobile' for potential backend compatibility
      request.fields['Mobile'] = mobile.trim();
      print("  • Mobile: '${mobile.trim()}'");

      request.fields['CheckInTime'] = checkInTime.trim();
      print("  • CheckInTime: '${checkInTime.trim()}'");
      
      // Also send as 'CheckinTime' for potential backend compatibility
      request.fields['CheckinTime'] = checkInTime.trim();
      print("  • CheckinTime: '${checkInTime.trim()}'");

      request.fields['CheckInLocation'] = location.trim();
      print("  • CheckInLocation: '${location.trim()}'");
      
      // Also send as 'Location' for potential backend compatibility
      request.fields['Location'] = location.trim();
      print("  • Location: '${location.trim()}'");

      request.fields['Latitude'] = latitude.toString();
      print("  • Latitude: '${latitude.toString()}'");

      request.fields['Longitude'] = longitude.toString();
      print("  • Longitude: '${longitude.toString()}'");

      request.fields['Type'] = "CheckIn";
      print("  • Type: 'CheckIn'");

      request.fields['State'] = stateValue;
      print("  • State: '$stateValue'");

      // Try additional fields that backend might need
      request.fields['CheckinImage'] = ''; // Placeholder, actual file added separately
      print("  • CheckinImage: '[FILE WILL BE ATTACHED]'");

      // Optional fields that might help
      request.fields['DeviceType'] = 'Mobile';
      print("  • DeviceType: 'Mobile'");

      request.fields['AppVersion'] = '1.0.0';
      print("  • AppVersion: '1.0.0'");
      
      // Additional fields that backend might require based on error logs
      // Add employee name if available
      String nameToSend = employeeName?.isNotEmpty == true ? employeeName! : 'Employee';
      request.fields['EmployeeName'] = nameToSend;
      print("  • EmployeeName: '$nameToSend'");
      
      request.fields['EmpName'] = nameToSend;
      print("  • EmpName: '$nameToSend'");
      
      // Add other potential fields
      request.fields['Email'] = '${employeeId.trim()}@company.com'; // Create email from employee ID
      print("  • Email: '${employeeId.trim()}@company.com'");
      
      request.fields['Department'] = 'General';
      print("  • Department: 'General'");
      
      request.fields['Designation'] = 'Staff';
      print("  • Designation: 'Staff'");

      // 3. Add image file
      print("\n=== STEP 3: ADDING IMAGE FILE ===");
      try {
        final imageFile = await http.MultipartFile.fromPath(
          "CheckinImage", // Try different field names
          image.path,
          filename: 'checkin_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(imageFile);
        print("✅ Image file added successfully");
        print("  • Field name: 'CheckinImage'");
        print("  • File path: '${image.path}'");
        print("  • File size: ${image.lengthSync()} bytes");
      } catch (e) {
        print("❌ Failed to add image file: $e");
        return ItAttendanceCheckInModel(
          status: false,
          message: "Failed to prepare image: $e",
          type: "image_error",
        );
      }

      // 4. Add headers
      print("\n=== STEP 4: ADDING HEADERS ===");
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['User-Agent'] = 'Flutter-App/1.0';
      print("✅ Headers added");

      // 5. Log complete request
      print("\n=== STEP 5: COMPLETE REQUEST DETAILS ===");
      print("🌐 API URL: $apiUrl");
      print("📦 Total fields: ${request.fields.length}");
      print("📦 Total files: ${request.files.length}");
      print("\n🔍 ALL FIELDS BEING SENT:");
      request.fields.forEach((key, value) {
        print("  '$key': '${value.isEmpty ? '[EMPTY STRING]' : value}'");
      });

      print("\n🔍 ALL FILES BEING SENT:");
      for (var file in request.files) {
        print("  Field: '${file.field}', Filename: '${file.filename}'");
      }

      // 6. Send request
      print("\n=== STEP 6: SENDING REQUEST ===");
      print("⏳ Sending to server...");

      final stopwatch = Stopwatch()..start();
      final response = await request.send().timeout(const Duration(seconds: 45));
      stopwatch.stop();

      print("✅ Request completed in ${stopwatch.elapsedMilliseconds}ms");
      print("📡 Response status: ${response.statusCode}");

      // 7. Read response
      print("\n=== STEP 7: READING RESPONSE ===");
      final body = await response.stream.bytesToString();
      print("📄 Response body length: ${body.length} characters");

      if (body.length > 500) {
        print("📄 First 500 chars: ${body.substring(0, 500)}");
      } else {
        print("📄 Full response: $body");
      }

      // 8. Check for common errors
      print("\n=== STEP 8: ERROR CHECKING ===");

      if (body.isEmpty) {
        print("❌ EMPTY RESPONSE BODY");
        return ItAttendanceCheckInModel(
          status: false,
          message: "Server returned empty response",
          type: "empty_response",
        );
      }

      // Check for specific error messages
      if (body.toLowerCase().contains("required information") ||
          body.toLowerCase().contains("information missing") ||
          body.toLowerCase().contains("object reference") ||
          body.toLowerCase().contains("null reference")) {

        print("❌ SERVER ERROR DETECTED: 'Required information missing'");
        print("💡 This means backend is expecting a field that we're not sending");
        print("💡 Possible missing fields:");
        print("   - EmployeeName (maybe backend expects name)");
        print("   - EmpName");
        print("   - Email");
        print("   - Department");
        print("   - Designation");

        // Try to extract specific error
        String errorMessage = "Required information is missing on server";
        if (body.contains('"message"')) {
          try {
            final json = jsonDecode(body);
            errorMessage = json['message']?.toString() ?? errorMessage;
          } catch (_) {}
        }

        return ItAttendanceCheckInModel(
          status: false,
          message: errorMessage,
          type: "server_validation_error",
          error: body.length > 200 ? '${body.substring(0, 200)}...' : body,
        );
      }

      // Check if it's HTML/error page
      if (body.contains('<!DOCTYPE') ||
          body.contains('<html') ||
          body.contains('Error') ||
          body.contains('Exception')) {
        print("❌ HTML/ERROR PAGE RECEIVED");

        // Extract error from HTML if possible
        String? extractedError;
        final errorPatterns = [
          RegExp(r'Exception[^<]*'),
          RegExp(r'Error[^<]*'),
          RegExp(r'Message[^<]*'),
        ];

        for (var pattern in errorPatterns) {
          final match = pattern.firstMatch(body);
          if (match != null) {
            extractedError = match.group(0);
            break;
          }
        }

        return ItAttendanceCheckInModel(
          status: false,
          message: extractedError ?? "Server returned error page",
          type: "html_error",
          error: body.length > 300 ? '${body.substring(0, 300)}...' : body,
        );
      }

      // 9. Parse JSON response
      print("\n=== STEP 9: PARSING RESPONSE ===");

      dynamic jsonRes;
      try {
        jsonRes = jsonDecode(body);
        print("✅ JSON parsed successfully");
      } catch (e) {
        print("❌ JSON PARSE ERROR: $e");
        print("💡 Response might be in different format");

        // Try to extract JSON-like content
        final jsonMatch = RegExp(r'\{.*\}').firstMatch(body);
        if (jsonMatch != null) {
          try {
            final jsonStr = jsonMatch.group(0)!;
            jsonRes = jsonDecode(jsonStr);
            print("✅ Extracted and parsed JSON from response");
          } catch (_) {
            return ItAttendanceCheckInModel(
              status: false,
              message: "Invalid response format from server",
              type: "parse_error",
              error: "JSON parse failed: $e\nResponse: ${body.length > 100 ? '${body.substring(0, 100)}...' : body}",
            );
          }
        } else {
          return ItAttendanceCheckInModel(
            status: false,
            message: "Invalid server response format",
            type: "format_error",
            error: body.length > 100 ? '${body.substring(0, 100)}...' : body,
          );
        }
      }

      // 10. Create response model
      print("\n=== STEP 10: CREATING RESPONSE MODEL ===");

      if (jsonRes is! Map<String, dynamic>) {
        print("❌ Response is not a Map, it's: ${jsonRes.runtimeType}");
        return ItAttendanceCheckInModel(
          status: false,
          message: "Unexpected response structure",
          type: "structure_error",
        );
      }

      final result = ItAttendanceCheckInModel.fromJson(jsonRes);

      print("\n🎯 FINAL RESULT:");
      print("  Status: ${result.status ? '✅ SUCCESS' : '❌ FAILED'}");
      print("  Message: ${result.message}");
      print("  Type: ${result.type}");

      if (result.status) {
        print("\n🎉 CHECK-IN SUCCESSFUL!");
        if (result.checkInTime != null) {
          print("  Check-in Time: ${result.checkInTime}");
        }
        if (result.workDuration != null) {
          print("  Work Duration: ${result.workDuration}");
        }
      } else {
        print("\n😞 CHECK-IN FAILED");
        if (result.error != null) {
          print("  Error: ${result.error}");
        }
      }

      return result;

    } catch (e, stackTrace) {
      print("\n❌❌❌ UNEXPECTED ERROR ❌❌❌");
      print("Error: $e");
      print("Stack Trace: $stackTrace");

      return ItAttendanceCheckInModel(
        status: false,
        message: "Unexpected error: ${e.toString()}",
        type: "unexpected_error",
        error: "$e\n$stackTrace",
      );
    } finally {
      print("\n🚨🚨🚨 DEBUG CHECK-IN ENDED 🚨🚨🚨");
    }
  }
}
// guardattendanceoutService.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '/Model/guardAttendanceOutModel.dart';

class GuardAttendanceOutService {
  static const String _baseUrl = "https://g17bookworld.com/API";
  static const String _markAttendance = "$_baseUrl/AttendenceManagement/MarkAttendance";

  Future<GuardCheckOutModel> checkOut({
    required String employeeId,
    required String mobile,
    required int? attendanceId,
    required String location,
    required File image,
    required double latitude,
    required double longitude,
    required DateTime checkInTime,
  }) async {
    try {
      print('=== Starting Check-Out Process ===');
      print('Employee ID: $employeeId');
      print('Mobile: $mobile');
      print('Attendance ID: $attendanceId');
      print('Location: $location');
      print('Latitude: $latitude, Longitude: $longitude');
      print('Check-in Time: $checkInTime');

      // Create multipart request
      final uri = Uri.parse(_markAttendance);
      final request = http.MultipartRequest('POST', uri);

      // Add form fields for check-out
      request.fields.addAll({
        'EmployeeId': employeeId.trim(),
        'EmpMobNo': mobile.trim(),
        'CheckOutLocation': location.trim(),
        'Latitude': latitude.toStringAsFixed(6),
        'Longitude': longitude.toStringAsFixed(6),
        'AttendanceId': attendanceId?.toString() ?? '', // Send attendance ID if available
        'CheckOutDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'CheckOutTime': DateFormat('HH:mm:ss').format(DateTime.now()),
        'Type': 'CheckOut', // Important: Tell backend this is check-out
      });

      print('Check-out form fields: ${request.fields}');

      // Add check-out image
      await _addCheckOutImageToRequest(request, image);

      // Send request
      print('Sending check-out request...');
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout after 30 seconds');
        },
      );

      // Get response
      final responseBody = await response.stream.bytesToString();
      print('Response Status: ${response.statusCode}');
      print('Response Body: $responseBody');

      // Parse response
      final decoded = json.decode(responseBody) as Map<String, dynamic>;
      final result = GuardCheckOutModel.fromJson(decoded);

      // Validate response
      if (response.statusCode != 200) {
        print('HTTP Error: ${response.statusCode}');
        return GuardCheckOutModel(
          status: false,
          message: 'Server error (HTTP ${response.statusCode})',
        );
      }

      if (!result.status) {
        print('API returned failure: ${result.message}');
        return result;
      }

      print('Check-Out Successful: ${result.message}');
      print('Work Duration: ${result.workDuration}');

      return result;

    } on TimeoutException catch (e) {
      print('Timeout Error: ${e.message}');
      return GuardCheckOutModel(
        status: false,
        message: 'Request timeout: ${e.message}',
      );
    } on http.ClientException catch (e) {
      print('Network Error: ${e.message}');
      return GuardCheckOutModel(
        status: false,
        message: 'Network error: Please check your connection',
      );
    } on FormatException catch (e) {
      print('Format Error: ${e.message}');
      return GuardCheckOutModel(
        status: false,
        message: 'Invalid server response format',
      );
    } on FileSystemException catch (e) {
      print('File Error: ${e.message}');
      return GuardCheckOutModel(
        status: false,
        message: 'Image file error: ${e.message}',
      );
    } catch (e) {
      print('Unexpected Error: $e');
      return GuardCheckOutModel(
        status: false,
        message: 'Check-out failed: ${e.toString()}',
      );
    }
  }

  Future<void> _addCheckOutImageToRequest(
      http.MultipartRequest request,
      File image,
      ) async {
    try {
      // Validate image exists
      if (!await image.exists()) {
        throw FileSystemException('Check-out image file not found');
      }

      // Check file size (max 5MB)
      final fileSize = await image.length();
      const maxSize = 5 * 1024 * 1024; // 5MB

      if (fileSize > maxSize) {
        throw FileSystemException(
          'Image too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). '
              'Max size is 5MB',
        );
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = image.path.split('.').last.toLowerCase();

      // Validate file type
      if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        throw FileSystemException(
          'Invalid image format. Only JPG and PNG are allowed',
        );
      }

      final fileName = 'checkout_${timestamp}.$fileExtension';

      print('Adding check-out image: $fileName (${fileSize ~/ 1024}KB)');

      // Add file to request with correct field name
      request.files.add(
        await http.MultipartFile.fromPath(
          'checkoutimage', // Field name from API response
          image.path,
          filename: fileName,
        ),
      );

    } catch (e) {
      rethrow;
    }
  }

  // Alternative: If backend needs different field name
  Future<void> _addImageToRequest(
      http.MultipartRequest request,
      File image,
      String fieldName,
      ) async {
    try {
      if (!await image.exists()) {
        throw FileSystemException('Image file not found');
      }

      final fileSize = await image.length();
      const maxSize = 5 * 1024 * 1024;

      if (fileSize > maxSize) {
        throw FileSystemException('Image too large (${fileSize ~/ (1024 * 1024)}MB)');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = image.path.split('.').last.toLowerCase();

      if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        throw FileSystemException('Invalid image format');
      }

      final fileName = '${fieldName}_${timestamp}.$fileExtension';

      print('Adding $fieldName image: $fileName');

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          image.path,
          filename: fileName,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
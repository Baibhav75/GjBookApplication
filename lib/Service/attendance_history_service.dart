import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../Model/attendance_history_model.dart';

/// Service class for fetching attendance history data
class AttendanceService {
  static const String _url =
      'https://g17bookworld.com/API/AttendanceHistory/GetAttendancehistory';

  static const Duration _timeoutDuration = Duration(seconds: 30);

  /// Fetch attendance history for a specific staff member by mobile number
  static Future<List<Attendance>> getAttendanceHistory(String mobileNo) async {
    // Validate input parameter
    if (mobileNo.isEmpty) {
      throw Exception('Mobile number is required');
    }
    
    try {
      // Call attendance API with mobile number as parameter
      final Uri uri = Uri.parse('$_url?mobileNo=$mobileNo');
      final http.Response response = await http
          .get(uri)
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final parsed = AttendanceResponse.fromJson(data);
        
        // Check if the API returned a success status
        if (parsed.status) {
          return parsed.records;
        } else {
          throw Exception(parsed.message.isNotEmpty ? parsed.message : 'Failed to fetch attendance data');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please check your internet connection.');
    } catch (e) {
      // Re-throw the exception with more context
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }
}
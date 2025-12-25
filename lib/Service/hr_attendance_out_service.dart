import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../Model/hr_attendance_out_model.dart';

class HrAttendanceOutService {
  static const String _url =
      'https://g17bookworld.com/API/AttendenceManagement/MarkAttendance';

  static Future<HrAttendanceOutModel> markCheckOut({
    required String employeeId,
    required String mobile,
    required Position position,
    required String address,
    required File image,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(_url));

    request.fields.addAll({
      'EmployeeId': employeeId,
      'EmpMobNo': mobile,
      'Type': 'CheckOut',
      'CheckOutLocation': address,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'checkoutimage',
        image.path,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print('CHECKOUT STATUS: ${response.statusCode}');
    print('CHECKOUT BODY: $body');

    if (response.statusCode != 200) {
      throw Exception('Server error ${response.statusCode}');
    }

    return HrAttendanceOutModel.fromJson(
      json.decode(body) as Map<String, dynamic>,
    );
  }
}

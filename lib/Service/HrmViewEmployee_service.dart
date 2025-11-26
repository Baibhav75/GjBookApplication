// service/HrmViewEmployee_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/HrmViewEmplyeeModel.dart';

class HrmViewEmployeeService {
  static const String apiUrl = 'https://gj.realhomes.co.in/API/EmployeeList/GetEmployee';

  Future<HrmViewEmployeeModel?> fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('API Response: ${responseData}'); // Debug print
        return HrmViewEmployeeModel.fromJson(responseData);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      print('Service Error: $e');
      throw Exception('Failed to load employees: $e');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/CounterDetailsAdmin_Model.dart';

class CounterDetailsService {

  Future<CounterDetailsAdminModel?> fetchCounterDetails(String counterId) async {

    final url =
        "https://g17bookworld.com/api/CounterDetails/GetCounterById?Counterid=$counterId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CounterDetailsAdminModel.fromJson(data);
    } else {
      return null;
    }
  }
}
import '../../Service/counter_details_service.dart';
import '/Model/CounterDetailsAdmin_Model.dart';


class CounterDetailsController {

  final CounterDetailsService _service = CounterDetailsService();

  Future<CounterDetailsAdminModel?> getDetails(String counterId) {
    return _service.fetchCounterDetails(counterId);
  }
}
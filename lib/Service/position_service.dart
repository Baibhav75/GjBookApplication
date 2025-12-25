import 'dart:async';

/// Service responsible for providing staff positions.
///
/// Currently returns a static list, but is structured to be easily
/// replaced with a real backend / API implementation later.
class PositionService {
  /// Fetches available staff positions.
  ///
  /// TODO: Replace this mock implementation with a real API call.
  static Future<List<String>> fetchPositions() async {
    // Simulate network latency (optional; can be removed if undesired)
    // await Future.delayed(const Duration(milliseconds: 300));

    return [
      "Accounts",
      "Billing",
      "Bouncer Man",
      "Collection Recovery",
      "Computer Operator",
      "Driver",
      "Field Recovery",
      "Godown Incharge",
      "Housekeeper",
      "IT",
      "Labours",
      "Manager",
      "Receptionist",
      "Sales",
      "Sales Officer",
      "Security Guard",
      "Services Incharge",
      "Stock",
      "Supervisor",
    ];
  }
}







class TrackingOrderResponse {
  final String status;
  final String message;
  final List<TrackingOrder> data;

  TrackingOrderResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TrackingOrderResponse.fromJson(Map<String, dynamic> json) {
    return TrackingOrderResponse(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      data: (json['Data'] as List<dynamic>)
          .map((e) => TrackingOrder.fromJson(e))
          .toList(),
    );
  }
}

class TrackingOrder {
  final String orderNo;
  final String senderId; // ✅ stored, not shown
  final String publication;
  final DateTime date;

  TrackingOrder({
    required this.orderNo,
    required this.senderId,
    required this.publication,
    required this.date,
  });

  factory TrackingOrder.fromJson(Map<String, dynamic> json) {
    return TrackingOrder(
      orderNo: json['OrderNo'] ?? '',
      senderId: json['SenderId'] ?? '',
      publication: json['Publication'] ?? '',
      date: DateTime.parse(json['Dates']),
    );
  }
}


class PublicationOrderDetailsResponse {
  final bool success;
  final OrderMaster master;
  final List<String> schools;
  final int totalPurchase;
  final double grandTotal; // ✅ FIXED
  final List<OrderItem> items;

  PublicationOrderDetailsResponse({
    required this.success,
    required this.master,
    required this.schools,
    required this.totalPurchase,
    required this.grandTotal,
    required this.items,
  });

  factory PublicationOrderDetailsResponse.fromJson(
      Map<String, dynamic> json) {
    return PublicationOrderDetailsResponse(
      success: json['success'] ?? false,
      master: OrderMaster.fromJson(json['master'] ?? {}),
      schools: List<String>.from(json['schools'] ?? []),
      totalPurchase: json['totalPurchase'] ?? 0,
      grandTotal: (json['GrandTotal'] as num?)?.toDouble() ?? 0.0, // ✅ SAFE
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderMaster {
  final String senderId;
  final String publicationId;
  final String publicationName;
  final String transport;
  final DateTime date;

  OrderMaster({
    required this.senderId,
    required this.publicationId,
    required this.publicationName,
    required this.transport,
    required this.date,
  });

  factory OrderMaster.fromJson(Map<String, dynamic> json) {
    return OrderMaster(
      senderId: json['SenderId'] ?? '',
      publicationId: json['PublicationId'] ?? '',
      publicationName: json['PublicationName'] ?? '',
      transport: json['Transport'] ?? '',
      date: DateTime.tryParse(json['Dates'] ?? '') ??
          DateTime.now(), // ✅ SAFE
    );
  }
}

class OrderItem {
  final String series;
  final String bookName;
  final String classes;
  final String subject;
  final int qty;
  final double rate;         // ✅ FIXED
  final double totalAmount;  // ✅ FIXED

  OrderItem({
    required this.series,
    required this.bookName,
    required this.classes,
    required this.subject,
    required this.qty,
    required this.rate,
    required this.totalAmount,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      series: json['Series'] ?? '',
      bookName: json['BookName'] ?? '',
      classes: json['Classes'] ?? '',
      subject: json['Subject'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,          // ✅ SAFE
      totalAmount:
      (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,   // ✅ SAFE
    );
  }
}

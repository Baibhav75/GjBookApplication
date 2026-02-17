class OrderTrackingDetailResponse {
  final String status;
  final String message;
  final TrackingMaster master;
  final List<TrackingItem> items;
  final int totalFromDB;
  final int totalShown;
  final List<String> allSchools;

  OrderTrackingDetailResponse({
    required this.status,
    required this.message,
    required this.master,
    required this.items,
    required this.totalFromDB,
    required this.totalShown,
    required this.allSchools,
  });

  factory OrderTrackingDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderTrackingDetailResponse(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      master: TrackingMaster.fromJson(json['Master'] ?? {}),
      items: (json['Items'] as List? ?? [])
          .map((e) => TrackingItem.fromJson(e))
          .toList(),
      totalFromDB: json['TotalFromDB'] ?? 0,
      totalShown: json['TotalShown'] ?? 0,
      allSchools: List<String>.from(json['AllSchools'] ?? []),
    );
  }
}

class TrackingMaster {
  final String orderNo;
  final String senderId;
  final String publication;
  final String transport;
  final String schoolName;
  final DateTime date;

  TrackingMaster({
    required this.orderNo,
    required this.senderId,
    required this.publication,
    required this.transport,
    required this.schoolName,
    required this.date,
  });

  factory TrackingMaster.fromJson(Map<String, dynamic> json) {
    return TrackingMaster(
      orderNo: json['OrderNo'] ?? '',
      senderId: json['SenderId'] ?? '',
      publication: json['Publication'] ?? '',
      transport: json['Transport'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      date: DateTime.tryParse(json['Dates'] ?? '') ?? DateTime.now(),
    );
  }
}

class TrackingItem {
  final String bookName;
  final String subject;
  final String classes;
  final String series;
  final int qty;
  final double rate;
  final double totalAmount;

  TrackingItem({
    required this.bookName,
    required this.subject,
    required this.classes,
    required this.series,
    required this.qty,
    required this.rate,
    required this.totalAmount,
  });

  factory TrackingItem.fromJson(Map<String, dynamic> json) {
    return TrackingItem(
      bookName: json['BookName'] ?? '',
      subject: json['Subject'] ?? '',
      classes: json['Classes'] ?? '',
      series: json['Series'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

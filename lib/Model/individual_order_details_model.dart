class IndividualOrderDetailsResponse {
  final String status;
  final OrderMaster master;
  final List<OrderItem> items;

  IndividualOrderDetailsResponse({
    required this.status,
    required this.master,
    required this.items,
  });

  factory IndividualOrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return IndividualOrderDetailsResponse(
      status: json['Status'] ?? '',
      master: OrderMaster.fromJson(json['Master'] ?? {}),
      items: (json['Items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderMaster {
  final String orderNo;
  final String publication;
  final String address;
  final String transport;
  final String? grNo;
  final DateTime date;
  final String schoolName;
  final String senderId;

  OrderMaster({
    required this.orderNo,
    required this.publication,
    required this.address,
    required this.transport,
    required this.grNo,
    required this.date,
    required this.schoolName,
    required this.senderId,
  });

  factory OrderMaster.fromJson(Map<String, dynamic> json) {
    return OrderMaster(
      orderNo: json['OrderNo'] ?? '',
      publication: json['Publication'] ?? '',
      address: json['Address'] ?? '',
      transport: json['Transport'] ?? '',
      grNo: json['GrNo'],
      schoolName: json['SchoolName'] ?? '',
      senderId: json['SenderId'] ?? '',
      date: DateTime.tryParse(json['Dates'] ?? '') ?? DateTime.now(),
    );
  }
}

class OrderItem {
  final String series;
  final String bookName;
  final String classes;
  final String subject;
  final int qty;
  final double rate;
  final double totalAmount;

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
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

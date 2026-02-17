class OrderDispatchInvoiceModel {
  final bool success;
  final Master master;
  final List<String> schools;
  final List<InvoiceItem> items;

  OrderDispatchInvoiceModel({
    required this.success,
    required this.master,
    required this.schools,
    required this.items,
  });

  factory OrderDispatchInvoiceModel.fromJson(Map<String, dynamic> json) {
    return OrderDispatchInvoiceModel(
      success: json['success'],
      master: Master.fromJson(json['Master']),
      schools: List<String>.from(json['Schools'] ?? []),
      items: (json['Items'] as List)
          .map((e) => InvoiceItem.fromJson(e))
          .toList(),
    );
  }
}

class Master {
  final String publication;
  final String address;
  final String orderNo;
  final String grNo;
  final String transport;
  final String bundal;
  final String dates;
  final String orderStatus;
  final String senderId;

  Master({
    required this.publication,
    required this.address,
    required this.orderNo,
    required this.grNo,
    required this.transport,
    required this.bundal,
    required this.dates,
    required this.orderStatus,
    required this.senderId,
  });

  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      publication: json['Publication'] ?? '',
      address: json['Address'] ?? '',
      orderNo: json['OrderNo'] ?? '',
      grNo: json['GrNo'] ?? '',
      transport: json['Transport'] ?? '',
      bundal: json['Bundal'] ?? '',
      dates: json['Dates'] ?? '',
      orderStatus: json['OrderStatus'] ?? '',
      senderId: json['SenderId'] ?? '',
    );
  }
}

class InvoiceItem {
  final String series;
  final String bookName;
  final String classes;
  final String subject;
  final double rate;
  final int qty;
  final double totalAmount;

  InvoiceItem({
    required this.series,
    required this.bookName,
    required this.classes,
    required this.subject,
    required this.rate,
    required this.qty,
    required this.totalAmount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      series: json['Series'] ?? '',
      bookName: json['BookName'] ?? '',
      classes: json['Classes'] ?? '',
      subject: json['Subject'] ?? '',
      rate: (json['Rate'] ?? 0).toDouble(),
      qty: json['Qty'] ?? 0,
      totalAmount: (json['TotalAmount'] ?? 0).toDouble(),
    );
  }
}

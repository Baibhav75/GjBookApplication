class OrderListModel {
  final String status;
  final String message;
  final List<OrderItem> data;

  OrderListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderListModel.fromJson(Map<String, dynamic> json) {
    return OrderListModel(
      status: json['Status'],
      message: json['Message'],
      data: (json['Data'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderItem {
  final String billNo;
  final String schoolName;
  final DateTime dates;
  final DateTime recDate;

  OrderItem({
    required this.billNo,
    required this.schoolName,
    required this.dates,
    required this.recDate,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      billNo: json['BillNo'],
      schoolName: json['SchoolName'],
      dates: DateTime.parse(json['Dates']),
      recDate: DateTime.parse(json['RecDate']),
    );
  }
}

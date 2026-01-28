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
      status: json['Status']?.toString() ?? '',
      message: json['Message']?.toString() ?? '',
      data: (json['Data'] as List?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final String billNo;
  final String schoolName;
  final String oldOrderDate;
  final String orderDate;
  final String counterSupply;
  final String agentName;
  final String mobileNo;
  final String billDate;

  OrderItem({
    required this.billNo,
    required this.schoolName,
    required this.oldOrderDate,
    required this.orderDate,
    required this.counterSupply,
    required this.agentName,
    required this.mobileNo,
    required this.billDate,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      billNo: json['BillNo']?.toString() ?? '',
      schoolName: json['SchoolName'] ?? '',
      oldOrderDate: json['OldOrderDate'] ?? '',
      orderDate: json['OrderDate'] ?? json['Dates'] ?? '',
      counterSupply: json['CounterSupply'] ?? '',
      agentName: json['AgentName'] ?? '',
      mobileNo: json['MobileNo'] ?? '',
      billDate: json['BillDate'] ?? json['RecDate'] ?? '',
    );
  }
}

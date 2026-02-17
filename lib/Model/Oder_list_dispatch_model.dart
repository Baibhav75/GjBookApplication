class OrderListDispatchModel {
  final String grNo;
  final String orderNo;
  final String senderId;
  final String publication;
  final String bundal;
  final String dates;

  OrderListDispatchModel({
    required this.grNo,
    required this.orderNo,
    required this.senderId,
    required this.publication,
    required this.bundal,
    required this.dates,
  });

  factory OrderListDispatchModel.fromJson(Map<String, dynamic> json) {
    return OrderListDispatchModel(
      grNo: json['GrNo'] ?? '',
      orderNo: json['OrderNo'] ?? '',
      senderId: json['SenderId'] ?? '',
      publication: json['Publication'] ?? '',
      bundal: json['Bundal'] ?? '',
      dates: json['Dates'] ?? '',
    );
  }
}
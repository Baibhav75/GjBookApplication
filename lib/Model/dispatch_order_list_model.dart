class DispatchOrderListModel {
  final String grNo;
  final String orderNo;
  final String senderId;
  final String publication;
  final String bundal;
  final DateTime dates;

  DispatchOrderListModel({
    required this.grNo,
    required this.orderNo,
    required this.senderId,
    required this.publication,
    required this.bundal,
    required this.dates,
  });

  factory DispatchOrderListModel.fromJson(Map<String, dynamic> json) {
    return DispatchOrderListModel(
      grNo: json['GrNo'] ?? '',
      orderNo: json['OrderNo'] ?? '',
      senderId: json['SenderId'] ?? '',
      publication: json['Publication'] ?? '',
      bundal: json['Bundal'] ?? '',
      dates: DateTime.parse(json['Dates']),
    );
  }
}

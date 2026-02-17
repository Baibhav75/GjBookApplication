class DiscussionOrderListModel {
  final String billNo;
  final String schoolName;
  final DateTime? dates;
  final DateTime? recDate;
  final DateTime? oldOrderDate;
  final String schoolMobileNo;
  final String counterType;
  final String? agentName;
  final String schoolType;

  DiscussionOrderListModel({
    required this.billNo,
    required this.schoolName,
    this.dates,
    this.recDate,
    this.oldOrderDate,
    required this.schoolMobileNo,
    required this.counterType,
    this.agentName,
    required this.schoolType,
  });

  factory DiscussionOrderListModel.fromJson(Map<String, dynamic> json) {
    return DiscussionOrderListModel(
      billNo: json['BillNo'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      dates: json['Dates'] != null ? DateTime.tryParse(json['Dates']) : null,
      recDate: json['RecDate'] != null ? DateTime.tryParse(json['RecDate']) : null,
      oldOrderDate: json['OldOrderDate'] != null
          ? DateTime.tryParse(json['OldOrderDate'])
          : null,
      schoolMobileNo: json['SchoolMobileNo'] ?? '',
      counterType: json['CounterType'] ?? '',
      agentName: json['CounterNamOrAgentName'],
      schoolType: json['SchoolType'] ?? '',
    );
  }
}

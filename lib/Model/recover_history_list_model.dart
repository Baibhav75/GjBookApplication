class RecoverHistoryListModel {
  final int id;
  final String schoolName;
  final String schoolId;
  final double amount;
  final String recivedByFromSchool;
  final String reciverEmpId;
  final DateTime payMentDate;
  final String status;
  final String? reciptNo;
  final String schoolAddress;
  final String collectedByInoffice;
  final String paymentMode;
  final String createdBy;
  final DateTime createDate;

  RecoverHistoryListModel({
    required this.id,
    required this.schoolName,
    required this.schoolId,
    required this.amount,
    required this.recivedByFromSchool,
    required this.reciverEmpId,
    required this.payMentDate,
    required this.status,
    this.reciptNo, // nullable so not required
    required this.schoolAddress,
    required this.collectedByInoffice,
    required this.paymentMode,
    required this.createdBy,
    required this.createDate,
  });

  factory RecoverHistoryListModel.fromJson(Map<String, dynamic> json) {
    return RecoverHistoryListModel(
      id: json['id'] ?? 0,
      schoolName: json['SchoolName'] ?? "",
      schoolId: json['SchoolId'] ?? "",
      amount: (json['Amount'] ?? 0).toDouble(),
      recivedByFromSchool: json['RecivedByFromSchool'] ?? "",
      reciverEmpId: json['ReciverEmpId'] ?? "",
      payMentDate: json['PayMentDate'] != null
          ? DateTime.parse(json['PayMentDate'])
          : DateTime.now(),
      status: json['Status'] ?? "",
      reciptNo: json['ReciptNo'],
      schoolAddress: json['SchoolAddress'] ?? "",
      collectedByInoffice: json['CollectedByInoffice'] ?? "",
      paymentMode: json['Paymentmode'] ?? "",
      createdBy: json['CreatedBy'] ?? "",
      createDate: json['CreateDate'] != null
          ? DateTime.parse(json['CreateDate'])
          : DateTime.now(),
    );
  }
}
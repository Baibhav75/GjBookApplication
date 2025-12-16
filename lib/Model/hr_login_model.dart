class HrLoginModel {
  final String status;
  final String message;
  final String hrName;
  final String hrEmail;
  final String mobileNo;

  HrLoginModel({
    required this.status,
    required this.message,
    required this.hrName,
    required this.hrEmail,
    required this.mobileNo,
  });

  factory HrLoginModel.fromJson(Map<String, dynamic> json) {
    return HrLoginModel(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      hrName: json['HRname'] ?? '',
      hrEmail: json['Hremail'] ?? '',
      mobileNo: json['MobileNo'] ?? '',
    );
  }
}

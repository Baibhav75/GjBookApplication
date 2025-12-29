class SchoolLoginModel {
  final String status;
  final String message;
  final String ownerName;
  final String ownerNumber;
  final String ownerPassword;

  SchoolLoginModel({
    required this.status,
    required this.message,
    required this.ownerName,
    required this.ownerNumber,
    required this.ownerPassword,
  });

  factory SchoolLoginModel.fromJson(Map<String, dynamic> json) {
    return SchoolLoginModel(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      ownerName: json['OwnerName'] ?? '',
      ownerNumber: json['OwnerNumber'] ?? '',
      ownerPassword: json['OwnerPassWord'] ?? '',
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}

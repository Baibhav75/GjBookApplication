class SchoolChangePasswordModel {
  final String status;
  final String message;
  final String? newPassword;

  SchoolChangePasswordModel({
    required this.status,
    required this.message,
    this.newPassword,
  });

  factory SchoolChangePasswordModel.fromJson(Map<String, dynamic> json) {
    return SchoolChangePasswordModel(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      newPassword: json['NewPassWord'],
    );
  }
}

class CounterChangePasswordModel {
  final bool status;
  final String message;
  final String? newPassword;

  CounterChangePasswordModel({
    required this.status,
    required this.message,
    this.newPassword,
  });

  factory CounterChangePasswordModel.fromJson(Map<String, dynamic> json) {
    return CounterChangePasswordModel(
      status: json['Status'] == 'Success',
      message: json['Message'] ?? '',
      newPassword: json['NewPassWord'],
    );
  }
}

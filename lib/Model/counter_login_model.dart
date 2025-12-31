class CounterLoginModel {
  final String status;
  final String message;
  final String counterBoyName;
  final String counterBoyNo;
  final String counterBoyPassword;

  CounterLoginModel({
    required this.status,
    required this.message,
    required this.counterBoyName,
    required this.counterBoyNo,
    required this.counterBoyPassword,
  });

  factory CounterLoginModel.fromJson(Map<String, dynamic> json) {
    return CounterLoginModel(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      counterBoyName: json['CounterBoyName'] ?? '',
      counterBoyNo: json['CounterBoyNo'] ?? '',
      counterBoyPassword: json['CounterBoyPassWord'] ?? '',
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}

class SecurityGuardLoginModel {
  final String status;
  final String message;
  final String name;
  final String email;
  final String position;

  SecurityGuardLoginModel({
    required this.status,
    required this.message,
    required this.name,
    required this.email,
    required this.position,
  });

  factory SecurityGuardLoginModel.fromJson(Map<String, dynamic> json) {
    return SecurityGuardLoginModel(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      name: json['AgentName'] ?? '',
      email: json['AgentAdminEmail'] ?? '',
      position: json['Position'] ?? '',
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}

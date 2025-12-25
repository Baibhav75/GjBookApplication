class SecurityGuardLoginModel {
  final String status;
  final String message;
  final String name;
  final String email;
  final String position;
  final String employeeId;

  SecurityGuardLoginModel({
    required this.status,
    required this.message,
    required this.name,
    required this.email,
    required this.position,
    required this.employeeId,
  });

  factory SecurityGuardLoginModel.fromJson(Map<String, dynamic> json) {
    return SecurityGuardLoginModel(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      name: json['AgentName'] ?? '',
      email: json['AgentAdminEmail'] ?? '',
      position: json['Position'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}

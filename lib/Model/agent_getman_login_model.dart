class AgentGetManLoginModel {
  final String status;
  final String message;
  final String agentName;
  final String agentAdminEmail;
  final String position;
  final String employeeId;

  AgentGetManLoginModel({
    required this.status,
    required this.message,
    required this.agentName,
    required this.agentAdminEmail,
    required this.position,
    required this.employeeId,
  });

  factory AgentGetManLoginModel.fromJson(Map<String, dynamic> json) {
    return AgentGetManLoginModel(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      agentName: json['AgentName'] ?? '',
      agentAdminEmail: json['AgentAdminEmail'] ?? '',
      position: json['Position'] ?? '',
      employeeId: json['EmployeeId'] ?? '',
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}

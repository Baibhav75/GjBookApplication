class AgentGetManLoginModel {
  final String status;
  final String message;
  final String agentName;
  final String agentAdminEmail;
  final String? position;
  final String employeeId;
  final String? agentPassword;

  AgentGetManLoginModel({
    required this.status,
    required this.message,
    required this.agentName,
    required this.agentAdminEmail,
    this.position,
    required this.employeeId,
    this.agentPassword,
  });

  factory AgentGetManLoginModel.fromJson(Map<String, dynamic> json) {
    return AgentGetManLoginModel(
      status: (json['Status'] ?? json['status'] ?? '').toString(),
      message: (json['Message'] ?? json['message'] ?? '').toString(),
      agentName: (json['AgentName'] ?? json['agentName'] ?? '').toString(),
      agentAdminEmail: (json['AgentAdminEmail'] ?? json['agentAdminEmail'] ?? '').toString(),
      position: (json['Position'] ?? json['position'] ?? '').toString(),
      employeeId: (json['EmployeeId'] ?? json['employeeId'] ?? json['EmployeeID'] ?? json['id'] ?? '').toString(),
      agentPassword: (json['AgentPassword'] ?? json['agentPassword'] ?? '').toString(),
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}

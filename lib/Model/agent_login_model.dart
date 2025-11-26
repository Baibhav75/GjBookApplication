class AgentLoginModel {
  final String status;
  final String message;
  final String agentName;
  final String employeeType;
  final String agentAdminEmail;
  final String agentPassword;

  AgentLoginModel({
    required this.status,
    required this.message,
    required this.agentName,
    required this.employeeType,
    required this.agentAdminEmail,
    required this.agentPassword,
  });

  factory AgentLoginModel.fromJson(Map<String, dynamic> json) {
    return AgentLoginModel(
      status: json['Status'] ?? "",
      message: json['Message'] ?? "",
      agentName: json['AgentName'] ?? "",
      employeeType: json['EmployeeType'] ?? "",
      agentAdminEmail: json['AgentAdminEmail'] ?? "",
      agentPassword: json['AgentPassword'] ?? "",
    );
  }
}

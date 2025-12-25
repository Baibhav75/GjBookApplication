class AgentLoginModel {
  final String status;
  final String message;
  final String agentName;
  final String employeeType;
  final String agentAdminEmail;
  final String agentPassword;
  final String mobileNo; // Added mobile number field
  final String position; // Added position field

  AgentLoginModel({
    required this.status,
    required this.message,
    required this.agentName,
    required this.employeeType,
    required this.agentAdminEmail,
    required this.agentPassword,
    required this.mobileNo, // Added mobile number parameter
    required this.position, // Added position parameter
  });

  factory AgentLoginModel.fromJson(Map<String, dynamic> json) {
    return AgentLoginModel(
      status: json['Status'] ?? "",
      message: json['Message'] ?? "",
      agentName: json['AgentName'] ?? "",
      employeeType: json['Position'] ?? "", // Map Position to employeeType
      agentAdminEmail: json['AgentAdminEmail'] ?? "",
      agentPassword: json['AgentPassword'] ?? "",
      mobileNo: json['MobileNo'] ?? "", // Added mobile number from JSON
      position: json['Position'] ?? "", // Added position from JSON
    );
  }
}

class AgentGetManLoginModel {
  final String status;
  final String message;
  final String agentName;
  final String agentAdminEmail;
  final String position;

  AgentGetManLoginModel({
    required this.status,
    required this.message,
    required this.agentName,
    required this.agentAdminEmail,
    required this.position,
  });

  factory AgentGetManLoginModel.fromJson(Map<String, dynamic> json) {
    return AgentGetManLoginModel(
      status: json['Status'] ?? '',
      message: json['Message'] ?? '',
      agentName: json['AgentName'] ?? '',
      agentAdminEmail: json['AgentAdminEmail'] ?? '',
      position: json['Position'] ?? '',
    );
  }

  bool get isSuccess => status.toLowerCase() == "success";
}

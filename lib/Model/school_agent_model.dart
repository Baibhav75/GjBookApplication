class SchoolAgentResponse {
  final bool success;
  final List<SchoolAgent> data;

  SchoolAgentResponse({required this.success, required this.data});

  factory SchoolAgentResponse.fromJson(Map<String, dynamic> json) {
    return SchoolAgentResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((e) => SchoolAgent.fromJson(e))
          .toList(),
    );
  }
}

class SchoolAgent {
  final int id;
  final String schoolName;
  final String schoolAddress;
  final String district;
  final String tahsil;
  final String block;
  final String village;
  final String mobile;
  final String principalName;
  final String principalMobile;
  final String agentId;
  final String agentName;
  final int totalStudents;

  SchoolAgent({
    required this.id,
    required this.schoolName,
    required this.schoolAddress,
    required this.district,
    required this.tahsil,
    required this.block,
    required this.village,
    required this.mobile,
    required this.principalName,
    required this.principalMobile,
    required this.agentId,
    required this.agentName,
    required this.totalStudents,
  });

  factory SchoolAgent.fromJson(Map<String, dynamic> json) {
    return SchoolAgent(
      id: json['Id'],
      schoolName: json['SchoolName'] ?? '',
      schoolAddress: json['SchoolAddress'] ?? '',
      district: json['District'] ?? '',
      tahsil: json['Tahsil'] ?? '',
      block: json['Block'] ?? '',
      village: json['Village'] ?? '',
      mobile: json['Mobile'] ?? '',
      principalName: json['PrincipalName'] ?? '',
      principalMobile: json['PrincipalMobile'] ?? '',
      agentId: json['AgentId'] ?? '',
      agentName: json['AgentName'] ?? '',
      totalStudents: json['AllTotal'] ?? 0,
    );
  }
}

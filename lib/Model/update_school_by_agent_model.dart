class UpdateSchoolByAgentRequest {
  final int id;
  final String agentId;
  final String schoolAddress;
  final String district;

  UpdateSchoolByAgentRequest({
    required this.id,
    required this.agentId,
    required this.schoolAddress,
    required this.district,
  });

  Map<String, dynamic> toJson() {
    return {
      "Id": id,
      "AgentId": agentId,
      "SchoolAddress": schoolAddress,
      "District": district,
    };
  }
}

class UpdateSchoolByAgentResponse {
  final String message;

  UpdateSchoolByAgentResponse({required this.message});

  factory UpdateSchoolByAgentResponse.fromJson(Map<String, dynamic> json) {
    return UpdateSchoolByAgentResponse(
      message: json["Message"] ?? "",
    );
  }
}

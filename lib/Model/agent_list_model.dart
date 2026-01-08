class AgentListResponse {
  final bool status;
  final String message;
  final List<AgentEmployee> employeeList;

  AgentListResponse({
    required this.status,
    required this.message,
    required this.employeeList,
  });

  factory AgentListResponse.fromJson(Map<String, dynamic> json) {
    return AgentListResponse(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      employeeList: (json['EmployeeList'] as List? ?? [])
          .map((e) => AgentEmployee.fromJson(e))
          .toList(),
    );
  }
}

class AgentEmployee {
  final String employeeName;
  final String employeeId;
  final String designation;
  final String contactNumber;

  AgentEmployee({
    required this.employeeName,
    required this.employeeId,
    required this.designation,
    required this.contactNumber,
  });

  factory AgentEmployee.fromJson(Map<String, dynamic> json) {
    return AgentEmployee(
      employeeName: json['EmployeeName'] ?? '',
      employeeId: json['Employeid'] ?? '',
      designation: json['Designation'] ?? '',
      contactNumber: json['ContactNumber'] ?? '',
    );
  }
}

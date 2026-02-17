class SchoolAgreementAgentModel {
  final bool status;
  final String message;
  final List<AgentItem> employeeList;

  SchoolAgreementAgentModel({
    required this.status,
    required this.message,
    required this.employeeList,
  });

  factory SchoolAgreementAgentModel.fromJson(Map<String, dynamic> json) {
    return SchoolAgreementAgentModel(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      employeeList: (json['EmployeeList'] as List)
          .map((e) => AgentItem.fromJson(e))
          .toList(),
    );
  }
}

class AgentItem {
  final String employeeName;
  final String employeeId;
  final String designation;
  final String contactNumber;

  AgentItem({
    required this.employeeName,
    required this.employeeId,
    required this.designation,
    required this.contactNumber,
  });

  factory AgentItem.fromJson(Map<String, dynamic> json) {
    return AgentItem(
      employeeName: json['EmployeeName'] ?? '',
      employeeId: json['Employeid'] ?? '',
      designation: json['Designation'] ?? '',
      contactNumber: json['ContactNumber'] ?? '',
    );
  }
}

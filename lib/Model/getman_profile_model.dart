class GetManProfileModel {
  final String employeeId;
  final String employeeName;
  final String email;
  final String mobile;
  final String alternate;
  final String fatherName;
  final String motherName;
  final String dob;
  final String gender;
  final String maritalStatus;
  final String permanentAddress;
  final String currentAddress;
  final String department;
  final String designation;
  final String joiningDate;
  final double salary;
  final String employeeType;

  GetManProfileModel({
    required this.employeeId,
    required this.employeeName,
    required this.email,
    required this.mobile,
    required this.alternate,
    required this.fatherName,
    required this.motherName,
    required this.dob,
    required this.gender,
    required this.maritalStatus,
    required this.permanentAddress,
    required this.currentAddress,
    required this.department,
    required this.designation,
    required this.joiningDate,
    required this.salary,
    required this.employeeType,
  });

  factory GetManProfileModel.fromJson(Map<String, dynamic> json) {
    return GetManProfileModel(
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      email: json['Email'] ?? '',
      mobile: json['Mobile'] ?? '',
      alternate: json['AlterNate'] ?? '',
      fatherName: json['EmployeeFahterName'] ?? '',
      motherName: json['EmployeeMotherName'] ?? '',
      dob: json['EmpDateOfbirth'] ?? '',
      gender: json['Gender'] ?? '',
      maritalStatus: json['MartialStatus'] ?? '',
      permanentAddress: json['PermanantAddress'] ?? '',
      currentAddress: json['CurrentAddress'] ?? '',
      department: json['Department'] ?? '',
      designation: json['Designation'] ?? '',
      joiningDate: json['DateOFJoining'] ?? '',
      salary: (json['Salary'] ?? 0).toDouble(),
      employeeType: json['Employeetype'] ?? '',
    );
  }
}

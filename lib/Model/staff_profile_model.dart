class StaffProfileModel {
  final String employeeId;
  final String employeeName;
  final String email;
  final String mobile;
  final String alternate;
  final String password;
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

  StaffProfileModel({
    required this.employeeId,
    required this.employeeName,
    required this.email,
    required this.mobile,
    required this.alternate,
    required this.password,
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

  factory StaffProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? {};

    return StaffProfileModel(
      employeeId: data["EmployeeId"] ?? "",
      employeeName: data["EmployeeName"] ?? "",
      email: data["Email"] ?? "",
      mobile: data["Mobile"] ?? "",
      alternate: data["AlterNate"] ?? "",
      password: data["Password"] ?? "",
      fatherName: data["EmployeeFahterName"] ?? "",
      motherName: data["EmployeeMotherName"] ?? "",
      dob: data["EmpDateOfbirth"] ?? "",
      gender: data["Gender"] ?? "",
      maritalStatus: data["MartialStatus"] ?? "",
      permanentAddress: data["PermanantAddress"] ?? "",
      currentAddress: data["CurrentAddress"] ?? "",
      department: data["Department"] ?? "",
      designation: data["Designation"] ?? "",
      joiningDate: data["DateOFJoining"] ?? "",
      salary: (data["Salary"] as num?)?.toDouble() ?? 0.0,
      employeeType: data["Employeetype"] ?? "",
    );
  }
}

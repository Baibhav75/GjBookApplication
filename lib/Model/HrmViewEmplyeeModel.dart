// model/HrmViewEmployee_model.dart
class HrmViewEmployeeModel {
  bool? status;
  String? message;
  List<EmployeeList>? employeeList;

  HrmViewEmployeeModel({this.status, this.message, this.employeeList});

  HrmViewEmployeeModel.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
    if (json['EmployeeList'] != null) {
      employeeList = <EmployeeList>[];
      json['EmployeeList'].forEach((v) {
        employeeList!.add(EmployeeList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status'] = status;
    data['Message'] = message;
    if (employeeList != null) {
      data['EmployeeList'] = employeeList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EmployeeList {
  String? employeeName;
  String? contactNumber;
  String? employeeFatherName;
  String? employeeMotherName;
  String? dateOfBirth;
  String? gender;
  String? martialStatus;
  String? permanantAddress;
  String? currentAddress;
  String? anotherContactNumber;
  String? emailId;
  String? departmentName;
  String? designation;
  String? dateOfJoining;
  String? employeeType;
  String? aadharPic;
  String? passportsizePic;
  String? resumePic;
  String? bankAccountDetail;
  dynamic salary; // Changed from int? to dynamic
  String? lifevision;
  dynamic fatherEarlyIncome; // Changed from int? to dynamic
  dynamic motherEarlyIncome; // Changed from int? to dynamic
  String? workinternship;
  String? familyType;
  String? eveningSleepingTime;
  dynamic morningWakeupTime;
  String? policeverification;
  String? salaryConfirmation;
  String? ruleRegulation;
  dynamic position;
  String? agrementFrom;
  String? employeid;

  EmployeeList({
    this.employeeName,
    this.contactNumber,
    this.employeeFatherName,
    this.employeeMotherName,
    this.dateOfBirth,
    this.gender,
    this.martialStatus,
    this.permanantAddress,
    this.currentAddress,
    this.anotherContactNumber,
    this.emailId,
    this.departmentName,
    this.designation,
    this.dateOfJoining,
    this.employeeType,
    this.aadharPic,
    this.passportsizePic,
    this.resumePic,
    this.bankAccountDetail,
    this.salary,
    this.lifevision,
    this.fatherEarlyIncome,
    this.motherEarlyIncome,
    this.workinternship,
    this.familyType,
    this.eveningSleepingTime,
    this.morningWakeupTime,
    this.policeverification,
    this.salaryConfirmation,
    this.ruleRegulation,
    this.position,
    this.agrementFrom,
    this.employeid,
  });

  factory EmployeeList.fromJson(Map<String, dynamic> json) {
    return EmployeeList(
      employeeName: json['EmployeeName']?.toString(),
      contactNumber: json['ContactNumber']?.toString(),
      employeeFatherName: json['EmployeeFatherName']?.toString(),
      employeeMotherName: json['EmployeeMotherName']?.toString(),
      dateOfBirth: json['DateOfBirth']?.toString(),
      gender: json['Gender']?.toString(),
      martialStatus: json['MartialStatus']?.toString(),
      permanantAddress: json['PermanantAddress']?.toString(),
      currentAddress: json['CurrentAddress']?.toString(),
      anotherContactNumber: json['AnotherContactNumber']?.toString(),
      emailId: json['EmailId']?.toString(),
      departmentName: json['DepartmentName']?.toString(),
      designation: json['Designation']?.toString(),
      dateOfJoining: json['DateOfJoining']?.toString(),
      employeeType: json['EmployeeType']?.toString(),
      aadharPic: json['AadharPic']?.toString(),
      passportsizePic: json['PassportsizePic']?.toString(),
      resumePic: json['ResumePic']?.toString(),
      bankAccountDetail: json['BankAccountDetail']?.toString(),
      salary: json['Salary'],
      lifevision: json['Lifevision']?.toString(),
      fatherEarlyIncome: json['FatherEarlyIncome'],
      motherEarlyIncome: json['MotherEarlyIncome'],
      workinternship: json['Workinternship']?.toString(),
      familyType: json['FamilyType']?.toString(),
      eveningSleepingTime: json['EveningSleepingTime']?.toString(),
      morningWakeupTime: json['MorningWakeupTime'],
      policeverification: json['Policeverification']?.toString(),
      salaryConfirmation: json['SalaryConfirmation']?.toString(),
      ruleRegulation: json['RuleRegulation']?.toString(),
      position: json['Position'],
      agrementFrom: json['AgrementFrom']?.toString(),
      employeid: json['Employeid']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['EmployeeName'] = employeeName;
    data['ContactNumber'] = contactNumber;
    data['EmployeeFatherName'] = employeeFatherName;
    data['EmployeeMotherName'] = employeeMotherName;
    data['DateOfBirth'] = dateOfBirth;
    data['Gender'] = gender;
    data['MartialStatus'] = martialStatus;
    data['PermanantAddress'] = permanantAddress;
    data['CurrentAddress'] = currentAddress;
    data['AnotherContactNumber'] = anotherContactNumber;
    data['EmailId'] = emailId;
    data['DepartmentName'] = departmentName;
    data['Designation'] = designation;
    data['DateOfJoining'] = dateOfJoining;
    data['EmployeeType'] = employeeType;
    data['AadharPic'] = aadharPic;
    data['PassportsizePic'] = passportsizePic;
    data['ResumePic'] = resumePic;
    data['BankAccountDetail'] = bankAccountDetail;
    data['Salary'] = salary;
    data['Lifevision'] = lifevision;
    data['FatherEarlyIncome'] = fatherEarlyIncome;
    data['MotherEarlyIncome'] = motherEarlyIncome;
    data['Workinternship'] = workinternship;
    data['FamilyType'] = familyType;
    data['EveningSleepingTime'] = eveningSleepingTime;
    data['MorningWakeupTime'] = morningWakeupTime;
    data['Policeverification'] = policeverification;
    data['SalaryConfirmation'] = salaryConfirmation;
    data['RuleRegulation'] = ruleRegulation;
    data['Position'] = position;
    data['AgrementFrom'] = agrementFrom;
    data['Employeid'] = employeid;
    return data;
  }

  // Helper methods to safely convert dynamic fields
  int? get salaryAsInt {
    if (salary == null) return null;
    if (salary is int) return salary as int;
    if (salary is double) return (salary as double).round();
    if (salary is String) return int.tryParse(salary as String);
    return null;
  }

  String? get salaryFormatted {
    final salaryValue = salaryAsInt;
    return salaryValue?.toString() ?? 'N/A';
  }
}
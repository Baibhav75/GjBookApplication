class RecovertAssignedSchoolModel {
  String? status;
  String? message;
  Data? data;

  RecovertAssignedSchoolModel({this.status, this.message, this.data});

  RecovertAssignedSchoolModel.fromJson(Map<String, dynamic> json) {
    status = (json['status'] ?? json['Status'])?.toString();
    message = (json['message'] ?? json['Message'])?.toString();
    data = (json['data'] ?? json['Data']) != null
        ? Data.fromJson(json['data'] ?? json['Data'])
        : null;
  }
}

class Data {
  int? assignedSchoolCount;
  String? employeeId;
  String? employeeName;
  String? empMobileNo;
  String? empEmail;
  int? totalDueAmount; // ✅ NEW
  List<Schools>? schools;

  Data({
    this.assignedSchoolCount,
    this.employeeId,
    this.employeeName,
    this.empMobileNo,
    this.empEmail,
    this.totalDueAmount,
    this.schools,
  });

  Data.fromJson(Map<String, dynamic> json) {
    assignedSchoolCount = _parseInt(json['AssignedSchoolCount'] ?? json['assignedSchoolCount']);
    employeeId = (json['EmployeeId'] ?? json['employeeId'])?.toString();
    employeeName = (json['EmployeeName'] ?? json['employeeName'])?.toString();
    empMobileNo = (json['EmpMobileNo'] ?? json['empMobileNo'])?.toString();
    empEmail = (json['EmpEmail'] ?? json['empEmail'])?.toString();

    totalDueAmount = _parseInt(json['TotalDueAmount'] ?? json['totalDueAmount']);

    if (json['Schools'] != null) {
      schools = <Schools>[];
      json['Schools'].forEach((v) {
        schools!.add(Schools.fromJson(v));
      });
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.tryParse(value.toString())?.toInt() ?? 0;
  }
}

class Schools {
  String? schoolId;
  String? schoolName;
  String? principalName;
  String? principalMoNo;
  String? schoolAddress;
  String? emailAddress;

  int? totalSale;     // ✅ NEW
  int? totalReturn;   // ✅ NEW
  int? totalPayment;  // ✅ NEW
  int? dueAmount;     // ✅ NEW

  Schools({
    this.schoolId,
    this.schoolName,
    this.principalName,
    this.principalMoNo,
    this.schoolAddress,
    this.emailAddress,
    this.totalSale,
    this.totalReturn,
    this.totalPayment,
    this.dueAmount,
  });

  Schools.fromJson(Map<String, dynamic> json) {
    schoolId = (json['SchoolId'] ?? json['schoolId'])?.toString();
    schoolName = (json['SchoolName'] ?? json['schoolName'])?.toString();
    principalName = (json['PrincipalName'] ?? json['principalName'])?.toString();
    principalMoNo = (json['PrincipalMoNo'] ?? json['principalMoNo'])?.toString();
    schoolAddress = (json['SchoolAddress'] ?? json['schoolAddress'])?.toString();
    emailAddress = (json['EmailAddress'] ?? json['emailAddress'])?.toString();

    totalSale = _parseInt(json['TotalSale'] ?? json['totalSale']);
    totalReturn = _parseInt(json['TotalReturn'] ?? json['totalReturn']);
    totalPayment = _parseInt(json['TotalPayment'] ?? json['totalPayment']);
    dueAmount = _parseInt(json['DueAmount'] ?? json['dueAmount']);
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.tryParse(value.toString())?.toInt() ?? 0;
  }
}
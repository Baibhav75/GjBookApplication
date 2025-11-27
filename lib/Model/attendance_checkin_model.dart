class AttendanceCheckInModel {
  final bool status;
  final String? type;
  final String? message;
  final String? checkInTime;
  final String? workDuration;
  final AttendanceData? data;

  AttendanceCheckInModel({
    required this.status,
    this.type,
    this.message,
    this.checkInTime,
    this.workDuration,
    this.data,
  });

  factory AttendanceCheckInModel.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceCheckInModel(
        status: json['status'] == true || json['Status'] == true || json['status'] == 'true' || json['Status'] == 'true',
        type: json['type']?.toString() ?? json['Type']?.toString(),
        message: json['message']?.toString() ?? json['Message']?.toString() ?? json['msg']?.toString() ?? json['Msg']?.toString(),
        checkInTime: json['checkInTime']?.toString() ?? json['CheckInTime']?.toString(),
        workDuration: json['workDuration']?.toString() ?? json['WorkDuration']?.toString(),
        data: json['data'] != null && json['data'] is Map<String, dynamic>
            ? AttendanceData.fromJson(json['data'] as Map<String, dynamic>)
            : json['Data'] != null && json['Data'] is Map<String, dynamic>
                ? AttendanceData.fromJson(json['Data'] as Map<String, dynamic>)
                : null,
      );
    } catch (e) {
      print("Model parsing error: $e");
      return AttendanceCheckInModel(
        status: false,
        message: "Failed to parse response: $e",
        type: "error",
      );
    }
  }
}

class AttendanceData {
  final String? id;
  final String? employeeId;
  final String? empMobNo;
  final String? checkInTime;
  final String? checkOutTime;
  final String? workDuration;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInImage;
  final String? checkOutImage;
  final String? empName;

  AttendanceData({
    this.id,
    this.employeeId,
    this.empMobNo,
    this.checkInTime,
    this.checkOutTime,
    this.workDuration,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInImage,
    this.checkOutImage,
    this.empName,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceData(
        id: json['Id']?.toString() ?? json['id']?.toString(),
        employeeId: json['EmployeeId']?.toString() ?? json['employeeId']?.toString(),
        empMobNo: json['EmpMobNo']?.toString() ?? json['empMobNo']?.toString(),
        checkInTime: json['CheckInTime']?.toString() ?? json['checkInTime']?.toString(),
        checkOutTime: json['CheckOutTime']?.toString() ?? json['checkOutTime']?.toString(),
        workDuration: json['WorkDuration']?.toString() ?? json['workDuration']?.toString(),
        checkInLocation: json['CheckInLocation']?.toString() ?? json['checkInLocation']?.toString(),
        checkOutLocation: json['CheckOutLocation']?.toString() ?? json['checkOutLocation']?.toString(),
        checkInImage: json['CheckinImage']?.toString() ?? json['checkinImage']?.toString() ?? json['CheckInImage']?.toString(),
        checkOutImage: json['checkoutimage']?.toString() ?? json['checkOutImage']?.toString() ?? json['CheckOutImage']?.toString(),
        empName: json['Emp_Name']?.toString() ?? json['empName']?.toString() ?? json['EmpName']?.toString(),
      );
    } catch (e) {
      print("AttendanceData parsing error: $e");
      return AttendanceData();
    }
  }
}

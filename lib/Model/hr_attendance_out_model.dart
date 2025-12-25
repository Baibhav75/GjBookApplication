class HrAttendanceOutModel {
  final bool status;
  final String message;
  final String type;
  final DateTime? checkOutTime;
  final String? workDuration;
  final AttendanceData? data;

  HrAttendanceOutModel({
    required this.status,
    required this.message,
    required this.type,
    this.checkOutTime,
    this.workDuration,
    this.data,
  });

  factory HrAttendanceOutModel.fromJson(Map<String, dynamic> json) {
    return HrAttendanceOutModel(
      status: json['status'] == true || json['Status'] == true,
      type: json['type']?.toString() ?? json['Type']?.toString() ?? 'CheckOut',
      message: json['message']?.toString() ??
          json['Message']?.toString() ??
          '',
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.tryParse(json['checkOutTime'].toString())
          : json['CheckOutTime'] != null
          ? DateTime.tryParse(json['CheckOutTime'].toString())
          : null,
      workDuration: json['workDuration']?.toString() ??
          json['WorkDuration']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AttendanceData.fromJson(json['data'])
          : json['Data'] != null && json['Data'] is Map<String, dynamic>
          ? AttendanceData.fromJson(json['Data'])
          : null,
    );
  }
}

class AttendanceData {
  final int id;
  final String employeeId;
  final String empMobile;
  final String empName;
  final String? checkInTime;
  final String? checkOutTime;
  final String? workDuration;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInImage;
  final String? checkOutImage;

  AttendanceData({
    required this.id,
    required this.employeeId,
    required this.empMobile,
    required this.empName,
    this.checkInTime,
    this.checkOutTime,
    this.workDuration,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInImage,
    this.checkOutImage,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: int.tryParse(json['Id']?.toString() ?? '0') ?? 0,
      employeeId: json['EmployeeId']?.toString() ?? '',
      empMobile: json['EmpMobNo']?.toString() ?? '',
      empName: json['Emp_Name']?.toString() ?? '',
      checkInTime: json['CheckInTime']?.toString(),
      checkOutTime: json['CheckOutTime']?.toString(),
      workDuration: json['WorkDuration']?.toString(),
      checkInLocation: json['CheckInLocation']?.toString(),
      checkOutLocation: json['CheckOutLocation']?.toString(),
      checkInImage: json['CheckinImage']?.toString(),
      checkOutImage: json['checkoutimage']?.toString(),
    );
  }
}

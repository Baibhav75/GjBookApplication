class AttendanceCheckOutModel {
  final bool status;
  final String type;
  final String message;
  final String? checkOutTime;
  final String? workDuration;
  final AttendanceData? data;

  AttendanceCheckOutModel({
    required this.status,
    required this.type,
    required this.message,
    this.checkOutTime,
    this.workDuration,
    this.data,
  });

  factory AttendanceCheckOutModel.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceCheckOutModel(
        status: json['status'] == true || json['Status'] == true || json['status'] == 'true' || json['Status'] == 'true',
        type: json['type']?.toString() ?? json['Type']?.toString() ?? 'CheckOut',
        message: json['message']?.toString() ?? json['Message']?.toString() ?? json['msg']?.toString() ?? json['Msg']?.toString() ?? '',
        checkOutTime: json['checkOutTime']?.toString() ?? json['CheckOutTime']?.toString(),
        workDuration: json['workDuration']?.toString() ?? json['WorkDuration']?.toString(),
        data: json['data'] != null && json['data'] is Map<String, dynamic>
            ? AttendanceData.fromJson(json['data'] as Map<String, dynamic>)
            : json['Data'] != null && json['Data'] is Map<String, dynamic>
                ? AttendanceData.fromJson(json['Data'] as Map<String, dynamic>)
                : null,
      );
    } catch (e) {
      print("Model parsing error: $e");
      return AttendanceCheckOutModel(
        status: false,
        type: "error",
        message: "Failed to parse response: $e",
      );
    }
  }
}

class AttendanceData {
  final int id;
  final String employeeId;
  final String empMobile;
  final String? checkInTime;
  final String? checkOutTime;
  final String? workDuration;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInImage;
  final String? checkOutImage;
  final String empName;

  AttendanceData({
    required this.id,
    required this.employeeId,
    required this.empMobile,
    this.checkInTime,
    this.checkOutTime,
    this.workDuration,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInImage,
    this.checkOutImage,
    required this.empName,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceData(
        id: (json['Id'] ?? json['id'] ?? 0) is int ? (json['Id'] ?? json['id'] ?? 0) : int.tryParse((json['Id'] ?? json['id'] ?? '0').toString()) ?? 0,
        employeeId: json['EmployeeId']?.toString() ?? json['employeeId']?.toString() ?? '',
        empMobile: json['EmpMobNo']?.toString() ?? json['empMobNo']?.toString() ?? '',
        checkInTime: json['CheckInTime']?.toString() ?? json['checkInTime']?.toString(),
        checkOutTime: json['CheckOutTime']?.toString() ?? json['checkOutTime']?.toString(),
        workDuration: json['WorkDuration']?.toString() ?? json['workDuration']?.toString(),
        checkInLocation: json['CheckInLocation']?.toString() ?? json['checkInLocation']?.toString(),
        checkOutLocation: json['CheckOutLocation']?.toString() ?? json['checkOutLocation']?.toString(),
        checkInImage: json['CheckinImage']?.toString() ?? json['checkinImage']?.toString() ?? json['CheckInImage']?.toString(),
        checkOutImage: json['checkoutimage']?.toString() ?? json['checkOutImage']?.toString() ?? json['CheckOutImage']?.toString(),
        empName: json['Emp_Name']?.toString() ?? json['empName']?.toString() ?? json['EmpName']?.toString() ?? '',
      );
    } catch (e) {
      print("AttendanceData parsing error: $e");
      return AttendanceData(
        id: 0,
        employeeId: '',
        empMobile: '',
        empName: '',
      );
    }
  }
}

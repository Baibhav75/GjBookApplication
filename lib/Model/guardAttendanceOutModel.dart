// guardAttendanceOutModel.dart
import 'dart:convert';

class GuardCheckOutModel {
  final bool status;
  final String? type;
  final String message;
  final String? checkOutTime;
  final String? workDuration;
  final AttendanceData? data;

  GuardCheckOutModel({
    required this.status,
    this.type,
    required this.message,
    this.checkOutTime,
    this.workDuration,
    this.data,
  });

  factory GuardCheckOutModel.fromJson(Map<String, dynamic> json) {
    return GuardCheckOutModel(
      status: json['status'] ?? false,
      type: json['type'],
      message: json['message'] ?? 'Unknown error',
      checkOutTime: json['checkOutTime'],
      workDuration: json['workDuration'],
      data: json['data'] != null ? AttendanceData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'type': type,
      'message': message,
      'checkOutTime': checkOutTime,
      'workDuration': workDuration,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    return 'GuardCheckOutModel{status: $status, type: $type, message: $message}';
  }
}

class AttendanceData {
  final int? id;
  final String employeeId;
  final String empMobNo;
  final String? checkInTime;
  final String? checkOutTime;
  final String? workDuration;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkinImage;
  final String? checkoutimage;
  final String? empName;

  AttendanceData({
    this.id,
    required this.employeeId,
    required this.empMobNo,
    this.checkInTime,
    this.checkOutTime,
    this.workDuration,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkinImage,
    this.checkoutimage,
    this.empName,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['Id'],
      employeeId: json['EmployeeId'] ?? '',
      empMobNo: json['EmpMobNo'] ?? '',
      checkInTime: json['CheckInTime'],
      checkOutTime: json['CheckOutTime'],
      workDuration: json['WorkDuration'],
      checkInLocation: json['CheckInLocation'],
      checkOutLocation: json['CheckOutLocation'],
      checkinImage: json['CheckinImage'],
      checkoutimage: json['checkoutimage'],
      empName: json['Emp_Name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'EmployeeId': employeeId,
      'EmpMobNo': empMobNo,
      'CheckInTime': checkInTime,
      'CheckOutTime': checkOutTime,
      'WorkDuration': workDuration,
      'CheckInLocation': checkInLocation,
      'CheckOutLocation': checkOutLocation,
      'CheckinImage': checkinImage,
      'checkoutimage': checkoutimage,
      'Emp_Name': empName,
    };
  }
}
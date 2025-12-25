class GuardCheckInModel {
  final bool status;
  final String? type;
  final String? message;
  final String? checkInTime;
  final String? workDuration;
  final AttendanceData? data;

  GuardCheckInModel({
    required this.status,
    this.type,
    this.message,
    this.checkInTime,
    this.workDuration,
    this.data,
  });

  factory GuardCheckInModel.fromJson(Map<String, dynamic> json) {
    return GuardCheckInModel(
      status: json['status'] == true ||
          json['Status'] == true ||
          json['status'] == 'true',
      type: json['type']?.toString(),
      message: json['message']?.toString(),
      checkInTime: json['CheckInTime']?.toString(),
      workDuration: json['WorkDuration']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? AttendanceData.fromJson(json['data'])
          : null,
    );
  }
}

class AttendanceData {
  final String? employeeId;
  final String? empMobNo;
  final String? checkInTime;
  final String? checkInLocation;
  final String? checkInImage;

  AttendanceData({
    this.employeeId,
    this.empMobNo,
    this.checkInTime,
    this.checkInLocation,
    this.checkInImage,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      employeeId: json['EmployeeId']?.toString(),
      empMobNo: json['EmpMobNo']?.toString(),
      checkInTime: json['CheckInTime']?.toString(),
      checkInLocation: json['CheckInLocation']?.toString(),
      checkInImage: json['CheckInImage']?.toString(),
    );
  }
}

class AttendanceResponse {
  final bool status;
  final String message;
  final List<Attendance> records;

  AttendanceResponse({
    required this.status,
    required this.message,
    required this.records,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      records: (json['AttendanceList'] as List? ?? [])
          .map((e) => Attendance.fromJson(e))
          .toList(),
    );
  }
}

class Attendance {
  final int id;
  final String employeeId;
  final String employeeName;
  final String mobile;
  final String? workDuration;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInImage;
  final String? checkOutImage;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.mobile,
    required this.checkInTime,
    this.checkOutTime,
    this.workDuration,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInImage,
    this.checkOutImage,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['Id'],
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['Emp_Name'] ?? '',
      mobile: json['EmpMobNo'] ?? '',
      workDuration: json['WorkDuration'],
      checkInTime: DateTime.parse(json['CheckInTime']),
      checkOutTime: json['CheckOutTime'] != null
          ? DateTime.parse(json['CheckOutTime'])
          : null,
      checkInLocation: json['CheckInLocation'],
      checkOutLocation: json['CheckOutLocation'],
      checkInImage: json['CheckinImage'],
      checkOutImage: json['checkoutimage'],
    );
  }
}

class HrAttendanceInResponse {
  final bool status;
  final String message;
  final DateTime? checkInTime;
  final HrAttendanceData? data;

  HrAttendanceInResponse({
    required this.status,
    required this.message,
    this.checkInTime,
    this.data,
  });

  factory HrAttendanceInResponse.fromJson(Map<String, dynamic> json) {
    // Helper to parse date safely
    DateTime? parseTime(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    final dataObj = json['data'] != null
        ? HrAttendanceData.fromJson(json['data'])
        : null;

    // Try to find checkInTime in root or data
    final time = parseTime(json['checkInTime']) ??
        parseTime(json['CheckInTime']) ??
        dataObj?.checkInTime;

    return HrAttendanceInResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      checkInTime: time,
      data: dataObj,
    );
  }
}

class HrAttendanceData {
  final int id;
  final String employeeId;
  final String empMobNo;
  final DateTime checkInTime;
  final String checkInLocation;
  final String checkInImage;
  final String empName;

  HrAttendanceData({
    required this.id,
    required this.employeeId,
    required this.empMobNo,
    required this.checkInTime,
    required this.checkInLocation,
    required this.checkInImage,
    required this.empName,
  });

  factory HrAttendanceData.fromJson(Map<String, dynamic> json) {
    return HrAttendanceData(
      id: json['Id'] ?? 0,
      employeeId: json['EmployeeId'] ?? '',
      empMobNo: json['EmpMobNo'] ?? '',
      checkInTime: DateTime.parse(json['CheckInTime']),
      checkInLocation: json['CheckInLocation'] ?? '',
      checkInImage: json['CheckinImage'] ?? '',
      empName: json['Emp_Name'] ?? '',
    );
  }
}

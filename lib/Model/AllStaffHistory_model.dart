class AllStaffHistory {
  final String employeeId;
  final String employeeName;
  final String mobile;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInImage;
  final String? checkOutImage;
  final String? workDuration; // ⬅ NEW FIELD

  AllStaffHistory({
    required this.employeeId,
    required this.employeeName,
    required this.mobile,
    required this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInImage,
    this.checkOutImage,
    this.workDuration,
  });

  factory AllStaffHistory.fromJson(Map<String, dynamic> json) {
    return AllStaffHistory(
      employeeId: json['EmployeeId'] ?? '',
      employeeName: json['EmployeeName'] ?? '',
      mobile: json['Mobile'] ?? '',
      checkInTime: DateTime.parse(json['CheckInTime']),
      checkOutTime: json['CheckOutTime'] != null
          ? DateTime.parse(json['CheckOutTime'])
          : null,
      checkInLocation: json['CheckInLocation'],
      checkOutLocation: json['CheckOutLocation'],
      checkInImage: json['CheckInImage'],
      checkOutImage: json['CheckOutImage'],
      workDuration: json['WorkDuration'], // ⬅ ADDED
    );
  }
}

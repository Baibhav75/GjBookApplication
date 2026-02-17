class AgreementSchoolListModel {
  final bool status;
  final String message;
  final int total;
  final List<SchoolItem> data;

  AgreementSchoolListModel({
    required this.status,
    required this.message,
    required this.total,
    required this.data,
  });

  factory AgreementSchoolListModel.fromJson(Map<String, dynamic> json) {
    return AgreementSchoolListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      total: json['total'] ?? 0,
      data: json['data'] != null
          ? List<SchoolItem>.from(
          json['data'].map((e) => SchoolItem.fromJson(e)))
          : [],
    );
  }
}

class SchoolItem {
  final String schoolId;
  final String accName;

  SchoolItem({
    required this.schoolId,
    required this.accName,
  });

  factory SchoolItem.fromJson(Map<String, dynamic> json) {
    return SchoolItem(
      schoolId: json['SchoolId']?.toString() ?? '',
      accName: json['AccName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "SchoolId": schoolId,
      "AccName": accName,
    };
  }

  @override
  String toString() => accName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SchoolItem &&
              runtimeType == other.runtimeType &&
              schoolId == other.schoolId;

  @override
  int get hashCode => schoolId.hashCode;
}

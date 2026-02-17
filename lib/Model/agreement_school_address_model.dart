class AgreementSchoolAddressModel {
  final bool status;
  final String message;
  final SchoolAddressData? data;

  AgreementSchoolAddressModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory AgreementSchoolAddressModel.fromJson(Map<String, dynamic> json) {
    return AgreementSchoolAddressModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SchoolAddressData.fromJson(json['data'])
          : null,
    );
  }
}

class SchoolAddressData {
  final String schoolId;
  final String schoolName;
  final String address;
  final String district;
  final String block;
  final String area;

  SchoolAddressData({
    required this.schoolId,
    required this.schoolName,
    required this.address,
    required this.district,
    required this.block,
    required this.area,
  });

  factory SchoolAddressData.fromJson(Map<String, dynamic> json) {
    return SchoolAddressData(
      schoolId: json['SchoolId'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      address: json['Address'] ?? '',
      district: json['District'] ?? '',
      block: json['Block'] ?? '',
      area: json['Area'] ?? '',
    );
  }
}

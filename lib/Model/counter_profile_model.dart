class CounterProfileModel {
  final bool status;
  final String message;
  final CounterProfileData? data;

  CounterProfileModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CounterProfileModel.fromJson(Map<String, dynamic> json) {
    return CounterProfileModel(
      status: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CounterProfileData.fromJson(json['data'])
          : null,
    );
  }
}

class CounterProfileData {
  final String counterId;
  final String counterName;
  final String counterBoyName;
  final String schoolName;
  final String fatherName;
  final String motherName;
  final String mobile;
  final String cashLimit;

  // Documents
  final String agreement;
  final String cancelCheck;
  final String counterBoyMarkSheet;
  final String counterBoyAdharCard;
  final String fatherAdhar;
  final String motherAdhar;

  CounterProfileData({
    required this.counterId,
    required this.counterName,
    required this.counterBoyName,
    required this.schoolName,
    required this.fatherName,
    required this.motherName,
    required this.mobile,
    required this.cashLimit,
    required this.agreement,
    required this.cancelCheck,
    required this.counterBoyMarkSheet,
    required this.counterBoyAdharCard,
    required this.fatherAdhar,
    required this.motherAdhar,
  });

  factory CounterProfileData.fromJson(Map<String, dynamic> json) {
    return CounterProfileData(
      counterId: json['CounterId'] ?? '',
      counterName: json['CounterName'] ?? '',
      counterBoyName: json['CounterBoyName'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      fatherName: json['FatherName'] ?? '',
      motherName: json['MotherName'] ?? '',
      mobile: json['Mobile'] ?? '',
      cashLimit: json['CashLimit'] ?? '',
      agreement: json['Agreement'] ?? '',
      cancelCheck: json['CancelCheck'] ?? '',
      counterBoyMarkSheet: json['CounterBoyMarkSheet'] ?? '',
      counterBoyAdharCard: json['CounterBoyAdharCard'] ?? '',
      fatherAdhar: json['FatherAdhar'] ?? '',
      motherAdhar: json['MotherAdhar'] ?? '',
    );
  }
}

class LoginModel {
  String? status;
  String? message;
  String? adminName;
  String? adminEmail;
  String? mobileNo;

  LoginModel({
    this.status,
    this.message,
    this.adminName,
    this.adminEmail,
    this.mobileNo,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['Status']?.toString(),
      message: json['Message']?.toString(),
      adminName: json['AdminName']?.toString(),
      adminEmail: json['AdminEmail']?.toString(),
      mobileNo: json['MobileNo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Message': message,
      'AdminName': adminName,
      'AdminEmail': adminEmail,
      'MobileNo': mobileNo,
    };
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
}
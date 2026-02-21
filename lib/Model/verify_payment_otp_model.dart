class VerifyPaymentOtpModel {
  String? status;
  String? message;
  PaymentData? data;

  VerifyPaymentOtpModel({this.status, this.message, this.data});

  VerifyPaymentOtpModel.fromJson(Map<String, dynamic> json) {
    status = json['Status']?.toString();
    message = json['Message']?.toString();
    data = json['Data'] != null
        ? PaymentData.fromJson(json['Data'])
        : null;
  }
}

class PaymentData {
  int? id;
  String? schoolName;
  String? schoolId;
  double? amount;
  String? recivedByFromSchool;
  String? reciverEmpId;
  String? payMentDate;
  String? status;
  String? schoolAddress;
  String? paymentmode;

  PaymentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    schoolName = json['SchoolName'];
    schoolId = json['SchoolId'];
    amount = double.tryParse(json['Amount'].toString());
    recivedByFromSchool = json['RecivedByFromSchool'];
    reciverEmpId = json['ReciverEmpId'];
    payMentDate = json['PayMentDate'];
    status = json['Status'];
    schoolAddress = json['SchoolAddress'];
    paymentmode = json['Paymentmode'];
  }
}
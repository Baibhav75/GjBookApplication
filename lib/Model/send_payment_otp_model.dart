class SendPaymentOtpModel {
  String? schoolId;
  int? amount;

  SendPaymentOtpModel({this.schoolId, this.amount});
  
  String? status;
  String? message;

  SendPaymentOtpModel.fromResponse(Map<String, dynamic> json) {
    status = (json['Status'] ?? json['status'])?.toString();
    message = (json['Message'] ?? json['message'])?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      "SchoolId": schoolId,
      "Amount": amount,
    };
  }
}
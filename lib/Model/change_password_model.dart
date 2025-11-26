class ChangePasswordModel {
  String? status;
  String? message;

  ChangePasswordModel({this.status, this.message});

  factory ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordModel(
      status: json['Status']?.toString(),
      message: json['Message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status'] = status;
    data['Message'] = message;
    return data;
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
}



















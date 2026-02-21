class RecoverCollectAmountModel {
  String? status;
  DueData? data;

  RecoverCollectAmountModel({this.status, this.data});

  RecoverCollectAmountModel.fromJson(Map<String, dynamic> json) {
    status = (json['status'] ?? json['Status'])?.toString();
    data = (json['data'] ?? json['Data']) != null
        ? DueData.fromJson(json['data'] ?? json['Data'])
        : null;
  }
}

class DueData {
  String? schoolId;
  String? schoolName;
  int? totalSale;
  int? totalReturn;
  int? totalPayment;
  int? dueAmount;

  DueData({
    this.schoolId,
    this.schoolName,
    this.totalSale,
    this.totalReturn,
    this.totalPayment,
    this.dueAmount,
  });

  DueData.fromJson(Map<String, dynamic> json) {
    schoolId = (json['SchoolId'] ?? json['schoolId'])?.toString();
    schoolName = (json['SchoolName'] ?? json['schoolName'])?.toString();
    
    totalSale = _parseInt(json['TotalSale'] ?? json['totalSale']);
    totalReturn = _parseInt(json['TotalReturn'] ?? json['totalReturn']);
    totalPayment = _parseInt(json['TotalPayment'] ?? json['totalPayment']);
    dueAmount = _parseInt(json['DueAmount'] ?? json['dueAmount']);
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return double.tryParse(value.toString())?.toInt() ?? 0;
  }
}
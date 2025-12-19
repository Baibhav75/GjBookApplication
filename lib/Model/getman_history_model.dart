class GetManHistoryModel {
  final bool status;
  final String message;
  final List<GetManHistoryData> data;

  GetManHistoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetManHistoryModel.fromJson(Map<String, dynamic> json) {
    return GetManHistoryModel(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      data: json['Data'] != null
          ? List<GetManHistoryData>.from(
        json['Data'].map((x) => GetManHistoryData.fromJson(x)),
      )
          : [],
    );
  }
}

class GetManHistoryData {
  final String? name;
  final String? information;
  final String? itemType;
  final String? itemName;
  final String? qty;
  final String? rate;
  final double amount;
  final String? remarks;
  final String createDate;
  final String image;

  GetManHistoryData({
    this.name,
    this.information,
    this.itemType,
    this.itemName,
    this.qty,
    this.rate,
    required this.amount,
    this.remarks,
    required this.createDate,
    required this.image,
  });

  factory GetManHistoryData.fromJson(Map<String, dynamic> json) {
    return GetManHistoryData(
      name: json['Name'],
      information: json['Information'],
      itemType: json['ItemType'],
      itemName: json['ItemName'],
      qty: json['QTY'],
      rate: json['Rate'],
      amount: (json['Amount'] ?? 0).toDouble(),
      remarks: json['Remarks'],
      createDate: json['CreateDate'] ?? '',
      image: json['Image'] ?? '',
    );
  }
}

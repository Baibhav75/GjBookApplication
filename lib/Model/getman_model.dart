class GetManModel {
  final bool status;
  final String message;
  final GetManData? data;

  GetManModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory GetManModel.fromJson(Map<String, dynamic> json) {
    return GetManModel(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      data: json['Data'] != null
          ? GetManData.fromJson(json['Data'])
          : null,
    );
  }
}

class GetManData {
  final int id;
  final String name;
  final String information;
  final String itemType;
  final String itemName;
  final String qty;
  final String rate;
  final double amount;
  final String remarks;
  final String createDate;
  final String image;

  GetManData({
    required this.id,
    required this.name,
    required this.information,
    required this.itemType,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.remarks,
    required this.createDate,
    required this.image,
  });

  factory GetManData.fromJson(Map<String, dynamic> json) {
    return GetManData(
      id: json['id'],
      name: json['Name'] ?? '',
      information: json['Information'] ?? '',
      itemType: json['ItemType'] ?? '',
      itemName: json['ItemName'] ?? '',
      qty: json['QTY'] ?? '',
      rate: json['Rate'] ?? '',
      amount: (json['Amount'] as num).toDouble(),
      remarks: json['Remarks'] ?? '',
      createDate: json['CreateDate'] ?? '',
      image: json['Image'] ?? '',
    );
  }
}

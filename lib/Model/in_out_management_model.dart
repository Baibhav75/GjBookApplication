class InOutManagementModel {
  final String? name;
  final String? itemType;
  final String? information;
  final String? itemName;
  final String? remarks;
  final String? qty;
  final String? rate;
  final double? amount;
  final DateTime? createDate;
  final String? image;

  InOutManagementModel({
    this.name,
    this.itemType,
    this.information,
    this.itemName,
    this.remarks,
    this.qty,
    this.rate,
    this.amount,
    this.createDate,
    this.image,
  });

  factory InOutManagementModel.fromJson(Map<String, dynamic> json) {
    return InOutManagementModel(
      name: json['Name'],
      itemType: json['ItemType'],
      information: json['Information'],
      itemName: json['ItemName'],
      remarks: json['Remarks'],
      qty: json['QTY']?.toString(),
      rate: json['Rate']?.toString(),
      amount: json['Amount'] != null
          ? double.tryParse(json['Amount'].toString())
          : null,
      createDate: json['CreateDate'] != null
          ? DateTime.tryParse(json['CreateDate'])
          : null,
      image: json['Image'],
    );
  }
}

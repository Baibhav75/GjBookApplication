class DayBookModel {
  final int? id;
  final String? particularName;
  final String? type;
  final double? amount;
  final double? totalBalance;
  final String? createdAt;
  final double? openingBalance;
  final String? expenseVoucherNo;
  final String? receiptVoucherNo;
  final String? remark;
  final String? mobileNo;
  final String? remarks;
  final String? image;
  final String? director;
  final String? transfer;

  DayBookModel({
    this.id,
    this.particularName,
    this.type,
    this.amount,
    this.totalBalance,
    this.createdAt,
    this.openingBalance,
    this.expenseVoucherNo,
    this.receiptVoucherNo,
    this.remark,
    this.mobileNo,
    this.remarks,
    this.image,
    this.director,
    this.transfer,
  });

  // ---------------- SEND TO API ----------------
  Map<String, dynamic> toJson() {
    return {
      "ParicularName": particularName,
      "Flag": type,
      "Amount": amount,
      "MobileNo": mobileNo,
      "ExpenceBowcherNo": expenseVoucherNo,
      "ReceiptBowcherNo": receiptVoucherNo,
      "Remarks": remarks,
      "image": image,
      // The following are usually calculated by backend but included for completeness
      "TotalBalance": totalBalance,
      "OpeningBalance": openingBalance,
      "Remark": remark,
      "Director": director,
      "Transfer": transfer,
    };
  }

  // ---------------- RECEIVE FROM API ----------------
  factory DayBookModel.fromJson(Map<String, dynamic> json) {
    return DayBookModel(
      id: json["id"],
      particularName: json["ParicularName"],
      type: json["Flag"],
      amount: json["Amount"] != null ? (json["Amount"] as num).toDouble() : null,
      totalBalance: json["TotalBalance"] != null ? (json["TotalBalance"] as num).toDouble() : null,
      createdAt: json["Createdatetime"],
      openingBalance: json["OpeningBalance"] != null ? (json["OpeningBalance"] as num).toDouble() : null,
      expenseVoucherNo: json["ExpenceBowcherNo"],
      receiptVoucherNo: json["ReceiptBowcherNo"],
      remark: json["Remark"],
      mobileNo: json["MobileNo"],
      remarks: json["Remarks"],
      image: json["image"],
      director: json["Director"],
      transfer: json["Transfer"],
    );
  }

  DayBookModel copyWith({
    int? id,
    String? particularName,
    String? type,
    double? amount,
    double? totalBalance,
    String? createdAt,
    double? openingBalance,
    String? expenseVoucherNo,
    String? receiptVoucherNo,
    String? remark,
    String? mobileNo,
    String? remarks,
    String? image,
    String? director,
    String? transfer,
  }) {
    return DayBookModel(
      id: id ?? this.id,
      particularName: particularName ?? this.particularName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      totalBalance: totalBalance ?? this.totalBalance,
      createdAt: createdAt ?? this.createdAt,
      openingBalance: openingBalance ?? this.openingBalance,
      expenseVoucherNo: expenseVoucherNo ?? this.expenseVoucherNo,
      receiptVoucherNo: receiptVoucherNo ?? this.receiptVoucherNo,
      remark: remark ?? this.remark,
      mobileNo: mobileNo ?? this.mobileNo,
      remarks: remarks ?? this.remarks,
      image: image ?? this.image,
      director: director ?? this.director,
      transfer: transfer ?? this.transfer,
    );
  }
}



// models/day_book_model.dart
class DayBookModel {
  final String? id;
  final String company;
  final String? crdr;
  final String amount;
  final String? expenseNo;
  final String? receiptNo;
  final String? mobile;
  final String? remark;
  final String? filePath;
  final DateTime? createdAt;

  DayBookModel({
    this.id,
    required this.company,
    this.crdr,
    required this.amount,
    this.expenseNo,
    this.receiptNo,
    this.mobile,
    this.remark,
    this.filePath,
    this.createdAt,
  });

  // Convert to JSON for API - match your API expected fields
  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'crdr': crdr,
      'amount': amount,
      'expense_no': expenseNo,
      'receipt_no': receiptNo,
      'mobile': mobile,
      'remark': remark,
      'file_path': filePath,
      // Add any other fields your API expects
      'created_date': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from JSON
  factory DayBookModel.fromJson(Map<String, dynamic> json) {
    return DayBookModel(
      id: json['id']?.toString(),
      company: json['company'] ?? '',
      crdr: json['crdr'],
      amount: json['amount']?.toString() ?? '0',
      expenseNo: json['expense_no'],
      receiptNo: json['receipt_no'],
      mobile: json['mobile'],
      remark: json['remark'],
      filePath: json['file_path'],
      createdAt: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
    );
  }

  DayBookModel copyWith({
    String? company,
    String? crdr,
    String? amount,
    String? expenseNo,
    String? receiptNo,
    String? mobile,
    String? remark,
    String? filePath,
  }) {
    return DayBookModel(
      id: id,
      company: company ?? this.company,
      crdr: crdr ?? this.crdr,
      amount: amount ?? this.amount,
      expenseNo: expenseNo ?? this.expenseNo,
      receiptNo: receiptNo ?? this.receiptNo,
      mobile: mobile ?? this.mobile,
      remark: remark ?? this.remark,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt,
    );
  }
}
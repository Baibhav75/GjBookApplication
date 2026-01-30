// viewbooklist_model.dart

class BookSummaryResponse {
  final bool status;
  final String message;
  final String billNo;
  final String schoolName;
  final List<ClassData> data;

  BookSummaryResponse({
    required this.status,
    required this.message,
    required this.billNo,
    required this.schoolName,
    required this.data,
  });

  factory BookSummaryResponse.fromJson(Map<String, dynamic> json) {
    return BookSummaryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      billNo: json['BillNo']?.toString() ?? '',
      schoolName: json['SchoolName'] ?? '',
      data: (json['Data'] as List? ?? [])
          .map((item) => ClassData.fromJson(item))
          .toList(),
    );
  }
}

class ClassData {
  final String className;
  final List<BookItem> items;
  final double classTotalQty;
  final double classTotalRate;
  final double classTotalAmount;

  ClassData({
    required this.className,
    required this.items,
    required this.classTotalQty,
    required this.classTotalRate,
    required this.classTotalAmount,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      className: json['ClassName']?.toString() ?? '',
      items: (json['Items'] as List? ?? [])
          .map((item) => BookItem.fromJson(item))
          .toList(),
      classTotalQty: _toDouble(json['ClassTotalQty']),
      classTotalRate: _toDouble(json['ClassTotalRate']),
      classTotalAmount: _toDouble(json['ClassTotalAmount']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class BookItem {
  final String publication;
  final String series;
  final String bookName;
  final String subject;
  final double totalQty;
  final double rate;
  final double totalAmount;

  BookItem({
    required this.publication,
    required this.series,
    required this.bookName,
    required this.subject,
    required this.totalQty,
    required this.rate,
    required this.totalAmount,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      publication: json['Publication'] ?? '',
      series: json['Series'] ?? '',
      bookName: json['BookName'] ?? '',
      subject: json['Subject'] ?? '',
      totalQty: _toDouble(json['TotalQty']),
      rate: _toDouble(json['Rate']),
      totalAmount: _toDouble(json['TotalAmount']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
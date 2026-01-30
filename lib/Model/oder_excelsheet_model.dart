class OrderExcelSheetModel {
  final bool status;
  final String message;
  final String billNo;
  final String schoolName;
  final List<ClassWiseData> data;

  OrderExcelSheetModel({
    required this.status,
    required this.message,
    required this.billNo,
    required this.schoolName,
    required this.data,
  });

  factory OrderExcelSheetModel.fromJson(Map<String, dynamic> json) {
    return OrderExcelSheetModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      billNo: json['BillNo']?.toString() ?? '',
      schoolName: json['SchoolName']?.toString() ?? '',
      data: (json['Data'] as List? ?? [])
          .map((e) => ClassWiseData.fromJson(e))
          .toList(),
    );
  }
}

// =====================================================

class ClassWiseData {
  final String className;
  final List<BookItem> items;
  final int classTotalQty;
  final double classTotalRate;
  final double classTotalAmount;

  ClassWiseData({
    required this.className,
    required this.items,
    required this.classTotalQty,
    required this.classTotalRate,
    required this.classTotalAmount,
  });

  factory ClassWiseData.fromJson(Map<String, dynamic> json) {
    return ClassWiseData(
      className: json['ClassName']?.toString() ?? '',
      items: (json['Items'] as List? ?? [])
          .map((e) => BookItem.fromJson(e))
          .toList(),
      classTotalQty: (json['ClassTotalQty'] as num?)?.toInt() ?? 0,
      classTotalRate: (json['ClassTotalRate'] as num?)?.toDouble() ?? 0.0,
      classTotalAmount: (json['ClassTotalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// =====================================================

class BookItem {
  final String publication;
  final String series;
  final String bookName;
  final String subject;
  final int totalQty;
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
      publication: json['Publication']?.toString() ?? '',
      series: json['Series']?.toString() ?? '',
      bookName: json['BookName']?.toString() ?? '',
      subject: json['Subject']?.toString() ?? '',
      totalQty: (json['TotalQty'] as num?)?.toInt() ?? 0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

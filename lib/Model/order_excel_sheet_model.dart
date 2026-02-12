class OrderExcelSheet {
  final String billNo;
  final String schoolName;
  final DateTime dates;
  final DateTime recDate;

  OrderExcelSheet({
    required this.billNo,
    required this.schoolName,
    required this.dates,
    required this.recDate,
  });

  factory OrderExcelSheet.fromJson(Map<String, dynamic> json) {
    return OrderExcelSheet(
      billNo: json['BillNo'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      dates: DateTime.parse(json['Dates']),
      recDate: DateTime.parse(json['RecDate']),
    );
  }
}

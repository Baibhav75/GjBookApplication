class BillNoInvoiceModel {
  final bool status;
  final String message;
  final InvoiceData data;

  BillNoInvoiceModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BillNoInvoiceModel.fromJson(Map<String, dynamic> json) {
    return BillNoInvoiceModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: InvoiceData.fromJson(json['data'] ?? {}),
    );
  }
}

/* ================= DATA ================= */

class InvoiceData {
  final InvoiceHeader header;
  final List<Publication> publications;
  final InvoiceSummary summary;

  InvoiceData({
    required this.header,
    required this.publications,
    required this.summary,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      header: InvoiceHeader.fromJson(json['Header'] ?? {}),
      publications: (json['Publications'] as List?)
              ?.map((e) => Publication.fromJson(e))
              .toList() ??
          [],
      summary: InvoiceSummary.fromJson(json['Summary'] ?? {}),
    );
  }
}

/* ================= HEADER ================= */

class InvoiceHeader {
  final String invoiceNo;
  final DateTime billDate;
  final String schoolName;
  final String address;
  final String transport;
  final String? board;
  final String? remark;

  InvoiceHeader({
    required this.invoiceNo,
    required this.billDate,
    required this.schoolName,
    required this.address,
    required this.transport,
    this.board,
    this.remark,
  });

  factory InvoiceHeader.fromJson(Map<String, dynamic> json) {
    return InvoiceHeader(
      invoiceNo: json['InvoiceNo']?.toString() ?? '',
      billDate: json['BillDate'] != null
          ? DateTime.tryParse(json['BillDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      schoolName: json['SchoolName'] ?? '',
      address: json['Address'] ?? '',
      transport: json['Transport'] ?? '',
      board: json['Board'],
      remark: json['Remark'],
    );
  }
}

/* ================= PUBLICATION ================= */

class Publication {
  final String publicationName;
  final String series;
  final List<BookItem> items;
  final int totalQty;
  final double subTotal;

  Publication({
    required this.publicationName,
    required this.series,
    required this.items,
    required this.totalQty,
    required this.subTotal,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      publicationName: json['PublicationName'] ?? '',
      series: json['Series'] ?? '',
      items: (json['Items'] as List?)
              ?.map((e) => BookItem.fromJson(e))
              .toList() ??
          [],
      totalQty: json['TotalQty'] ?? 0,
      subTotal: (json['SubTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/* ================= ITEMS ================= */

class BookItem {
  final String bookName;
  final String subject;
  final String className;
  final int qty;
  final double rate;
  final double amount;

  BookItem({
    required this.bookName,
    required this.subject,
    required this.className,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      bookName: json['BookName'] ?? '',
      subject: json['Subject'] ?? '',
      className: json['Class'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/* ================= SUMMARY ================= */

class InvoiceSummary {
  final int grandQty;
  final double grandTotal;

  InvoiceSummary({
    required this.grandQty,
    required this.grandTotal,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      grandQty: json['GrandQty'] ?? 0,
      grandTotal: (json['GrandTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

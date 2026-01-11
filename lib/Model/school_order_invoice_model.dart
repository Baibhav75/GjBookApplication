class SchoolOrderInvoiceResponse {
  final bool status;
  final String message;
  final SchoolOrderInvoiceData data;

  SchoolOrderInvoiceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SchoolOrderInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return SchoolOrderInvoiceResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: SchoolOrderInvoiceData.fromJson(json['data'] ?? {}),
    );
  }
}

// --------------------------------------------------

class SchoolOrderInvoiceData {
  final InvoiceHeader header;
  final List<Publication> publications;
  final InvoiceSummary summary;

  SchoolOrderInvoiceData({
    required this.header,
    required this.publications,
    required this.summary,
  });

  factory SchoolOrderInvoiceData.fromJson(Map<String, dynamic> json) {
    return SchoolOrderInvoiceData(
      header: InvoiceHeader.fromJson(json['Header'] ?? {}),
      publications: (json['Publications'] as List? ?? [])
          .map((e) => Publication.fromJson(e))
          .toList(),
      summary: InvoiceSummary.fromJson(json['Summary'] ?? {}),
    );
  }
}

// --------------------------------------------------

class InvoiceHeader {
  final String schoolName;
  final String ownerName;
  final String ownerMobile;
  final String address;
  final String district;
  final String state;
  final DateTime billDate;
  final DateTime recDate;

  InvoiceHeader({
    required this.schoolName,
    required this.ownerName,
    required this.ownerMobile,
    required this.address,
    required this.district,
    required this.state,
    required this.billDate,
    required this.recDate,
  });

  factory InvoiceHeader.fromJson(Map<String, dynamic> json) {
    return InvoiceHeader(
      schoolName: json['SchoolName'] ?? '',
      ownerName: json['OwnerName'] ?? '',
      ownerMobile: json['OwnerMobile'] ?? '',
      address: json['Address'] ?? '',
      district: json['District'] ?? '',
      state: json['State'] ?? '',
      billDate: DateTime.tryParse(json['BillDate'] ?? '') ?? DateTime.now(),
      recDate: DateTime.tryParse(json['RecDate'] ?? '') ?? DateTime.now(),
    );
  }
}

// --------------------------------------------------

class Publication {
  final String publicationName;
  final String series;
  final List<InvoiceItem> items;
  final int totalQty;
  final num subTotal;

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
      items: (json['Items'] as List? ?? [])
          .map((e) => InvoiceItem.fromJson(e))
          .toList(),
      totalQty: json['TotalQty'] ?? 0,
      subTotal: json['SubTotal'] ?? 0,
    );
  }
}

// --------------------------------------------------

class InvoiceItem {
  final String bookName;
  final String subject;
  final String className;
  final int qty;
  final num rate;
  final num amount;

  InvoiceItem({
    required this.bookName,
    required this.subject,
    required this.className,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      bookName: json['BookName'] ?? '',
      subject: json['Subject'] ?? '',
      className: json['Class'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: json['Rate'] ?? 0,
      amount: json['Amount'] ?? 0,
    );
  }
}

// --------------------------------------------------

class InvoiceSummary {
  final int grandQty;
  final num grandTotal;

  InvoiceSummary({
    required this.grandQty,
    required this.grandTotal,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      grandQty: json['GrandQty'] ?? 0,
      grandTotal: json['GrandTotal'] ?? 0,
    );
  }
}

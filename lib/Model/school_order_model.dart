class OrderFormInvoice {
  final bool status;
  final String message;
  final OrderFormInvoiceData data;

  OrderFormInvoice({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderFormInvoice.fromJson(Map<String, dynamic> json) {
    return OrderFormInvoice(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: OrderFormInvoiceData.fromJson(json['data'] ?? {}),
    );
  }
}

class OrderFormInvoiceData {
  final Header header;
  final List<Publication> publications;
  final Summary summary;

  OrderFormInvoiceData({
    required this.header,
    required this.publications,
    required this.summary,
  });

  factory OrderFormInvoiceData.fromJson(Map<String, dynamic> json) {
    return OrderFormInvoiceData(
      header: Header.fromJson(json['Header'] ?? {}),
      publications: (json['Publications'] as List? ?? [])
          .map((e) => Publication.fromJson(e))
          .toList(),
      summary: Summary.fromJson(json['Summary'] ?? {}),
    );
  }
}

class Header {
  final String invoiceNo;
  final DateTime billDate;
  final String schoolName;
  final String address;
  final String transport;
  final String? board;
  final String? remark;

  Header({
    required this.invoiceNo,
    required this.billDate,
    required this.schoolName,
    required this.address,
    required this.transport,
    this.board,
    this.remark,
  });

  factory Header.fromJson(Map<String, dynamic> json) {
    return Header(
      invoiceNo: json['InvoiceNo']?.toString() ?? '',
      billDate: DateTime.parse(json['BillDate'] ?? DateTime.now().toString()),
      schoolName: json['SchoolName'] ?? '',
      address: json['Address'] ?? '',
      transport: json['Transport'] ?? '',
      board: json['Board'],
      remark: json['Remark'],
    );
  }
}

class Publication {
  final String publicationName;
  final String series;
  final List<Item> items;
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
      items: (json['Items'] as List? ?? [])
          .map((e) => Item.fromJson(e))
          .toList(),
      totalQty: json['TotalQty'] ?? 0,
      subTotal: (json['SubTotal'] ?? 0).toDouble(),
    );
  }
}

class Item {
  final String bookName;
  final String subject;
  final String className;
  final int qty;
  final double rate;
  final double amount;

  Item({
    required this.bookName,
    required this.subject,
    required this.className,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      bookName: json['BookName'] ?? '',
      subject: json['Subject'] ?? '',
      className: json['Class'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: (json['Rate'] ?? 0).toDouble(),
      amount: (json['Amount'] ?? 0).toDouble(),
    );
  }
}

class Summary {
  final int grandQty;
  final double grandTotal;

  Summary({
    required this.grandQty,
    required this.grandTotal,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      grandQty: json['GrandQty'] ?? 0,
      grandTotal: (json['GrandTotal'] ?? 0).toDouble(),
    );
  }
}
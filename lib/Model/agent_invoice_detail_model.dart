class AgentInvoiceDetailResponse {
  final bool status;
  final String message;
  final InvoiceData data;

  AgentInvoiceDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AgentInvoiceDetailResponse.fromJson(Map<String, dynamic> json) {
    return AgentInvoiceDetailResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: InvoiceData.fromJson(json['data'] ?? {}),
    );
  }
}

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
      publications: (json['Publications'] as List? ?? [])
          .map((e) => Publication.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: InvoiceSummary.fromJson(json['Summary'] ?? {}),
    );
  }
}

class InvoiceHeader {
  final String invoiceNo;
  final DateTime billDate;
  final String partyName;
  final String address;
  final String transport;
  final String agentName;

  InvoiceHeader({
    required this.invoiceNo,
    required this.billDate,
    required this.partyName,
    required this.address,
    required this.transport,
    required this.agentName,
  });

  factory InvoiceHeader.fromJson(Map<String, dynamic> json) {
    return InvoiceHeader(
      invoiceNo: json['InvoiceNo'] ?? '',
      billDate: json['BillDate'] != null
          ? DateTime.parse(json['BillDate'])
          : DateTime.now(),
      partyName: json['PartyName'] ?? '',
      address: json['Address'] ?? '',
      transport: json['Transport'] ?? '',
      agentName: json['AgentName'] ?? '',
    );
  }
}

class Publication {
  final String publicationName;
  final String series;
  final List<InvoiceItem> items;
  final double subTotal;
  final double commissionPercent;
  final double commissionAmount;

  Publication({
    required this.publicationName,
    required this.series,
    required this.items,
    required this.subTotal,
    required this.commissionPercent,
    required this.commissionAmount,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      publicationName: json['PublicationName'] ?? '',
      series: json['Series'] ?? '',
      items: (json['Items'] as List? ?? [])
          .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subTotal: (json['SubTotal'] as num? ?? 0).toDouble(),
      commissionPercent:
          (json['AgentCommissionPercent'] as num? ?? 0).toDouble(),
      commissionAmount:
          (json['AgentCommissionAmount'] as num? ?? 0).toDouble(),
    );
  }
}

class InvoiceItem {
  final String bookName;
  final String subject;
  final String className;
  final int qty;
  final double rate;
  final double amount;

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
      rate: (json['Rate'] as num? ?? 0).toDouble(),
      amount: (json['Amount'] as num? ?? 0).toDouble(),
    );
  }
}

class InvoiceSummary {
  final double grandTotal;
  final double totalCommission;

  InvoiceSummary({
    required this.grandTotal,
    required this.totalCommission,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      grandTotal: (json['GrandTotal'] as num? ?? 0).toDouble(),
      totalCommission: (json['TotalAgentCommission'] as num? ?? 0).toDouble(),
    );
  }
}

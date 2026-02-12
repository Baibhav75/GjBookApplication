class PublicationLedgerResponse {
  final String publicationId;
  final String publicationName;
  final String address;
  final double totalCredit;
  final double totalDebit;
  final double closingBalance;
  final List<PublicationLedgerItem> ledger;

  PublicationLedgerResponse({
    required this.publicationId,
    required this.publicationName,
    required this.address,
    required this.totalCredit,
    required this.totalDebit,
    required this.closingBalance,
    required this.ledger,
  });

  factory PublicationLedgerResponse.fromJson(Map<String, dynamic> json) {
    return PublicationLedgerResponse(
      publicationId: json['PublicationId'] ?? '',
      publicationName: json['PublicationName'] ?? '',
      address: json['Address'] ?? '',
      totalCredit:
      double.parse(json['TotalCredit'].toString().replaceAll(',', '')),
      totalDebit:
      double.parse(json['TotalDebit'].toString().replaceAll(',', '')),
      closingBalance:
      double.parse(json['ClosingBalance'].toString().replaceAll(',', '')),
      ledger: (json['Ledger'] as List)
          .map((e) => PublicationLedgerItem.fromJson(e))
          .toList(),
    );
  }
}

class PublicationLedgerItem {
  final DateTime date;
  final String orderNo;
  final String senderId;
  final String orderDate;
  final double debit;
  final double credit;

  PublicationLedgerItem({
    required this.date,
    required this.orderNo,
    required this.senderId,
    required this.orderDate,
    required this.debit,
    required this.credit,
  });

  factory PublicationLedgerItem.fromJson(Map<String, dynamic> json) {
    return PublicationLedgerItem(
      date: DateTime.parse(json['Date']),
      orderNo: json['OrderNo'] ?? '',
      senderId: json['SenderId'] ?? '',
      orderDate: json['OrderDate'] ?? '',
      debit: (json['Debit'] as num).toDouble(),
      credit: (json['Credit'] as num).toDouble(),
    );
  }
}

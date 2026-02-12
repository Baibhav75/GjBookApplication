class PublicationOrderManagementResponse {
  final double totalPurchase; // ✅ FIX: int → double
  final List<PublicationOrderRecord> records;

  PublicationOrderManagementResponse({
    required this.totalPurchase,
    required this.records,
  });

  factory PublicationOrderManagementResponse.fromJson(
      Map<String, dynamic> json) {
    return PublicationOrderManagementResponse(
      totalPurchase: (json['TotalPurchase'] as num).toDouble(),
      records: (json['Records'] as List)
          .map((e) => PublicationOrderRecord.fromJson(e))
          .toList(),
    );
  }
}

class PublicationOrderRecord {
  final String orderNo;
  final String publicationName;
  final String senderId;
  final DateTime date;
  final String publicationId;

  PublicationOrderRecord({
    required this.orderNo,
    required this.publicationName,
    required this.senderId,
    required this.date,
    required this.publicationId,
  });

  factory PublicationOrderRecord.fromJson(Map<String, dynamic> json) {
    return PublicationOrderRecord(
      orderNo: json['OrderNo'] ?? '',
      publicationName: json['PublicationName'] ?? '',
      senderId: json['SenderId'] ?? '',
      date: DateTime.parse(json['Dates']), // ✅ this format is OK
      publicationId: json['PublicationId'] ?? '',
    );
  }
}

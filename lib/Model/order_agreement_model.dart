class OrderAgreementResponse {
  final String status;
  final String message;
  final List<OrderAgreement> data;

  OrderAgreementResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderAgreementResponse.fromJson(Map<String, dynamic> json) {
    return OrderAgreementResponse(
      status: json['Status'],
      message: json['Message'],
      data: List<OrderAgreement>.from(
        json['Data'].map((x) => OrderAgreement.fromJson(x)),
      ),
    );
  }
}

class OrderAgreement {
  final int id;
  final DateTime createDate;
  final String partyName;
  final String address;

  OrderAgreement({
    required this.id,
    required this.createDate,
    required this.partyName,
    required this.address,
  });

  factory OrderAgreement.fromJson(Map<String, dynamic> json) {
    return OrderAgreement(
      id: json['id'],
      createDate: DateTime.parse(json['CreateDate']),
      partyName: json['PartyName'],
      address: json['Address'],
    );
  }
}

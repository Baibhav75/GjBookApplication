class OrderLetterPadResponse {
  final bool status;
  final String message;
  final List<OrderLetterPad> data;

  OrderLetterPadResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderLetterPadResponse.fromJson(Map<String, dynamic> json) {
    return OrderLetterPadResponse(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      data: (json['Data'] as List<dynamic>? ?? [])
          .map((e) => OrderLetterPad.fromJson(e))
          .toList(),
    );
  }
}

class OrderLetterPad {
  final int id;
  final String schoolName;
  final String address;
  final DateTime? createDate;   // ✅ Nullable
  final String image;
  final String type;
  final DateTime? orderDate;    // ✅ Nullable

  OrderLetterPad({
    required this.id,
    required this.schoolName,
    required this.address,
    required this.createDate,
    required this.image,
    required this.type,
    required this.orderDate,
  });

  factory OrderLetterPad.fromJson(Map<String, dynamic> json) {
    return OrderLetterPad(
      id: json['id'] ?? 0,
      schoolName: json['SchoolName'] ?? '',
      address: json['Address'] ?? '',

      // ✅ SAFE DATE PARSING
      createDate: DateTime.tryParse(
          json['CreateDate']?.toString() ?? ''
      ),

      orderDate: DateTime.tryParse(
          json['OrderDate']?.toString() ?? ''
      ),

      image: json['Image'] ?? '',
      type: json['Type'] ?? '',
    );
  }
}

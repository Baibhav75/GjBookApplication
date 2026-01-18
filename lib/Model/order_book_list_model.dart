class OrderBookListModel {
  final bool status;
  final String message;
  final List<OrderBookItem> books;

  OrderBookListModel({
    required this.status,
    required this.message,
    required this.books,
  });

  factory OrderBookListModel.fromJson(Map<String, dynamic> json) {
    return OrderBookListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      books: (json['Books'] as List? ?? [])
          .map((e) => OrderBookItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderBookItem {
  final String bookName;
  final String classes;
  final String subject;
  int qty;
  final double rate;

  OrderBookItem({
    required this.bookName,
    required this.classes,
    required this.subject,
    required this.qty,
    required this.rate,
  });

  factory OrderBookItem.fromJson(Map<String, dynamic> json) {
    return OrderBookItem(
      bookName: json['BookName'] ?? '',
      classes: json['Classes'] ?? '',
      subject: json['Subject'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: (json['Rate'] ?? 0).toDouble(),
    );
  }

  double get amount => qty * rate;
}

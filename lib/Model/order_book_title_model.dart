class OrderBookTitleModel {
  final bool status;
  final String message;
  final List<String> subjectList;

  OrderBookTitleModel({
    required this.status,
    required this.message,
    required this.subjectList,
  });

  factory OrderBookTitleModel.fromJson(Map<String, dynamic> json) {
    return OrderBookTitleModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      subjectList: List<String>.from(json['SubjectList'] ?? []),
    );
  }
}

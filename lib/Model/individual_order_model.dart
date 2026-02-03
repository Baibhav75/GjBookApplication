class IndividualOrder {
  final String senderId;
  final String publication;
  final DateTime date;
  final String schoolName;

  IndividualOrder({
    required this.senderId,
    required this.publication,
    required this.date,
    required this.schoolName,
  });

  factory IndividualOrder.fromJson(Map<String, dynamic> json) {
    return IndividualOrder(
      senderId: json['SenderId'] ?? '',
      publication: json['Publication'] ?? '',
      date: DateTime.parse(json['Dates']),
      schoolName: json['SchoolName'] ?? '',
    );
  }

  static List<IndividualOrder> listFromJson(List<dynamic> list) {
    return list.map((e) => IndividualOrder.fromJson(e)).toList();
  }
}

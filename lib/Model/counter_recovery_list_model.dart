class CounterRecoveryListModel {
  final int id;
  final String counterId;
  final String counterName;
  final String counterBoyName;
  final String counterBoyMob;
  final String schoolName;
  final DateTime? createDate;
  final String schoolId;

  CounterRecoveryListModel({
    required this.id,
    required this.counterId,
    required this.counterName,
    required this.counterBoyName,
    required this.counterBoyMob,
    required this.schoolName,
    required this.createDate,
    required this.schoolId,
  });

  factory CounterRecoveryListModel.fromJson(Map<String, dynamic> json) {
    return CounterRecoveryListModel(
      id: json["Id"] ?? 0,
      counterId: json["CounterId"] ?? "",
      counterName: json["CounterName"] ?? "",
      counterBoyName: json["CounterBoyName"] ?? "",
      counterBoyMob: json["CounterBoyMob"] ?? "",
      schoolName: json["SchoolName"] ?? "",
      createDate: json["CreateDate"] != null
          ? DateTime.parse(json["CreateDate"])
          : null,
      schoolId: json["SchoolId"] ?? "",
    );
  }
}
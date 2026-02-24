class ReceivePendingAmountModel {
  final String employeeId;
  final double pendingAmount;
  final double receivedAmount;
  final double totalAmount;

  ReceivePendingAmountModel({
    required this.employeeId,
    required this.pendingAmount,
    required this.receivedAmount,
    required this.totalAmount,
  });

  factory ReceivePendingAmountModel.fromJson(Map<String, dynamic> json) {
    return ReceivePendingAmountModel(
      employeeId: json['EmployeeId'] ?? "",
      pendingAmount: (json['PendingAmount'] ?? 0).toDouble(),
      receivedAmount: (json['ReceivedAmount'] ?? 0).toDouble(),
      totalAmount: (json['TotalAmount'] ?? 0).toDouble(),
    );
  }
}
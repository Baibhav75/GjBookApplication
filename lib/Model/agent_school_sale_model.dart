class AgentSchoolSaleResponse {
  final String status;
  final String message;
  final String agentId;
  final int totalBills;
  final List<AgentSchoolSale> data;

  AgentSchoolSaleResponse({
    required this.status,
    required this.message,
    required this.agentId,
    required this.totalBills,
    required this.data,
  });

  factory AgentSchoolSaleResponse.fromJson(Map<String, dynamic> json) {
    return AgentSchoolSaleResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      agentId: json['AgentId'] ?? '',
      totalBills: json['TotalBills'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((e) => AgentSchoolSale.fromJson(e))
          .toList(),
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}

class AgentSchoolSale {
  final String schoolName;
  final String billNo;
  final DateTime billDate;
  final double amount;
  final String type;

  AgentSchoolSale({
    required this.schoolName,
    required this.billNo,
    required this.billDate,
    required this.amount,
    required this.type,
  });

  factory AgentSchoolSale.fromJson(Map<String, dynamic> json) {
    return AgentSchoolSale(
      schoolName: json['SchoolName'] ?? '',
      billNo: json['BillNo'] ?? '',
      billDate: DateTime.parse(json['BillDate']),
      amount: (json['Amount'] as num).toDouble(),
      type: json['Type'] ?? '',
    );
  }
}

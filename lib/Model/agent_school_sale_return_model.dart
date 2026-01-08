class AgentSchoolSaleReturnResponse {
  final String status;
  final String message;
  final String agentId;
  final int totalBills;
  final List<AgentSchoolSaleReturn> data;

  AgentSchoolSaleReturnResponse({
    required this.status,
    required this.message,
    required this.agentId,
    required this.totalBills,
    required this.data,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory AgentSchoolSaleReturnResponse.fromJson(Map<String, dynamic> json) {
    return AgentSchoolSaleReturnResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      agentId: json['AgentId'] ?? '',
      totalBills: json['TotalBills'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => AgentSchoolSaleReturn.fromJson(e))
          .toList(),
    );
  }
}

class AgentSchoolSaleReturn {
  final String schoolName;
  final String billNo;
  final DateTime billDate;
  final double amount;
  final String type;

  AgentSchoolSaleReturn({
    required this.schoolName,
    required this.billNo,
    required this.billDate,
    required this.amount,
    required this.type,
  });

  factory AgentSchoolSaleReturn.fromJson(Map<String, dynamic> json) {
    return AgentSchoolSaleReturn(
      schoolName: json['SchoolName'] ?? '',
      billNo: json['BillNo'] ?? '',
      billDate: DateTime.parse(json['BillDate']),
      amount: (json['Amount'] as num).toDouble(),
      type: json['Type'] ?? '',
    );
  }
}

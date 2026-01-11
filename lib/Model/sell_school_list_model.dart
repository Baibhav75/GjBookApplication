class SellSchoolListResponse {
  final bool status;
  final String message;
  final List<SellSchool> schools;

  SellSchoolListResponse({
    required this.status,
    required this.message,
    required this.schools,
  });

  factory SellSchoolListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['SchoolList'];
    return SellSchoolListResponse(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      schools: list is List
          ? list.map((e) => SellSchool.fromJson(e)).toList()
          : [],
    );
  }
}

class SellSchool {
  final int id;
  final String refName;
  final String ownerName;
  final String principalName;
  final String ownerNo;
  final String principalNo;
  final num openingBalance;
  final String balanceType;
  final String address;
  final String district;
  final String blocks;
  final String area;
  final String manager;
  final String agentName;
  final String recoveryAgent;
  final String transportName;
  final String fileNo;
  final String type;
  final String state;
  final String tahsil;
  final String accode;
  final String accName;
  final String complainRecord;
  final String schoolPassword;
  final String areaManagerHead;
  final String recoveryAgentHead;

  SellSchool({
    required this.id,
    required this.refName,
    required this.ownerName,
    required this.principalName,
    required this.ownerNo,
    required this.principalNo,
    required this.openingBalance,
    required this.balanceType,
    required this.address,
    required this.district,
    required this.blocks,
    required this.area,
    required this.manager,
    required this.agentName,
    required this.recoveryAgent,
    required this.transportName,
    required this.fileNo,
    required this.type,
    required this.state,
    required this.tahsil,
    required this.accode,
    required this.accName,
    required this.complainRecord,
    required this.schoolPassword,
    required this.areaManagerHead,
    required this.recoveryAgentHead,
  });

  factory SellSchool.fromJson(Map<String, dynamic> json) {
    return SellSchool(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      refName: json['RefName'] ?? '',
      ownerName: json['OwnerName'] ?? '',
      principalName: json['PrincipalName'] ?? '',
      ownerNo: json['OwnerNo'] ?? '',
      principalNo: json['PrincipalNo'] ?? '',
      openingBalance: json['OpeningBalance'] ?? 0,
      balanceType: json['BalanceType'] ?? '',
      address: json['Addresss'] ?? '', // API typo
      district: json['District'] ?? '',
      blocks: json['Blocks'] ?? '',
      area: json['Area'] ?? '',
      manager: json['Manager'] ?? '',
      agentName: json['AgentName'] ?? '',
      recoveryAgent: json['RecoveryAgent'] ?? '',
      transportName: json['TransportName'] ?? '',
      fileNo: json['FileNo'] ?? '',
      type: json['Type'] ?? '',
      state: json['State'] ?? '',
      tahsil: json['Tahsil'] ?? '',
      accode: json['Accode'] ?? '',
      accName: json['AccName'] ?? '',
      complainRecord: json['ComplainRecord'] ?? '',
      schoolPassword: json['SchoolPassword'] ?? '',
      areaManagerHead: json['AreaManagerHead'] ?? '',
      recoveryAgentHead: json['RecoveryAgentHead'] ?? '',
    );
  }

  /// ✅ UI-friendly alias (IMPORTANT)
  String get schoolName => accName;

  /// 🔥 Converts ALL fields to Map (for auto UI)
  Map<String, dynamic> toMap() {
    return {
      "ID": id,
      "Reference Name": refName,
      "Account Name": accName,
      "Owner Name": ownerName,
      "Principal Name": principalName,
      "Owner Mobile": ownerNo,
      "Principal Mobile": principalNo,
      "Opening Balance": openingBalance,
      "Balance Type": balanceType,
      "Address": address,
      "District": district,
      "Blocks": blocks,
      "Area": area,
      "Manager": manager,
      "Agent Name": agentName,
      "Recovery Agent": recoveryAgent,
      "Transport": transportName,
      "File No": fileNo,
      "Type": type,
      "State": state,
      "Tahsil": tahsil,
      "Account Code": accode,
      "Complaint Record": complainRecord,
      "School Password": schoolPassword,
      "Area Manager Head": areaManagerHead,
      "Recovery Agent Head": recoveryAgentHead,
    };
  }
}

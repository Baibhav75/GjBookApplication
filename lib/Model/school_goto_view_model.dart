class SchoolAgreementListModel {
  final bool status;
  final String message;
  final int totalRecords;
  final List<AgreementItem> data;

  SchoolAgreementListModel({
    required this.status,
    required this.message,
    required this.totalRecords,
    required this.data,
  });

  factory SchoolAgreementListModel.fromJson(Map<String, dynamic> json) {
    return SchoolAgreementListModel(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      totalRecords: json['TotalRecords'] ?? 0,
      data: (json['Data'] as List)
          .map((e) => AgreementItem.fromJson(e))
          .toList(),
    );
  }
}

class AgreementItem {
  final int id;
  final String partyName;
  final String address;
  final String district;
  final String principalName;
  final String principalContact;
  final String createDate;

  AgreementItem({
    required this.id,
    required this.partyName,
    required this.address,
    required this.district,
    required this.principalName,
    required this.principalContact,
    required this.createDate,
  });

  factory AgreementItem.fromJson(Map<String, dynamic> json) {
    return AgreementItem(
      id: json['id'] ?? 0,
      partyName: json['PartyName'] ?? '',
      address: json['Address'] ?? '',
      district: json['District'] ?? '',
      principalName: json['Principal_Name'] ?? '',
      principalContact: json['Principal_Contact'] ?? '',
      createDate: json['CreateDate'] ?? '',
    );
  }
}

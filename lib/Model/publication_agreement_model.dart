class PublicationListModel {
  final bool status;
  final String message;
  final List<Publication> publicationList;

  PublicationListModel({
    required this.status,
    required this.message,
    required this.publicationList,
  });

  factory PublicationListModel.fromJson(Map<String, dynamic> json) {
    return PublicationListModel(
      status: json['Status'] ?? false,
      message: json['Message'] ?? '',
      publicationList: (json['PublicationList'] as List? ?? [])
          .map((item) => Publication.fromJson(item))
          .toList(),
    );
  }
}

class Publication {
  final int id;
  final String publicationName;
  final String address;
  final String? mobileNo;
  final String? email;
  final String? agrementFile;
  final String? checks;
  final DateTime createDate;
  final String checkNumber;
  final String areaManagerName;
  final String areaManagerMoNo;
  final String areaManagerEmail;
  final String salesHeadName;
  final String salesHeadMoNo;
  final String salesHeadEmail;
  final String localSalesHeadName;
  final String localSalesHeadMoNo;
  final String localSalesHeadEmail;
  final String zonelHeadName;
  final String zonelHeadMoNo;
  final String zonelHeadEmail;
  final String? ownerName;
  final String? ownerMoNo;
  final String? ownerEmail;
  final String? type;
  final int? target;
  final String? groups;
  final String? remark;

  Publication({
    required this.id,
    required this.publicationName,
    required this.address,
    this.mobileNo,
    this.email,
    this.agrementFile,
    this.checks,
    required this.createDate,
    required this.checkNumber,
    required this.areaManagerName,
    required this.areaManagerMoNo,
    required this.areaManagerEmail,
    required this.salesHeadName,
    required this.salesHeadMoNo,
    required this.salesHeadEmail,
    required this.localSalesHeadName,
    required this.localSalesHeadMoNo,
    required this.localSalesHeadEmail,
    required this.zonelHeadName,
    required this.zonelHeadMoNo,
    required this.zonelHeadEmail,
    this.ownerName,
    this.ownerMoNo,
    this.ownerEmail,
    this.type,
    this.target,
    this.groups,
    this.remark,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'] ?? 0,
      publicationName: json['PublicationName'] ?? '',
      address: json['Address'] ?? '',
      mobileNo: json['MobileNo'],
      email: json['Email'],
      agrementFile: json['AgrementFile'],
      checks: json['Checks'],
      createDate: json['createdate'] != null
          ? DateTime.tryParse(json['createdate']) ?? DateTime.now()
          : DateTime.now(),
      checkNumber: json['CheckNumber']?.toString() ?? '',
      areaManagerName: json['AreaManagerName'] ?? '',
      areaManagerMoNo: json['AreaManagerMoNo']?.toString() ?? '',
      areaManagerEmail: json['AreaManagerEmail'] ?? '',
      salesHeadName: json['SalesHeadName'] ?? '',
      salesHeadMoNo: json['SalesHeadMoNo']?.toString() ?? '',
      salesHeadEmail: json['SalesHeadEmail'] ?? '',
      localSalesHeadName: json['LocalSalesHeadName'] ?? '',
      localSalesHeadMoNo: json['LocalSalesHeadMoNo']?.toString() ?? '',
      localSalesHeadEmail: json['LocalSalesHeadEmail'] ?? '',
      zonelHeadName: json['ZonelHeadName'] ?? '',
      zonelHeadMoNo: json['ZonelHeadMoNo']?.toString() ?? '',
      zonelHeadEmail: json['ZonelHeadEmail'] ?? '',
      ownerName: json['OwnerName'],
      ownerMoNo: json['OwnerMoNo']?.toString(),
      ownerEmail: json['OwnerEmail'],
      type: json['Type'],
      target: json['Target'] != null ? int.tryParse(json['Target'].toString()) : null,
      groups: json['Groups'],
      remark: json['Remark'],
    );
  }
}
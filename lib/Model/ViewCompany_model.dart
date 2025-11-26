class ViewCompanyModel {
  final bool? status;
  final String? message;
  final List<PublicationList>? publicationList;

  ViewCompanyModel({
    this.status,
    this.message,
    this.publicationList,
  });

  factory ViewCompanyModel.fromJson(Map<String, dynamic> json) {
    return ViewCompanyModel(
      status: json['Status'],
      message: json['Message'],
      publicationList: json['PublicationList'] != null
          ? (json['PublicationList'] as List)
          .map((v) => PublicationList.fromJson(v))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Message': message,
      'PublicationList': publicationList?.map((v) => v.toJson()).toList(),
    };
  }
}

class PublicationList {
  final String? code;
  final String? publication;
  final String? groups;
  final String? address;
  final String? createDate;
  final String? agreementForm;
  final dynamic discountRate; // Changed from int? to dynamic
  final String? email;
  final String? mobileNo;
  final String? gstNo;
  final String? websitelink;

  PublicationList({
    this.code,
    this.publication,
    this.groups,
    this.address,
    this.createDate,
    this.agreementForm,
    this.discountRate,
    this.email,
    this.mobileNo,
    this.gstNo,
    this.websitelink,
  });

  factory PublicationList.fromJson(Map<String, dynamic> json) {
    return PublicationList(
      code: _parseString(json['Code']),
      publication: _parseString(json['Publication']),
      groups: _parseString(json['Groups']),
      address: _parseString(json['Address']),
      createDate: _parseString(json['CreateDate']),
      agreementForm: _parseString(json['AgreementForm']),
      discountRate: json['discountRate'],
      email: _parseString(json['Email']),
      mobileNo: _parseString(json['MobileNo']),
      gstNo: _parseString(json['GstNo']),
      websitelink: _parseString(json['Websitelink']),
    );
  }

  // Helper method to safely parse strings
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  // Get discount rate as int with safe parsing
  int get discountRateAsInt {
    if (discountRate == null) return 0;
    if (discountRate is int) return discountRate as int;
    if (discountRate is double) return (discountRate as double).round();
    if (discountRate is String) {
      return int.tryParse(discountRate) ?? 0;
    }
    return 0;
  }

  // Get discount rate as string for display
  String get discountRateDisplay {
    if (discountRate == null) return '0%';
    if (discountRate is num) {
      return '${discountRate}%';
    }
    return '$discountRate%';
  }

  Map<String, dynamic> toJson() {
    return {
      'Code': code,
      'Publication': publication,
      'Groups': groups,
      'Address': address,
      'CreateDate': createDate,
      'AgreementForm': agreementForm,
      'discountRate': discountRate,
      'Email': email,
      'MobileNo': mobileNo,
      'GstNo': gstNo,
      'Websitelink': websitelink,
    };
  }
}
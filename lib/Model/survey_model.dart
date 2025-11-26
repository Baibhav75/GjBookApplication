// models/survey_model.dart
import 'dart:convert';

class SurveyResponse {
  final bool status;
  final String message;
  final List<SchoolData> schoolList;

  SurveyResponse({
    required this.status,
    required this.message,
    required this.schoolList,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      status: json['Status'] == null ? false : json['Status'] as bool,
      message: json['Message'] ?? '',
      schoolList: (json['SchoolList'] as List<dynamic>?)
          ?.map((e) => SchoolData.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'Status': status,
    'Message': message,
    'SchoolList': schoolList.map((e) => e.toJson()).toList(),
  };

  static SurveyResponse fromRawJson(String str) =>
      SurveyResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

class SchoolData {
  final int? id;
  final String? schoolName;
  final String? schoolAddress;
  final String? district;
  final String? tahsil;
  final String? block;
  final String? village;
  final String? mobile;
  final String? prabandhakName;
  final String? prabandhakMobile;
  final String? principalName;
  final String? principalMobile;
  final int? schoolEstablishYear;
  final String? schoolType;
  final String? schoolMedium;
  final String? boardAffiliation;
  final String? branchDetail;
  final String? areaType;
  final int? allTotal;
  final String? schoolPhoto;
  final String? schoolLocation;
  final String? agentId;
  final String? agentName;
  final String? accountDetail;
  final String? createdDate;

  // You can add more fields as required; keep these commonly used ones for UI.

  SchoolData({
    this.id,
    this.schoolName,
    this.schoolAddress,
    this.district,
    this.tahsil,
    this.block,
    this.village,
    this.mobile,
    this.prabandhakName,
    this.prabandhakMobile,
    this.principalName,
    this.principalMobile,
    this.schoolEstablishYear,
    this.schoolType,
    this.schoolMedium,
    this.boardAffiliation,
    this.branchDetail,
    this.areaType,
    this.allTotal,
    this.schoolPhoto,
    this.schoolLocation,
    this.agentId,
    this.agentName,
    this.accountDetail,
    this.createdDate,
  });

  factory SchoolData.fromJson(Map<String, dynamic> json) {
    return SchoolData(
      id: json['Id'] is int ? json['Id'] as int : int.tryParse('${json['Id']}'),
      schoolName: json['SchoolName']?.toString(),
      schoolAddress: json['SchoolAddress']?.toString(),
      district: json['District']?.toString(),
      tahsil: json['Tahsil']?.toString(),
      block: json['Block']?.toString(),
      village: json['Village']?.toString(),
      mobile: json['Mobile']?.toString(),
      prabandhakName: json['PrabandhakName']?.toString(),
      prabandhakMobile: json['PrabandhakMobile']?.toString(),
      principalName: json['PrincipalName']?.toString(),
      principalMobile: json['PrincipalMobile']?.toString(),
      schoolEstablishYear: json['SchoolEstablishYear'] is int
          ? json['SchoolEstablishYear'] as int
          : int.tryParse('${json['SchoolEstablishYear']}'),
      schoolType: json['SchoolType']?.toString(),
      schoolMedium: json['SchoolMedium']?.toString(),
      boardAffiliation: json['BoardAffiliation']?.toString(),
      branchDetail: json['BranchDetail']?.toString(),
      areaType: json['AreaType']?.toString(),
      allTotal: json['AllTotal'] is int
          ? json['AllTotal'] as int
          : int.tryParse('${json['AllTotal']}'),
      schoolPhoto: json['SchoolPhoto']?.toString(),
      schoolLocation: json['SchoolLocation']?.toString(),
      agentId: json['AgentId']?.toString(),
      agentName: json['AgentName']?.toString(),
      accountDetail: json['AccountDetail']?.toString(),
      createdDate: json['CreatedDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'SchoolName': schoolName,
      'SchoolAddress': schoolAddress,
      'District': district,
      'Tahsil': tahsil,
      'Block': block,
      'Village': village,
      'Mobile': mobile,
      'PrabandhakName': prabandhakName,
      'PrabandhakMobile': prabandhakMobile,
      'PrincipalName': principalName,
      'PrincipalMobile': principalMobile,
      'SchoolEstablishYear': schoolEstablishYear,
      'SchoolType': schoolType,
      'SchoolMedium': schoolMedium,
      'BoardAffiliation': boardAffiliation,
      'BranchDetail': branchDetail,
      'AreaType': areaType,
      'AllTotal': allTotal,
      'SchoolPhoto': schoolPhoto,
      'SchoolLocation': schoolLocation,
      'AgentId': agentId,
      'AgentName': agentName,
      'AccountDetail': accountDetail,
      'CreatedDate': createdDate,
    };
  }

  String displayShortTitle() => schoolName ?? 'Unknown School';
}

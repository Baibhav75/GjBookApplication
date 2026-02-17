class SchoolDiscountAgreementResponseModel {
  final bool status;
  final String message;
  final AgreementData? data;

  SchoolDiscountAgreementResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory SchoolDiscountAgreementResponseModel.fromJson(
      Map<String, dynamic> json) {
    return SchoolDiscountAgreementResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data:
      json['data'] != null ? AgreementData.fromJson(json['data']) : null,
    );
  }
}

class AgreementData {
  final int? id;

  final String? partyName;
  final String? address;
  final String? district;
  final String? block;
  final String? area;

  final String? manageName;
  final String? managerContact;
  final DateTime? managerDOB;
  final DateTime? managerAnniversary;

  final String? principalName;
  final String? principalContact;
  final DateTime? principalDOB;
  final DateTime? principalAnniversary;

  final String? agentName;
  final String? agentContact;
  final DateTime? agentDOB;
  final DateTime? agentAnniversary;

  final String? areaManagerName;
  final String? areaManagerContact;
  final DateTime? areaManagerDOB;
  final DateTime? areaManagerAnniversary;

  final DateTime? orderDate;
  final DateTime? deliveryDate;

  final String? schoolPanNo;
  final String? schoolAdharNo;
  final String? schoolPanImage;
  final String? schoolAdharImage;

  final String? schoolAccountNo;
  final String? schoolBankDetail;
  final String? chequeNo;
  final String? securiyCheck;

  final String? januaryPayment;
  final String? februaryPayment;
  final String? marchPayment;
  final String? aprilPayment;
  final String? mayPayment;
  final String? junePayment;
  final String? julyPayment;
  final String? augustPayment;
  final String? septemberPayment;
  final String? octoberPayment;
  final String? novemberPayment;
  final String? decemberPayment;

  final String? partySignature;
  final String? managerSignature;

  final String? type;
  final String? schoolType;

  final String? discountSlab1;
  final String? discountSlab2;
  final String? discountSlab3;
  final String? discountSlab4;
  final String? discountSlab5;
  final String? discountSlab6;
  final String? discountSlab7;
  final String? discountSlab8;
  final String? discountSlab9;
  final String? discountSlab10;
  final String? discountSlab11;
  final String? discountSlab12;

  final String? remarks;
  final DateTime? createDate;
  final String? fileNo;
  final String? createdBy;
  final int? schoolId;
  final int? agentId;

  AgreementData({
    this.id,
    this.partyName,
    this.address,
    this.district,
    this.block,
    this.area,
    this.manageName,
    this.managerContact,
    this.managerDOB,
    this.managerAnniversary,
    this.principalName,
    this.principalContact,
    this.principalDOB,
    this.principalAnniversary,
    this.agentName,
    this.agentContact,
    this.agentDOB,
    this.agentAnniversary,
    this.areaManagerName,
    this.areaManagerContact,
    this.areaManagerDOB,
    this.areaManagerAnniversary,
    this.orderDate,
    this.deliveryDate,
    this.schoolPanNo,
    this.schoolAdharNo,
    this.schoolPanImage,
    this.schoolAdharImage,
    this.schoolAccountNo,
    this.schoolBankDetail,
    this.chequeNo,
    this.securiyCheck,
    this.januaryPayment,
    this.februaryPayment,
    this.marchPayment,
    this.aprilPayment,
    this.mayPayment,
    this.junePayment,
    this.julyPayment,
    this.augustPayment,
    this.septemberPayment,
    this.octoberPayment,
    this.novemberPayment,
    this.decemberPayment,
    this.partySignature,
    this.managerSignature,
    this.type,
    this.schoolType,
    this.discountSlab1,
    this.discountSlab2,
    this.discountSlab3,
    this.discountSlab4,
    this.discountSlab5,
    this.discountSlab6,
    this.discountSlab7,
    this.discountSlab8,
    this.discountSlab9,
    this.discountSlab10,
    this.discountSlab11,
    this.discountSlab12,
    this.remarks,
    this.createDate,
    this.fileNo,
    this.createdBy,
    this.schoolId,
    this.agentId,
  });

  factory AgreementData.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? date) =>
        date != null ? DateTime.tryParse(date) : null;

    return AgreementData(
      id: json['id'],
      partyName: json['PartyName'],
      address: json['Address'],
      district: json['District'],
      block: json['Block'],
      area: json['Area'],
      manageName: json['ManageName'],
      managerContact: json['ManagerContact'],
      managerDOB: parseDate(json['Manager_DOB']),
      managerAnniversary: parseDate(json['Manager_Anniversary']),
      principalName: json['Principal_Name'],
      principalContact: json['Principal_Contact'],
      principalDOB: parseDate(json['Principal_DOB']),
      principalAnniversary: parseDate(json['Principal_Anniversary']),
      agentName: json['AgentName'],
      agentContact: json['AgentContact'],
      agentDOB: parseDate(json['Agent_DOB']),
      agentAnniversary: parseDate(json['Agent_Anniversary']),
      areaManagerName: json['AreaManagerName'],
      areaManagerContact: json['AreaManager_Contact'],
      areaManagerDOB: parseDate(json['AreaManager_DOB']),
      areaManagerAnniversary: parseDate(json['AreaManager_Anniversary']),
      orderDate: parseDate(json['OrderDate']),
      deliveryDate: parseDate(json['DeliveryDate']),
      schoolPanNo: json['SchoolPanNo'],
      schoolAdharNo: json['SchoolAdhar_No'],
      schoolPanImage: json['SchoolPan_image'],
      schoolAdharImage: json['School_Adhar_Image'],
      schoolAccountNo: json['School_AccountNo'],
      schoolBankDetail: json['School_BankDetail'],
      chequeNo: json['Cheque_No'],
      securiyCheck: json['Securiy_Check'],
      januaryPayment: json['January_Payment'],
      februaryPayment: json['February_Payment'],
      marchPayment: json['March_Payment'],
      aprilPayment: json['April_Payment'],
      mayPayment: json['May_Payment'],
      junePayment: json['June_Payment'],
      julyPayment: json['July_Payment'],
      augustPayment: json['August_Payment'],
      septemberPayment: json['September_Payment'],
      octoberPayment: json['October_Payment'],
      novemberPayment: json['November_Payment'],
      decemberPayment: json['December_Payment'],
      partySignature: json['Party_Signature'],
      managerSignature: json['Manager_Signature'],
      type: json['Type'],
      schoolType: json['SchoolType'],
      discountSlab1: json['Discount_Slab1'],
      discountSlab2: json['Discount_Slab2'],
      discountSlab3: json['Discount_Slab3'],
      discountSlab4: json['Discount_Slab4'],
      discountSlab5: json['Discount_Slab5'],
      discountSlab6: json['Discount_Slab6'],
      discountSlab7: json['Discount_Slab7'],
      discountSlab8: json['Discount_Slab8'],
      discountSlab9: json['Discount_Slab9'],
      discountSlab10: json['Discount_Slab10'],
      discountSlab11: json['Discount_Slab11'],
      discountSlab12: json['Discount_Slab12'],
      remarks: json['Remarks'],
      createDate: parseDate(json['CreateDate']),
      fileNo: json['FileNo'],
      createdBy: json['CreatedBy'],
      schoolId: json['SchoolId'],
      agentId: json['AgentId'],
    );
  }
}

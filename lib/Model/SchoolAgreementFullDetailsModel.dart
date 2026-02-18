class SchoolAgreementFullDetailsModel {
  String? status;
  String? message;
  Data? data;

  SchoolAgreementFullDetailsModel({this.status, this.message, this.data});

  SchoolAgreementFullDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? partyName;
  String? address;
  String? district;
  String? block;
  String? area;
  String? manageName;
  String? managerContact;
  String? managerDOB;
  String? managerAnniversary;
  String? principalName;
  String? principalContact;
  String? principalDOB;
  String? principalAnniversary;
  String? agentName;
  String? agentContact;
  String? agentDOB;
  String? agentAnniversary;
  String? areaManagerName;
  String? areaManagerContact;
  String? areaManagerDOB;
  String? areaManagerAnniversary;
  String? orderDate;
  String? deliveryDate;
  String? schoolPanNo;
  String? schoolAdharNo;
  String? schoolPanImage;
  String? schoolAdharImage;
  String? schoolAccountNo;
  String? schoolBankDetail;
  String? chequeNo;
  String? securiyCheck;
  String? januaryPayment;
  String? februaryPayment;
  String? marchPayment;
  String? aprilPayment;
  String? mayPayment;
  String? junePayment;
  String? julyPayment;
  String? augustPayment;
  String? septemberPayment;
  String? octoberPayment;
  String? novemberPayment;
  String? decemberPayment;
  String? partySignature;
  String? managerSignature;
  Null? type;
  String? discountSlab1;
  String? discountSlab2;
  String? discountSlab3;
  String? discountSlab4;
  String? discountSlab5;
  String? discountSlab6;
  String? discountSlab7;
  String? discountSlab8;
  String? remarks;
  String? createDate;
  String? schoolType;
  String? discountSlab9;
  String? discountSlab10;
  String? discountSlab11;
  String? discountSlab12;
  String? fileNo;
  String? createdBy;
  String? schoolId;
  String? agentId;

  Data(
      {this.id,
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
        this.discountSlab1,
        this.discountSlab2,
        this.discountSlab3,
        this.discountSlab4,
        this.discountSlab5,
        this.discountSlab6,
        this.discountSlab7,
        this.discountSlab8,
        this.remarks,
        this.createDate,
        this.schoolType,
        this.discountSlab9,
        this.discountSlab10,
        this.discountSlab11,
        this.discountSlab12,
        this.fileNo,
        this.createdBy,
        this.schoolId,
        this.agentId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    partyName = json['PartyName'];
    address = json['Address'];
    district = json['District'];
    block = json['Block'];
    area = json['Area'];
    manageName = json['ManageName'];
    managerContact = json['ManagerContact'];
    managerDOB = json['Manager_DOB'];
    managerAnniversary = json['Manager_Anniversary'];
    principalName = json['Principal_Name'];
    principalContact = json['Principal_Contact'];
    principalDOB = json['Principal_DOB'];
    principalAnniversary = json['Principal_Anniversary'];
    agentName = json['AgentName'];
    agentContact = json['AgentContact'];
    agentDOB = json['Agent_DOB'];
    agentAnniversary = json['Agent_Anniversary'];
    areaManagerName = json['AreaManagerName'];
    areaManagerContact = json['AreaManager_Contact'];
    areaManagerDOB = json['AreaManager_DOB'];
    areaManagerAnniversary = json['AreaManager_Anniversary'];
    orderDate = json['OrderDate'];
    deliveryDate = json['DeliveryDate'];
    schoolPanNo = json['SchoolPanNo'];
    schoolAdharNo = json['SchoolAdhar_No'];
    schoolPanImage = json['SchoolPan_image'];
    schoolAdharImage = json['School_Adhar_Image'];
    schoolAccountNo = json['School_AccountNo'];
    schoolBankDetail = json['School_BankDetail'];
    chequeNo = json['Cheque_No'];
    securiyCheck = json['Securiy_Check'];
    januaryPayment = json['January_Payment'];
    februaryPayment = json['February_Payment'];
    marchPayment = json['March_Payment'];
    aprilPayment = json['April_Payment'];
    mayPayment = json['May_Payment'];
    junePayment = json['June_Payment'];
    julyPayment = json['July_Payment'];
    augustPayment = json['August_Payment'];
    septemberPayment = json['September_Payment'];
    octoberPayment = json['October_Payment'];
    novemberPayment = json['November_Payment'];
    decemberPayment = json['December_Payment'];
    partySignature = json['Party_Signature'];
    managerSignature = json['Manager_Signature'];
    // type = json['Type']; // Removed Null? type
    discountSlab1 = json['Discount_Slab1'];
    discountSlab2 = json['Discount_Slab2'];
    discountSlab3 = json['Discount_Slab3'];
    discountSlab4 = json['Discount_Slab4'];
    discountSlab5 = json['Discount_Slab5'];
    discountSlab6 = json['Discount_Slab6'];
    discountSlab7 = json['Discount_Slab7'];
    discountSlab8 = json['Discount_Slab8'];
    remarks = json['Remarks'];
    createDate = json['CreateDate'];
    schoolType = json['SchoolType'];
    discountSlab9 = json['Discount_Slab9'];
    discountSlab10 = json['Discount_Slab10'];
    discountSlab11 = json['Discount_Slab11'];
    discountSlab12 = json['Discount_Slab12'];
    fileNo = json['FileNo'];
    createdBy = json['CreatedBy'];
    schoolId = json['SchoolId'];
    agentId = json['AgentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['PartyName'] = this.partyName;
    data['Address'] = this.address;
    data['District'] = this.district;
    data['Block'] = this.block;
    data['Area'] = this.area;
    data['ManageName'] = this.manageName;
    data['ManagerContact'] = this.managerContact;
    data['Manager_DOB'] = this.managerDOB;
    data['Manager_Anniversary'] = this.managerAnniversary;
    data['Principal_Name'] = this.principalName;
    data['Principal_Contact'] = this.principalContact;
    data['Principal_DOB'] = this.principalDOB;
    data['Principal_Anniversary'] = this.principalAnniversary;
    data['AgentName'] = this.agentName;
    data['AgentContact'] = this.agentContact;
    data['Agent_DOB'] = this.agentDOB;
    data['Agent_Anniversary'] = this.agentAnniversary;
    data['AreaManagerName'] = this.areaManagerName;
    data['AreaManager_Contact'] = this.areaManagerContact;
    data['AreaManager_DOB'] = this.areaManagerDOB;
    data['AreaManager_Anniversary'] = this.areaManagerAnniversary;
    data['OrderDate'] = this.orderDate;
    data['DeliveryDate'] = this.deliveryDate;
    data['SchoolPanNo'] = this.schoolPanNo;
    data['SchoolAdhar_No'] = this.schoolAdharNo;
    data['SchoolPan_image'] = this.schoolPanImage;
    data['School_Adhar_Image'] = this.schoolAdharImage;
    data['School_AccountNo'] = this.schoolAccountNo;
    data['School_BankDetail'] = this.schoolBankDetail;
    data['Cheque_No'] = this.chequeNo;
    data['Securiy_Check'] = this.securiyCheck;
    data['January_Payment'] = this.januaryPayment;
    data['February_Payment'] = this.februaryPayment;
    data['March_Payment'] = this.marchPayment;
    data['April_Payment'] = this.aprilPayment;
    data['May_Payment'] = this.mayPayment;
    data['June_Payment'] = this.junePayment;
    data['July_Payment'] = this.julyPayment;
    data['August_Payment'] = this.augustPayment;
    data['September_Payment'] = this.septemberPayment;
    data['October_Payment'] = this.octoberPayment;
    data['November_Payment'] = this.novemberPayment;
    data['December_Payment'] = this.decemberPayment;
    data['Party_Signature'] = this.partySignature;
    data['Manager_Signature'] = this.managerSignature;
    data['Type'] = this.type;
    data['Discount_Slab1'] = this.discountSlab1;
    data['Discount_Slab2'] = this.discountSlab2;
    data['Discount_Slab3'] = this.discountSlab3;
    data['Discount_Slab4'] = this.discountSlab4;
    data['Discount_Slab5'] = this.discountSlab5;
    data['Discount_Slab6'] = this.discountSlab6;
    data['Discount_Slab7'] = this.discountSlab7;
    data['Discount_Slab8'] = this.discountSlab8;
    data['Remarks'] = this.remarks;
    data['CreateDate'] = this.createDate;
    data['SchoolType'] = this.schoolType;
    data['Discount_Slab9'] = this.discountSlab9;
    data['Discount_Slab10'] = this.discountSlab10;
    data['Discount_Slab11'] = this.discountSlab11;
    data['Discount_Slab12'] = this.discountSlab12;
    data['FileNo'] = this.fileNo;
    data['CreatedBy'] = this.createdBy;
    data['SchoolId'] = this.schoolId;
    data['AgentId'] = this.agentId;
    return data;
  }
}

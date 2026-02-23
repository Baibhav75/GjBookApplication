class RecoveryPendingAmountModel {
  int? id;
  String? schoolName;
  String? schoolId;
  double? amount;
  String? recivedByFromSchool;
  String? reciverEmpId;
  String? payMentDate;
  String? status;
  String? remarks;
  String? reciptNo;
  String? schoolAddress;
  String? schoolBlock;
  String? schoolDistrict;
  String? collectedByInoffice;
  String? createDate;
  String? paymentmode;
  String? createdBy;
  String? collectedByInOfficeEmpid;

  RecoveryPendingAmountModel({
    this.id,
    this.schoolName,
    this.schoolId,
    this.amount,
    this.recivedByFromSchool,
    this.reciverEmpId,
    this.payMentDate,
    this.status,
    this.remarks,
    this.reciptNo,
    this.schoolAddress,
    this.schoolBlock,
    this.schoolDistrict,
    this.collectedByInoffice,
    this.createDate,
    this.paymentmode,
    this.createdBy,
    this.collectedByInOfficeEmpid,
  });


  RecoveryPendingAmountModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    schoolName = json['SchoolName']?.toString();
    schoolId = json['SchoolId']?.toString();
    amount = json['Amount'] != null
        ? double.tryParse(json['Amount'].toString())
        : 0.0;
    recivedByFromSchool = json['RecivedByFromSchool']?.toString();
    reciverEmpId = json['ReciverEmpId']?.toString();
    payMentDate = json['PayMentDate']?.toString();
    status = json['Status']?.toString();
    remarks = json['Remarks']?.toString();
    reciptNo = json['ReciptNo']?.toString();
    schoolAddress = json['SchoolAddress']?.toString();
    schoolBlock = json['SchoolBlock']?.toString();
    schoolDistrict = json['SchoolDistrict']?.toString();
    collectedByInoffice = json['CollectedByInoffice']?.toString();
    createDate = json['CreateDate']?.toString();
    paymentmode = json['Paymentmode']?.toString();
    createdBy = json['CreatedBy']?.toString();
    collectedByInOfficeEmpid = json['CollectedByInOfficeEmpid']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'SchoolName': schoolName,
      'SchoolId': schoolId,
      'Amount': amount,
      'RecivedByFromSchool': recivedByFromSchool,
      'ReciverEmpId': reciverEmpId,
      'PayMentDate': payMentDate,
      'Status': status,
      'Remarks': remarks,
      'ReciptNo': reciptNo,
      'SchoolAddress': schoolAddress,
      'SchoolBlock': schoolBlock,
      'SchoolDistrict': schoolDistrict,
      'CollectedByInoffice': collectedByInoffice,
      'CreateDate': createDate,
      'Paymentmode': paymentmode,
      'CreatedBy': createdBy,
      'CollectedByInOfficeEmpid': collectedByInOfficeEmpid,
    };
  }
}

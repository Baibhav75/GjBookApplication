class SchoolDiscountAgreementModel {
  final String? partyName;
  final String? address;
  final String? district;
  final String? block;
  final String? area;

  final String? manageName;
  final String? managerContact;
  final String? managerDOB;
  final String? managerAnniversary;

  final String? principalName;
  final String? principalContact;
  final String? principalDOB;
  final String? principalAnniversary;

  final String? agentName;
  final String? agentContact;
  final String? agentDOB;
  final String? agentAnniversary;

  final String? areaManagerName;
  final String? areaManagerContact;
  final String? areaManagerDOB;
  final String? areaManagerAnniversary;

  final String? orderDate;
  final String? deliveryDate;

  final String? schoolPanNo;
  final String? schoolAdharNo;

  final String? schoolAccountNo;
  final String? schoolBankDetail;
  final String? chequeNo;
  final String? securiyCheck;

  final String? type;
  final String? schoolType;
  final String? fileNo;
  final String? remarks;
  final String? createdBy;


  /// 🔥 IMPORTANT FIX
  final String? schoolId;   // was int
  final String? agentId;    // was int

  /// 🔥 NEW SIGNATURE FIELDS
  final String? partySignatureBase64;
  final String? managerSignatureBase64;

  final Map<String, String?> monthlyPayments;
  final List<String?> discountSlabs;

  SchoolDiscountAgreementModel({
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
    this.schoolAccountNo,
    this.schoolBankDetail,
    this.chequeNo,
    this.securiyCheck,
    this.type,
    this.schoolType,
    this.fileNo,
    this.remarks,
    this.createdBy,
    this.schoolId,
    this.agentId,
    this.partySignatureBase64,
    this.managerSignatureBase64,
    required this.monthlyPayments,
    required this.discountSlabs,
  });

  Map<String, dynamic> toJson() {
    return {
      "PartyName": partyName,
      "Address": address,
      "District": district,
      "Block": block,
      "Area": area,

      "ManageName": manageName,
      "ManagerContact": managerContact,
      "Manager_DOB": managerDOB,
      "Manager_Anniversary": managerAnniversary,

      "Principal_Name": principalName,
      "Principal_Contact": principalContact,
      "Principal_DOB": principalDOB,
      "Principal_Anniversary": principalAnniversary,

      "AgentName": agentName,
      "AgentContact": agentContact,
      "Agent_DOB": agentDOB,
      "Agent_Anniversary": agentAnniversary,

      "AreaManagerName": areaManagerName,
      "AreaManager_Contact": areaManagerContact,
      "AreaManager_DOB": areaManagerDOB,
      "AreaManager_Anniversary": areaManagerAnniversary,

      "OrderDate": orderDate,
      "DeliveryDate": deliveryDate,

      "SchoolPanNo": schoolPanNo,
      "SchoolAdhar_No": schoolAdharNo,

      "School_AccountNo": schoolAccountNo,
      "School_BankDetail": schoolBankDetail,
      "Cheque_No": chequeNo,
      "Securiy_Check": securiyCheck,

      "Type": type,
      "SchoolType": schoolType,
      "FileNo": fileNo,
      "Remarks": remarks,
      "CreatedBy": createdBy,

      /// IDs
      "SchoolId": schoolId,
      "AgentId": agentId,

      /// 🔥 SIGNATURE
      "Party_Signature": partySignatureBase64,
      "Manager_Signature": managerSignatureBase64,

      /// Monthly Payments
      "January_Payment": monthlyPayments["January"],
      "February_Payment": monthlyPayments["February"],
      "March_Payment": monthlyPayments["March"],
      "April_Payment": monthlyPayments["April"],
      "May_Payment": monthlyPayments["May"],
      "June_Payment": monthlyPayments["June"],
      "July_Payment": monthlyPayments["July"],
      "August_Payment": monthlyPayments["August"],
      "September_Payment": monthlyPayments["September"],
      "October_Payment": monthlyPayments["October"],
      "November_Payment": monthlyPayments["November"],
      "December_Payment": monthlyPayments["December"],

      /// Discount Slabs
      for (int i = 0; i < discountSlabs.length; i++)
        "Discount_Slab${i + 1}": discountSlabs[i],
    };
  }
}

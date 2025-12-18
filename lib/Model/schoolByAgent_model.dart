class schoolByAgent_model {
  bool? success;
  List<Data>? data;

  schoolByAgent_model({this.success, this.data});

  schoolByAgent_model.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? schoolName;
  String? schoolAddress;
  String? district;
  String? tahsil;
  String? block;
  String? village;
  String? mobile;
  String? prabandhakName;
  String? prabandhakMobile;
  String? prabandhakAddress;
  String? principalName;
  String? principalMobile;
  String? principalAddress;
  int? schoolEstablishYear;
  String? schoolType;
  String? schoolMedium;
  String? boardAffiliation;
  bool? hasBranch;
  String? branchDetail;
  Null? areaType;
  String? nearbySchool;
  int? nursary;
  int? lKG;
  int? uKG;
  int? class1;
  int? class2;
  int? class3;
  int? class4;
  int? class5;
  int? class6;
  int? class7;
  int? class8;
  int? class9;
  int? class10;
  int? class11;
  int? class12;
  int? allTotal;
  bool? willChangeBookList;
  String? bookSaleMethod;
  String? bookSellerName;
  String? bookSellerMobile;
  String? publisherName;
  String? previousPublisher;
  String? schoolGrade;
  String? schoolPhoto;
  String? schoolLocation;
  String? guardName;
  String? accountantName;
  String? accountantNumber;
  String? schoolAdminName;
  String? schoolAdminNumber;
  String? principalHouseAddress;
  String? principalEmailId;
  String? schoolOwnerName;
  String? schoolOwnerHouseAddress;
  String? schoolOwnerLocation;
  String? schoolOwnerEmailId;
  String? createdDate;
  String? nurseryTeacher;
  String? nurserySubject;
  String? nurseryMobile;
  Null? lKGTeacher;
  Null? lKGSubject;
  Null? lKGMobile;
  Null? uKGTeacher;
  Null? uKGSubject;
  Null? uKGMobile;
  Null? class1Teacher;
  Null? class1Subject;
  Null? class1Mobile;
  Null? class2Teacher;
  Null? class2Subject;
  Null? class2Mobile;
  Null? class3Teacher;
  Null? class3Subject;
  Null? class3Mobile;
  Null? class4Teacher;
  Null? class4Subject;
  Null? class4Mobile;
  Null? class5Teacher;
  Null? class5Subject;
  Null? class5Mobile;
  Null? class6Teacher;
  Null? class6Subject;
  Null? class6Mobile;
  Null? class7Teacher;
  Null? class7Subject;
  Null? class7Mobile;
  Null? class8Teacher;
  Null? class8Subject;
  Null? class8Mobile;
  Null? class9Teacher;
  Null? class9Subject;
  Null? class9Mobile;
  Null? class10Teacher;
  Null? class10Subject;
  Null? class10Mobile;
  Null? class11Teacher;
  Null? class11Subject;
  Null? class11Mobile;
  Null? class12Teacher;
  Null? class12Subject;
  Null? class12Mobile;
  String? rentalOrOwnSchool;
  String? areaOfSchool;
  String? playgoundArea;
  String? totalLab;
  String? conferenceHall;
  String? schoolBuildingFloor;
  String? classRoom;
  String? chemistryLab;
  String? biologyLab;
  String? compositeScienceLab;
  String? computerLab;
  String? mathLab;
  String? library;
  Null? toiletOnEveryFloorBoysOrGirls;
  String? toiletOnEveryFloor;
  String? drinkingWaterFacilityFloorwise;
  String? rampOrLift;
  String? indoorGameRoom;
  String? musicActivityRoom;
  String? infirmaryRoom;
  String? principalRoom;
  String? managementRoom;
  String? staffRoom;
  String? officeRoom;
  String? wellnessRoom;
  String? agentId;
  String? agentName;
  String? accountDetail;
  String? howManyYearsForDealers;
  String? strengthOfLowStudentsAndWhy;
  String? nurseryPublication;
  String? lKGPublication;
  String? uKGPublication;
  Null? class1Publication;
  Null? class2Publication;
  Null? class3Publication;
  Null? class4Publication;
  Null? class5Publication;
  Null? class6Publication;
  Null? class7Publication;
  Null? class8Publication;
  Null? class9Publication;
  Null? class10Publication;
  Null? class11Publication;
  Null? class12Publication;
  String? directorWakeupTime;
  String? directorSleepingTime;
  String? directorCallTime;
  String? principalWakeupTime;
  String? principalSleepingTime;
  String? nursaryToUkgFee;
  String? nursaryToUkgYeary;
  String? clas1ToClass5Fee;
  Null? clas1ToClass5FeeYearly;
  Null? class6ToClsas8Fee;
  Null? class6ToClsas8FeeYearly;
  Null? class9ToClass10Fee;
  Null? class9ToClass10FeeYearly;
  Null? class11ToClass12Fee;
  Null? class11ToClass12FeeYearly;

  Data(
      {this.id,
        this.schoolName,
        this.schoolAddress,
        this.district,
        this.tahsil,
        this.block,
        this.village,
        this.mobile,
        this.prabandhakName,
        this.prabandhakMobile,
        this.prabandhakAddress,
        this.principalName,
        this.principalMobile,
        this.principalAddress,
        this.schoolEstablishYear,
        this.schoolType,
        this.schoolMedium,
        this.boardAffiliation,
        this.hasBranch,
        this.branchDetail,
        this.areaType,
        this.nearbySchool,
        this.nursary,
        this.lKG,
        this.uKG,
        this.class1,
        this.class2,
        this.class3,
        this.class4,
        this.class5,
        this.class6,
        this.class7,
        this.class8,
        this.class9,
        this.class10,
        this.class11,
        this.class12,
        this.allTotal,
        this.willChangeBookList,
        this.bookSaleMethod,
        this.bookSellerName,
        this.bookSellerMobile,
        this.publisherName,
        this.previousPublisher,
        this.schoolGrade,
        this.schoolPhoto,
        this.schoolLocation,
        this.guardName,
        this.accountantName,
        this.accountantNumber,
        this.schoolAdminName,
        this.schoolAdminNumber,
        this.principalHouseAddress,
        this.principalEmailId,
        this.schoolOwnerName,
        this.schoolOwnerHouseAddress,
        this.schoolOwnerLocation,
        this.schoolOwnerEmailId,
        this.createdDate,
        this.nurseryTeacher,
        this.nurserySubject,
        this.nurseryMobile,
        this.lKGTeacher,
        this.lKGSubject,
        this.lKGMobile,
        this.uKGTeacher,
        this.uKGSubject,
        this.uKGMobile,
        this.class1Teacher,
        this.class1Subject,
        this.class1Mobile,
        this.class2Teacher,
        this.class2Subject,
        this.class2Mobile,
        this.class3Teacher,
        this.class3Subject,
        this.class3Mobile,
        this.class4Teacher,
        this.class4Subject,
        this.class4Mobile,
        this.class5Teacher,
        this.class5Subject,
        this.class5Mobile,
        this.class6Teacher,
        this.class6Subject,
        this.class6Mobile,
        this.class7Teacher,
        this.class7Subject,
        this.class7Mobile,
        this.class8Teacher,
        this.class8Subject,
        this.class8Mobile,
        this.class9Teacher,
        this.class9Subject,
        this.class9Mobile,
        this.class10Teacher,
        this.class10Subject,
        this.class10Mobile,
        this.class11Teacher,
        this.class11Subject,
        this.class11Mobile,
        this.class12Teacher,
        this.class12Subject,
        this.class12Mobile,
        this.rentalOrOwnSchool,
        this.areaOfSchool,
        this.playgoundArea,
        this.totalLab,
        this.conferenceHall,
        this.schoolBuildingFloor,
        this.classRoom,
        this.chemistryLab,
        this.biologyLab,
        this.compositeScienceLab,
        this.computerLab,
        this.mathLab,
        this.library,
        this.toiletOnEveryFloorBoysOrGirls,
        this.toiletOnEveryFloor,
        this.drinkingWaterFacilityFloorwise,
        this.rampOrLift,
        this.indoorGameRoom,
        this.musicActivityRoom,
        this.infirmaryRoom,
        this.principalRoom,
        this.managementRoom,
        this.staffRoom,
        this.officeRoom,
        this.wellnessRoom,
        this.agentId,
        this.agentName,
        this.accountDetail,
        this.howManyYearsForDealers,
        this.strengthOfLowStudentsAndWhy,
        this.nurseryPublication,
        this.lKGPublication,
        this.uKGPublication,
        this.class1Publication,
        this.class2Publication,
        this.class3Publication,
        this.class4Publication,
        this.class5Publication,
        this.class6Publication,
        this.class7Publication,
        this.class8Publication,
        this.class9Publication,
        this.class10Publication,
        this.class11Publication,
        this.class12Publication,
        this.directorWakeupTime,
        this.directorSleepingTime,
        this.directorCallTime,
        this.principalWakeupTime,
        this.principalSleepingTime,
        this.nursaryToUkgFee,
        this.nursaryToUkgYeary,
        this.clas1ToClass5Fee,
        this.clas1ToClass5FeeYearly,
        this.class6ToClsas8Fee,
        this.class6ToClsas8FeeYearly,
        this.class9ToClass10Fee,
        this.class9ToClass10FeeYearly,
        this.class11ToClass12Fee,
        this.class11ToClass12FeeYearly});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    schoolName = json['SchoolName'];
    schoolAddress = json['SchoolAddress'];
    district = json['District'];
    tahsil = json['Tahsil'];
    block = json['Block'];
    village = json['Village'];
    mobile = json['Mobile'];
    prabandhakName = json['PrabandhakName'];
    prabandhakMobile = json['PrabandhakMobile'];
    prabandhakAddress = json['PrabandhakAddress'];
    principalName = json['PrincipalName'];
    principalMobile = json['PrincipalMobile'];
    principalAddress = json['PrincipalAddress'];
    schoolEstablishYear = json['SchoolEstablishYear'];
    schoolType = json['SchoolType'];
    schoolMedium = json['SchoolMedium'];
    boardAffiliation = json['BoardAffiliation'];
    hasBranch = json['HasBranch'];
    branchDetail = json['BranchDetail'];
    areaType = json['AreaType'];
    nearbySchool = json['NearbySchool'];
    nursary = json['Nursary'];
    lKG = json['LKG'];
    uKG = json['UKG'];
    class1 = json['Class1'];
    class2 = json['Class2'];
    class3 = json['Class3'];
    class4 = json['Class4'];
    class5 = json['Class5'];
    class6 = json['Class6'];
    class7 = json['Class7'];
    class8 = json['Class8'];
    class9 = json['Class9'];
    class10 = json['Class10'];
    class11 = json['Class11'];
    class12 = json['Class12'];
    allTotal = json['AllTotal'];
    willChangeBookList = json['WillChangeBookList'];
    bookSaleMethod = json['BookSaleMethod'];
    bookSellerName = json['BookSellerName'];
    bookSellerMobile = json['BookSellerMobile'];
    publisherName = json['PublisherName'];
    previousPublisher = json['PreviousPublisher'];
    schoolGrade = json['SchoolGrade'];
    schoolPhoto = json['SchoolPhoto'];
    schoolLocation = json['SchoolLocation'];
    guardName = json['GuardName'];
    accountantName = json['AccountantName'];
    accountantNumber = json['AccountantNumber'];
    schoolAdminName = json['SchoolAdminName'];
    schoolAdminNumber = json['SchoolAdminNumber'];
    principalHouseAddress = json['PrincipalHouseAddress'];
    principalEmailId = json['PrincipalEmailId'];
    schoolOwnerName = json['SchoolOwnerName'];
    schoolOwnerHouseAddress = json['SchoolOwnerHouseAddress'];
    schoolOwnerLocation = json['SchoolOwnerLocation'];
    schoolOwnerEmailId = json['SchoolOwnerEmailId'];
    createdDate = json['CreatedDate'];
    nurseryTeacher = json['NurseryTeacher'];
    nurserySubject = json['NurserySubject'];
    nurseryMobile = json['NurseryMobile'];
    lKGTeacher = json['LKGTeacher'];
    lKGSubject = json['LKGSubject'];
    lKGMobile = json['LKGMobile'];
    uKGTeacher = json['UKGTeacher'];
    uKGSubject = json['UKGSubject'];
    uKGMobile = json['UKGMobile'];
    class1Teacher = json['Class1Teacher'];
    class1Subject = json['Class1Subject'];
    class1Mobile = json['Class1Mobile'];
    class2Teacher = json['Class2Teacher'];
    class2Subject = json['Class2Subject'];
    class2Mobile = json['Class2Mobile'];
    class3Teacher = json['Class3Teacher'];
    class3Subject = json['Class3Subject'];
    class3Mobile = json['Class3Mobile'];
    class4Teacher = json['Class4Teacher'];
    class4Subject = json['Class4Subject'];
    class4Mobile = json['Class4Mobile'];
    class5Teacher = json['Class5Teacher'];
    class5Subject = json['Class5Subject'];
    class5Mobile = json['Class5Mobile'];
    class6Teacher = json['Class6Teacher'];
    class6Subject = json['Class6Subject'];
    class6Mobile = json['Class6Mobile'];
    class7Teacher = json['Class7Teacher'];
    class7Subject = json['Class7Subject'];
    class7Mobile = json['Class7Mobile'];
    class8Teacher = json['Class8Teacher'];
    class8Subject = json['Class8Subject'];
    class8Mobile = json['Class8Mobile'];
    class9Teacher = json['Class9Teacher'];
    class9Subject = json['Class9Subject'];
    class9Mobile = json['Class9Mobile'];
    class10Teacher = json['Class10Teacher'];
    class10Subject = json['Class10Subject'];
    class10Mobile = json['Class10Mobile'];
    class11Teacher = json['Class11Teacher'];
    class11Subject = json['Class11Subject'];
    class11Mobile = json['Class11Mobile'];
    class12Teacher = json['Class12Teacher'];
    class12Subject = json['Class12Subject'];
    class12Mobile = json['Class12Mobile'];
    rentalOrOwnSchool = json['RentalOrOwnSchool'];
    areaOfSchool = json['AreaOfSchool'];
    playgoundArea = json['PlaygoundArea'];
    totalLab = json['TotalLab'];
    conferenceHall = json['ConferenceHall'];
    schoolBuildingFloor = json['SchoolBuildingFloor'];
    classRoom = json['ClassRoom'];
    chemistryLab = json['ChemistryLab'];
    biologyLab = json['BiologyLab'];
    compositeScienceLab = json['CompositeScienceLab'];
    computerLab = json['ComputerLab'];
    mathLab = json['MathLab'];
    library = json['Library'];
    toiletOnEveryFloorBoysOrGirls = json['ToiletOnEveryFloorBoysOrGirls'];
    toiletOnEveryFloor = json['ToiletOnEveryFloor'];
    drinkingWaterFacilityFloorwise = json['DrinkingWaterFacilityFloorwise'];
    rampOrLift = json['RampOrLift'];
    indoorGameRoom = json['IndoorGameRoom'];
    musicActivityRoom = json['MusicActivityRoom'];
    infirmaryRoom = json['InfirmaryRoom'];
    principalRoom = json['PrincipalRoom'];
    managementRoom = json['ManagementRoom'];
    staffRoom = json['StaffRoom'];
    officeRoom = json['OfficeRoom'];
    wellnessRoom = json['WellnessRoom'];
    agentId = json['AgentId'];
    agentName = json['AgentName'];
    accountDetail = json['AccountDetail'];
    howManyYearsForDealers = json['HowManyYearsForDealers'];
    strengthOfLowStudentsAndWhy = json['StrengthOfLowStudentsAndWhy'];
    nurseryPublication = json['NurseryPublication'];
    lKGPublication = json['LKGPublication'];
    uKGPublication = json['UKGPublication'];
    class1Publication = json['Class1Publication'];
    class2Publication = json['Class2Publication'];
    class3Publication = json['Class3Publication'];
    class4Publication = json['Class4Publication'];
    class5Publication = json['Class5Publication'];
    class6Publication = json['Class6Publication'];
    class7Publication = json['Class7Publication'];
    class8Publication = json['Class8Publication'];
    class9Publication = json['Class9Publication'];
    class10Publication = json['Class10Publication'];
    class11Publication = json['Class11Publication'];
    class12Publication = json['Class12Publication'];
    directorWakeupTime = json['DirectorWakeupTime'];
    directorSleepingTime = json['DirectorSleepingTime'];
    directorCallTime = json['DirectorCallTime'];
    principalWakeupTime = json['PrincipalWakeupTime'];
    principalSleepingTime = json['PrincipalSleepingTime'];
    nursaryToUkgFee = json['NursaryToUkgFee'];
    nursaryToUkgYeary = json['NursaryToUkgYeary'];
    clas1ToClass5Fee = json['Clas1ToClass5Fee'];
    clas1ToClass5FeeYearly = json['Clas1ToClass5FeeYearly'];
    class6ToClsas8Fee = json['Class6ToClsas8Fee'];
    class6ToClsas8FeeYearly = json['Class6ToClsas8FeeYearly'];
    class9ToClass10Fee = json['Class9ToClass10Fee'];
    class9ToClass10FeeYearly = json['Class9ToClass10FeeYearly'];
    class11ToClass12Fee = json['Class11ToClass12Fee'];
    class11ToClass12FeeYearly = json['Class11ToClass12FeeYearly'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['SchoolName'] = this.schoolName;
    data['SchoolAddress'] = this.schoolAddress;
    data['District'] = this.district;
    data['Tahsil'] = this.tahsil;
    data['Block'] = this.block;
    data['Village'] = this.village;
    data['Mobile'] = this.mobile;
    data['PrabandhakName'] = this.prabandhakName;
    data['PrabandhakMobile'] = this.prabandhakMobile;
    data['PrabandhakAddress'] = this.prabandhakAddress;
    data['PrincipalName'] = this.principalName;
    data['PrincipalMobile'] = this.principalMobile;
    data['PrincipalAddress'] = this.principalAddress;
    data['SchoolEstablishYear'] = this.schoolEstablishYear;
    data['SchoolType'] = this.schoolType;
    data['SchoolMedium'] = this.schoolMedium;
    data['BoardAffiliation'] = this.boardAffiliation;
    data['HasBranch'] = this.hasBranch;
    data['BranchDetail'] = this.branchDetail;
    data['AreaType'] = this.areaType;
    data['NearbySchool'] = this.nearbySchool;
    data['Nursary'] = this.nursary;
    data['LKG'] = this.lKG;
    data['UKG'] = this.uKG;
    data['Class1'] = this.class1;
    data['Class2'] = this.class2;
    data['Class3'] = this.class3;
    data['Class4'] = this.class4;
    data['Class5'] = this.class5;
    data['Class6'] = this.class6;
    data['Class7'] = this.class7;
    data['Class8'] = this.class8;
    data['Class9'] = this.class9;
    data['Class10'] = this.class10;
    data['Class11'] = this.class11;
    data['Class12'] = this.class12;
    data['AllTotal'] = this.allTotal;
    data['WillChangeBookList'] = this.willChangeBookList;
    data['BookSaleMethod'] = this.bookSaleMethod;
    data['BookSellerName'] = this.bookSellerName;
    data['BookSellerMobile'] = this.bookSellerMobile;
    data['PublisherName'] = this.publisherName;
    data['PreviousPublisher'] = this.previousPublisher;
    data['SchoolGrade'] = this.schoolGrade;
    data['SchoolPhoto'] = this.schoolPhoto;
    data['SchoolLocation'] = this.schoolLocation;
    data['GuardName'] = this.guardName;
    data['AccountantName'] = this.accountantName;
    data['AccountantNumber'] = this.accountantNumber;
    data['SchoolAdminName'] = this.schoolAdminName;
    data['SchoolAdminNumber'] = this.schoolAdminNumber;
    data['PrincipalHouseAddress'] = this.principalHouseAddress;
    data['PrincipalEmailId'] = this.principalEmailId;
    data['SchoolOwnerName'] = this.schoolOwnerName;
    data['SchoolOwnerHouseAddress'] = this.schoolOwnerHouseAddress;
    data['SchoolOwnerLocation'] = this.schoolOwnerLocation;
    data['SchoolOwnerEmailId'] = this.schoolOwnerEmailId;
    data['CreatedDate'] = this.createdDate;
    data['NurseryTeacher'] = this.nurseryTeacher;
    data['NurserySubject'] = this.nurserySubject;
    data['NurseryMobile'] = this.nurseryMobile;
    data['LKGTeacher'] = this.lKGTeacher;
    data['LKGSubject'] = this.lKGSubject;
    data['LKGMobile'] = this.lKGMobile;
    data['UKGTeacher'] = this.uKGTeacher;
    data['UKGSubject'] = this.uKGSubject;
    data['UKGMobile'] = this.uKGMobile;
    data['Class1Teacher'] = this.class1Teacher;
    data['Class1Subject'] = this.class1Subject;
    data['Class1Mobile'] = this.class1Mobile;
    data['Class2Teacher'] = this.class2Teacher;
    data['Class2Subject'] = this.class2Subject;
    data['Class2Mobile'] = this.class2Mobile;
    data['Class3Teacher'] = this.class3Teacher;
    data['Class3Subject'] = this.class3Subject;
    data['Class3Mobile'] = this.class3Mobile;
    data['Class4Teacher'] = this.class4Teacher;
    data['Class4Subject'] = this.class4Subject;
    data['Class4Mobile'] = this.class4Mobile;
    data['Class5Teacher'] = this.class5Teacher;
    data['Class5Subject'] = this.class5Subject;
    data['Class5Mobile'] = this.class5Mobile;
    data['Class6Teacher'] = this.class6Teacher;
    data['Class6Subject'] = this.class6Subject;
    data['Class6Mobile'] = this.class6Mobile;
    data['Class7Teacher'] = this.class7Teacher;
    data['Class7Subject'] = this.class7Subject;
    data['Class7Mobile'] = this.class7Mobile;
    data['Class8Teacher'] = this.class8Teacher;
    data['Class8Subject'] = this.class8Subject;
    data['Class8Mobile'] = this.class8Mobile;
    data['Class9Teacher'] = this.class9Teacher;
    data['Class9Subject'] = this.class9Subject;
    data['Class9Mobile'] = this.class9Mobile;
    data['Class10Teacher'] = this.class10Teacher;
    data['Class10Subject'] = this.class10Subject;
    data['Class10Mobile'] = this.class10Mobile;
    data['Class11Teacher'] = this.class11Teacher;
    data['Class11Subject'] = this.class11Subject;
    data['Class11Mobile'] = this.class11Mobile;
    data['Class12Teacher'] = this.class12Teacher;
    data['Class12Subject'] = this.class12Subject;
    data['Class12Mobile'] = this.class12Mobile;
    data['RentalOrOwnSchool'] = this.rentalOrOwnSchool;
    data['AreaOfSchool'] = this.areaOfSchool;
    data['PlaygoundArea'] = this.playgoundArea;
    data['TotalLab'] = this.totalLab;
    data['ConferenceHall'] = this.conferenceHall;
    data['SchoolBuildingFloor'] = this.schoolBuildingFloor;
    data['ClassRoom'] = this.classRoom;
    data['ChemistryLab'] = this.chemistryLab;
    data['BiologyLab'] = this.biologyLab;
    data['CompositeScienceLab'] = this.compositeScienceLab;
    data['ComputerLab'] = this.computerLab;
    data['MathLab'] = this.mathLab;
    data['Library'] = this.library;
    data['ToiletOnEveryFloorBoysOrGirls'] = this.toiletOnEveryFloorBoysOrGirls;
    data['ToiletOnEveryFloor'] = this.toiletOnEveryFloor;
    data['DrinkingWaterFacilityFloorwise'] =
        this.drinkingWaterFacilityFloorwise;
    data['RampOrLift'] = this.rampOrLift;
    data['IndoorGameRoom'] = this.indoorGameRoom;
    data['MusicActivityRoom'] = this.musicActivityRoom;
    data['InfirmaryRoom'] = this.infirmaryRoom;
    data['PrincipalRoom'] = this.principalRoom;
    data['ManagementRoom'] = this.managementRoom;
    data['StaffRoom'] = this.staffRoom;
    data['OfficeRoom'] = this.officeRoom;
    data['WellnessRoom'] = this.wellnessRoom;
    data['AgentId'] = this.agentId;
    data['AgentName'] = this.agentName;
    data['AccountDetail'] = this.accountDetail;
    data['HowManyYearsForDealers'] = this.howManyYearsForDealers;
    data['StrengthOfLowStudentsAndWhy'] = this.strengthOfLowStudentsAndWhy;
    data['NurseryPublication'] = this.nurseryPublication;
    data['LKGPublication'] = this.lKGPublication;
    data['UKGPublication'] = this.uKGPublication;
    data['Class1Publication'] = this.class1Publication;
    data['Class2Publication'] = this.class2Publication;
    data['Class3Publication'] = this.class3Publication;
    data['Class4Publication'] = this.class4Publication;
    data['Class5Publication'] = this.class5Publication;
    data['Class6Publication'] = this.class6Publication;
    data['Class7Publication'] = this.class7Publication;
    data['Class8Publication'] = this.class8Publication;
    data['Class9Publication'] = this.class9Publication;
    data['Class10Publication'] = this.class10Publication;
    data['Class11Publication'] = this.class11Publication;
    data['Class12Publication'] = this.class12Publication;
    data['DirectorWakeupTime'] = this.directorWakeupTime;
    data['DirectorSleepingTime'] = this.directorSleepingTime;
    data['DirectorCallTime'] = this.directorCallTime;
    data['PrincipalWakeupTime'] = this.principalWakeupTime;
    data['PrincipalSleepingTime'] = this.principalSleepingTime;
    data['NursaryToUkgFee'] = this.nursaryToUkgFee;
    data['NursaryToUkgYeary'] = this.nursaryToUkgYeary;
    data['Clas1ToClass5Fee'] = this.clas1ToClass5Fee;
    data['Clas1ToClass5FeeYearly'] = this.clas1ToClass5FeeYearly;
    data['Class6ToClsas8Fee'] = this.class6ToClsas8Fee;
    data['Class6ToClsas8FeeYearly'] = this.class6ToClsas8FeeYearly;
    data['Class9ToClass10Fee'] = this.class9ToClass10Fee;
    data['Class9ToClass10FeeYearly'] = this.class9ToClass10FeeYearly;
    data['Class11ToClass12Fee'] = this.class11ToClass12Fee;
    data['Class11ToClass12FeeYearly'] = this.class11ToClass12FeeYearly;
    return data;
  }
}

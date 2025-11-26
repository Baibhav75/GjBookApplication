class SchoolSurveyModel {
  String? agentId;
  String? agentName;

  String? schoolName;
  String? schoolAddress;
  String? district;
  String? tahsil;
  String? block;
  String? village;
  String? mobile;

  String? schoolType;
  String? schoolMedium;
  String? boardAffiliation;

  String? schoolPhotoPath; // local path for multipart

  SchoolSurveyModel({
    this.agentId,
    this.agentName,
    this.schoolName,
    this.schoolAddress,
    this.district,
    this.tahsil,
    this.block,
    this.village,
    this.mobile,
    this.schoolType,
    this.schoolMedium,
    this.boardAffiliation,
    this.schoolPhotoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      "AgentId": agentId,
      "AgentName": agentName,
      "SchoolName": schoolName,
      "SchoolAddress": schoolAddress,
      "District": district,
      "Tahsil": tahsil,
      "Block": block,
      "Village": village,
      "Mobile": mobile,
      "SchoolType": schoolType,
      "SchoolMedium": schoolMedium,
      "BoardAffiliation": boardAffiliation,
    };
  }
}

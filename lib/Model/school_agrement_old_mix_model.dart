class SchoolAgrementOldMixResponse {
  final bool status;
  final String message;
  final List<SchoolAgrementOldMix> data;

  SchoolAgrementOldMixResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SchoolAgrementOldMixResponse.fromJson(Map<String, dynamic> json) {
    return SchoolAgrementOldMixResponse(
      status: json['Status'],
      message: json['Message'],
      data: (json['Data'] as List)
          .map((e) => SchoolAgrementOldMix.fromJson(e))
          .toList(),
    );
  }
}

class SchoolAgrementOldMix {
  final int id;
  final String schoolName;
  final DateTime createDate;
  final String agrementImage;
  final String oldMixImage;

  SchoolAgrementOldMix({
    required this.id,
    required this.schoolName,
    required this.createDate,
    required this.agrementImage,
    required this.oldMixImage,
  });

  factory SchoolAgrementOldMix.fromJson(Map<String, dynamic> json) {
    return SchoolAgrementOldMix(
      id: json['id'],
      schoolName: json['SchoolName'],
      createDate: DateTime.parse(json['CreateDate']),
      agrementImage: json['AgrementImage'],
      oldMixImage: json['OldMixImage'],
    );
  }
}

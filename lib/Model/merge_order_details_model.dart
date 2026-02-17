class MergeOrderDetailsModel {
  final String publication;
  final String series;
  final String subject;
  final String bookName;
  final int nU;
  final int lKG;
  final int uKG;
  final int class1;
  final int class2;
  final int class3;
  final int class4;
  final int class5;
  final int class6;
  final int class7;
  final int class8;
  final int class9;
  final int class10;
  final int class11;
  final int class12;
  final String schoolName;

  MergeOrderDetailsModel({
    required this.publication,
    required this.series,
    required this.subject,
    required this.bookName,
    required this.nU,
    required this.lKG,
    required this.uKG,
    required this.class1,
    required this.class2,
    required this.class3,
    required this.class4,
    required this.class5,
    required this.class6,
    required this.class7,
    required this.class8,
    required this.class9,
    required this.class10,
    required this.class11,
    required this.class12,
    required this.schoolName,
  });

  factory MergeOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      return int.tryParse(value.toString()) ?? 0;
    }

    return MergeOrderDetailsModel(
      publication: json['Publication'] ?? '',
      series: json['Series'] ?? '',
      subject: json['Subject'] ?? '',
      bookName: json['BookName'] ?? '',
      nU: parseInt(json['NU']),
      lKG: parseInt(json['LKG']),
      uKG: parseInt(json['UKG']),
      class1: parseInt(json['I']),
      class2: parseInt(json['II']),
      class3: parseInt(json['III']),
      class4: parseInt(json['IV']),
      class5: parseInt(json['V']),
      class6: parseInt(json['VI']),
      class7: parseInt(json['VII']),
      class8: parseInt(json['VIII']),
      class9: parseInt(json['IX']),
      class10: parseInt(json['X']),
      class11: parseInt(json['XI']),
      class12: parseInt(json['XII']),
      schoolName: json['SchoolName'] ?? '',
    );
  }
}

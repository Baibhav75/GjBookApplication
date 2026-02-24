class CounterDetailsAdminModel {
  final int? id;
  final String? counterId;
  final String? counterName;
  final String? counterBoyName;
  final String? faterName;
  final String? motherName;
  final String? counterBoyPassWord;
  final String? counterBoyMob;
  final String? cancelCheck;
  final String? agreement;
  final String? counterBoyMarkSheet;
  final String? counterBoyAdharCard;
  final String? fatehrAdhar;
  final String? motherAdhar;
  final String? victim1;
  final String? victim2;
  final String? cashLimit;
  final String? victim1Adhar;
  final String? victim2Adhar;
  final String? schoolName;
  final DateTime? createDate;
  final String? schoolId;

  CounterDetailsAdminModel({
    this.id,
    this.counterId,
    this.counterName,
    this.counterBoyName,
    this.faterName,
    this.motherName,
    this.counterBoyPassWord,
    this.counterBoyMob,
    this.cancelCheck,
    this.agreement,
    this.counterBoyMarkSheet,
    this.counterBoyAdharCard,
    this.fatehrAdhar,
    this.motherAdhar,
    this.victim1,
    this.victim2,
    this.cashLimit,
    this.victim1Adhar,
    this.victim2Adhar,
    this.schoolName,
    this.createDate,
    this.schoolId,
  });

  factory CounterDetailsAdminModel.fromJson(Map<String, dynamic> json) {
    return CounterDetailsAdminModel(
      id: json['Id'],
      counterId: json['CounterId'],
      counterName: json['CounterName'],
      counterBoyName: json['CounterBoyName'],
      faterName: json['FaterName'],
      motherName: json['MotherName'],
      counterBoyPassWord: json['CounterBoyPassWord'],
      counterBoyMob: json['CounterBoyMob'],
      cancelCheck: json['CancelCheck'],
      agreement: json['Agreement'],
      counterBoyMarkSheet: json['CounterBoyMarkSheet'],
      counterBoyAdharCard: json['CounterBoyAdharCard'],
      fatehrAdhar: json['FatehrAdhar'],
      motherAdhar: json['MotherAdhar'],
      victim1: json['Victim1'],
      victim2: json['Victim2'],
      cashLimit: json['CashLimit'],
      victim1Adhar: json['Victim1Adhar'],
      victim2Adhar: json['Victim2Adhar'],
      schoolName: json['SchoolName'],
      createDate: json['CreateDate'] != null
          ? DateTime.parse(json['CreateDate'])
          : null,
      schoolId: json['SchoolId'],
    );
  }
}
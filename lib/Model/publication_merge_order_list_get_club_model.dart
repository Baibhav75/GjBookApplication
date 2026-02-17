class PublicationMergeOrderListGetClubModel {
  final int id;
  final String publication;
  final String publicationId;
  final String billNo;

  PublicationMergeOrderListGetClubModel({
    required this.id,
    required this.publication,
    required this.publicationId,
    required this.billNo,
  });

  factory PublicationMergeOrderListGetClubModel.fromJson(
      Map<String, dynamic> json) {
    return PublicationMergeOrderListGetClubModel(
      id: json['id'] ?? 0,
      publication: json['Publication'] ?? '',
      publicationId: json['PublicationId'] ?? '',
      billNo: json['BillNo'] ?? '',
    );
  }
}

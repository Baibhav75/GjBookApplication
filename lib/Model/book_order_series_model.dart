class BookOrderSeriesModel {
  final bool status;
  final String message;
  final List<String> seriesList;

  BookOrderSeriesModel({
    required this.status,
    required this.message,
    required this.seriesList,
  });

  factory BookOrderSeriesModel.fromJson(Map<String, dynamic> json) {
    return BookOrderSeriesModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      seriesList: List<String>.from(json['SeriesList'] ?? []),
    );
  }
}

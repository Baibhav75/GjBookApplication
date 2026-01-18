class BookModel {
  final String series;
  final String title;
  final String bookName;
  final String className;
  final int price;
  int qty;

  BookModel({
    required this.series,
    required this.title,
    required this.bookName,
    required this.className,
    required this.price,
    this.qty = 0,
  });

  int get amount => price * qty;
}

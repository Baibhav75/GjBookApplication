class ViewProductListResponse {
  bool? status;
  String? message;
  List<ProductModel>? productList;

  ViewProductListResponse({
    this.status,
    this.message,
    this.productList,
  });

  factory ViewProductListResponse.fromJson(Map<String, dynamic> json) {
    return ViewProductListResponse(
      status: json['Status'] as bool?,
      message: json['Message']?.toString(),
      productList: json['ProductList'] != null
          ? (json['ProductList'] as List)
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Message': message,
      'ProductList': productList?.map((item) => item.toJson()).toList(),
    };
  }

  bool get isSuccess => status == true;
}

class ProductModel {
  String? series;
  String? itemCode;
  String? itemTitle;
  String? subject;
  double? discount;
  String? publication;
  String? classField;
  double? rateNursery;
  double? rate1;
  double? rate2;
  double? rate3;
  double? rate4;
  double? rate5;
  double? rate6;
  double? rate7;
  double? rate8;
  double? rate9;
  double? rate10;
  double? rate11;
  double? rate12;
  String? createDate;

  ProductModel({
    this.series,
    this.itemCode,
    this.itemTitle,
    this.subject,
    this.discount,
    this.publication,
    this.classField,
    this.rateNursery,
    this.rate1,
    this.rate2,
    this.rate3,
    this.rate4,
    this.rate5,
    this.rate6,
    this.rate7,
    this.rate8,
    this.rate9,
    this.rate10,
    this.rate11,
    this.rate12,
    this.createDate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      series: json['Series']?.toString(),
      itemCode: json['itemCode']?.toString(),
      itemTitle: json['itemtitle']?.toString(),
      subject: json['Subject']?.toString(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      publication: json['Publication']?.toString(),
      classField: json['Class']?.toString(),
      rateNursery: json['Rate_Nursery'] != null ? (json['Rate_Nursery'] as num).toDouble() : null,
      rate1: json['Rate_1'] != null ? (json['Rate_1'] as num).toDouble() : null,
      rate2: json['Rate_2'] != null ? (json['Rate_2'] as num).toDouble() : null,
      rate3: json['Rate_3'] != null ? (json['Rate_3'] as num).toDouble() : null,
      rate4: json['Rate_4'] != null ? (json['Rate_4'] as num).toDouble() : null,
      rate5: json['Rate_5'] != null ? (json['Rate_5'] as num).toDouble() : null,
      rate6: json['Rate_6'] != null ? (json['Rate_6'] as num).toDouble() : null,
      rate7: json['Rate_7'] != null ? (json['Rate_7'] as num).toDouble() : null,
      rate8: json['Rate_8'] != null ? (json['Rate_8'] as num).toDouble() : null,
      rate9: json['Rate_9'] != null ? (json['Rate_9'] as num).toDouble() : null,
      rate10: json['Rate_10'] != null ? (json['Rate_10'] as num).toDouble() : null,
      rate11: json['Rate_11'] != null ? (json['Rate_11'] as num).toDouble() : null,
      rate12: json['Rate_12'] != null ? (json['Rate_12'] as num).toDouble() : null,
      createDate: json['CreateDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Series': series,
      'itemCode': itemCode,
      'itemtitle': itemTitle,
      'Subject': subject,
      'discount': discount,
      'Publication': publication,
      'Class': classField,
      'Rate_Nursery': rateNursery,
      'Rate_1': rate1,
      'Rate_2': rate2,
      'Rate_3': rate3,
      'Rate_4': rate4,
      'Rate_5': rate5,
      'Rate_6': rate6,
      'Rate_7': rate7,
      'Rate_8': rate8,
      'Rate_9': rate9,
      'Rate_10': rate10,
      'Rate_11': rate11,
      'Rate_12': rate12,
      'CreateDate': createDate,
    };
  }

  // Helper method to get a formatted rate display string
  String? getFormattedRate() {
    // Return the first non-null rate found
    if (rateNursery != null) return '₹${rateNursery!.toStringAsFixed(2)}';
    if (rate1 != null) return '₹${rate1!.toStringAsFixed(2)}';
    if (rate2 != null) return '₹${rate2!.toStringAsFixed(2)}';
    if (rate3 != null) return '₹${rate3!.toStringAsFixed(2)}';
    if (rate4 != null) return '₹${rate4!.toStringAsFixed(2)}';
    if (rate5 != null) return '₹${rate5!.toStringAsFixed(2)}';
    if (rate6 != null) return '₹${rate6!.toStringAsFixed(2)}';
    if (rate7 != null) return '₹${rate7!.toStringAsFixed(2)}';
    if (rate8 != null) return '₹${rate8!.toStringAsFixed(2)}';
    if (rate9 != null) return '₹${rate9!.toStringAsFixed(2)}';
    if (rate10 != null) return '₹${rate10!.toStringAsFixed(2)}';
    if (rate11 != null) return '₹${rate11!.toStringAsFixed(2)}';
    if (rate12 != null) return '₹${rate12!.toStringAsFixed(2)}';
    return null;
  }

  // Helper method to get all available rates as a list
  Map<String, double?> getAllRates() {
    return {
      'Nursery': rateNursery,
      'Class 1': rate1,
      'Class 2': rate2,
      'Class 3': rate3,
      'Class 4': rate4,
      'Class 5': rate5,
      'Class 6': rate6,
      'Class 7': rate7,
      'Class 8': rate8,
      'Class 9': rate9,
      'Class 10': rate10,
      'Class 11': rate11,
      'Class 12': rate12,
    };
  }
}
























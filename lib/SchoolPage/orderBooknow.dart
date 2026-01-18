import 'package:flutter/material.dart';
import '../Model/book_order_series_model.dart';
import '../Model/order_book_title_model.dart';
import '../Model/order_book_list_model.dart';
import '../Service/book_order_series_service.dart';
import '../Service/order_book_title_service.dart';
import '../Service/order_book_list_service.dart';

class OrderBookScreen extends StatefulWidget {
  final String mobileNo;

  const OrderBookScreen({
    super.key,
    required this.mobileNo,
  });

  @override
  State<OrderBookScreen> createState() => _OrderBookScreenState();
}

class _OrderBookScreenState extends State<OrderBookScreen> {
  late Future<BookOrderSeriesModel> _seriesFuture;
  Future<OrderBookTitleModel>? _titleFuture;
  Future<OrderBookListModel>? _bookFuture;

  String? selectedSeries;
  String? selectedTitle;

  @override
  void initState() {
    super.initState();

    _seriesFuture =
        BookOrderSeriesService.fetchSeries(ownerMobile: widget.mobileNo);
  }

  /// 🔹 SERIES CHANGE (RESET CHILD STATES)
  void _onSeriesChanged(String series) {
    setState(() {
      selectedSeries = series;

      // 🔴 RESET DEPENDENTS (VERY IMPORTANT)
      selectedTitle = null;
      _bookFuture = null;

      _titleFuture = OrderBookTitleService.fetchTitles(
        ownerMobile: widget.mobileNo,
        series: series,
      );
    });
  }

  /// 🔹 TITLE CHANGE (FINAL API CALL)
  void _onTitleChanged(String title) {
    setState(() {
      selectedTitle = title;

      _bookFuture = OrderBookListService.fetchBooks(
        ownerMobile: widget.mobileNo,
        series: selectedSeries!,
        subject: title,
      );
    });
  }

  double _grandTotal(List<OrderBookItem> books) {
    return books.fold(0, (sum, b) => sum + b.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Book Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: FutureBuilder<BookOrderSeriesModel>(
        future: _seriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.seriesList.isEmpty) {
            return const Center(child: Text('No Series Found'));
          }

          final seriesList = snapshot.data!.seriesList;

          /// ✅ SET DEFAULT SERIES ONLY ONCE
          selectedSeries ??= seriesList.first;

          /// ✅ LOAD TITLES ONLY IF NOT LOADED
          _titleFuture ??= OrderBookTitleService.fetchTitles(
            ownerMobile: widget.mobileNo,
            series: selectedSeries!,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 SERIES & TITLE
                /// 🔹 SERIES DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedSeries,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Series',
                    border: OutlineInputBorder(),
                  ),
                  items: seriesList
                      .map(
                        (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    if (v != null && v != selectedSeries) {
                      _onSeriesChanged(v);
                    }
                  },
                ),

                const SizedBox(height: 16),

                /// 🔹 TITLE DROPDOWN (BELOW SERIES)
                FutureBuilder<OrderBookTitleModel>(
                  future: _titleFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (!snap.hasData ||
                        snap.data!.subjectList.isEmpty) {
                      return DropdownButtonFormField<String>(
                        value: null,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        items: const [],
                        onChanged: null,
                      );
                    }

                    final titles = snap.data!.subjectList;

                    return DropdownButtonFormField<String>(
                      value: selectedTitle,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      items: titles
                          .map(
                            (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: selectedSeries == null
                          ? null
                          : (v) {
                        if (v != null) {
                          _onTitleChanged(v);
                        }
                      },

                    );
                  },
                ),

                const SizedBox(height: 22),


                /// 🔹 BOOK TABLE (ONLY WHEN TITLE IS SELECTED)
                if (_bookFuture != null && selectedTitle != null)
                  FutureBuilder<OrderBookListModel>(
                    future: _bookFuture,
                    builder: (context, snap) {
                      if (snap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snap.hasData || snap.data!.books.isEmpty) {
                        return const Center(child: Text('No Books Found'));
                      }

                      final books = snap.data!.books;

                      return Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              border: TableBorder.all(),
                              columnWidths: const {
                                0: FixedColumnWidth(200),
                                1: FixedColumnWidth(100),
                                2: FixedColumnWidth(80),
                                3: FixedColumnWidth(80),
                                4: FixedColumnWidth(100),
                              },
                              children: [
                                _headerRow(),
                                ...books.map(_dataRow),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Grand Total: ₹${_grandTotal(books).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔹 TABLE HEADER
  TableRow _headerRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFE3F2FD)),
      children: [
        _Cell(text: 'Book Name', bold: true),
        _Cell(text: 'Class', bold: true),
        _Cell(text: 'Qty', bold: true),
        _Cell(text: 'Rate', bold: true),
        _Cell(text: 'Amount', bold: true),
      ],
    );
  }

  /// 🔹 DATA ROW
  TableRow _dataRow(OrderBookItem book) {
    return TableRow(
      children: [
        _Cell(text: book.bookName),
        _Cell(text: book.classes),
        Padding(
          padding: const EdgeInsets.all(6),
          child: TextFormField(
            initialValue: book.qty.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (v) =>
                setState(() => book.qty = int.tryParse(v) ?? 0),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        _Cell(text: book.rate.toStringAsFixed(0)),
        _Cell(text: book.amount.toStringAsFixed(0)),
      ],
    );
  }
}

/// 🔹 CELL WIDGET
class _Cell extends StatelessWidget {
  final String text;
  final bool bold;

  const _Cell({required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

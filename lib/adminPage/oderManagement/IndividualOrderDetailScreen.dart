import 'package:flutter/material.dart';
import '../../Model/individual_order_details_model.dart';
import '../../Service/individual_order_details_service.dart';

class IndividualOrderDetailScreen extends StatefulWidget {
  final String senderId;

  const IndividualOrderDetailScreen({super.key, required this.senderId});

  @override
  State<IndividualOrderDetailScreen> createState() =>
      _IndividualOrderDetailScreenState();
}

class _IndividualOrderDetailScreenState
    extends State<IndividualOrderDetailScreen> {
  late Future<IndividualOrderDetailsResponse> futureData;

  @override
  void initState() {
    super.initState();
    futureData =
        IndividualOrderDetailsService.fetchDetails(widget.senderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text("Individual Order Details"),
      ),
      body: FutureBuilder<IndividualOrderDetailsResponse>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final master = data.master;
          final items = data.items;

          double grandTotal =
          items.fold(0, (sum, item) => sum + item.totalAmount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                /// HEADER
                const Center(
                  child: Text(
                    "GJ BOOK WORLD PVT. LTD.",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                /// ORDER INFO TABLE
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(),
                    defaultColumnWidth:
                    const IntrinsicColumnWidth(),
                    children: [
                      _row3(
                          "Order No : ${master.orderNo}",
                          "Supplier : ${master.publication}",
                          "Date : ${_formatDate(master.date)}"),
                      _row3(
                          "Transport : ${master.transport}",
                          "Address : ${master.address}",
                          "GR No : ${master.grNo ?? '-'}"),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// ITEMS TABLE
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(),
                    defaultColumnWidth:
                    const IntrinsicColumnWidth(),
                    children: [

                      _headerRow(),

                      ...items.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final item = entry.value;

                        return TableRow(
                          children: [
                            _cell("$index"),
                            _cell(item.series),
                            _cell(item.bookName),
                            _cell(item.classes),
                            _cell(item.subject),
                            _cell(item.qty.toString()),
                            _cell("₹ ${item.rate.toStringAsFixed(2)}"),
                            _cell("₹ ${item.totalAmount.toStringAsFixed(2)}"),
                          ],
                        );
                      }),

                      TableRow(
                        decoration:
                        BoxDecoration(color: Colors.blue.shade50),
                        children: [
                          _cell(""),
                          _cell(""),
                          _cell(""),
                          _cell(""),
                          _cell("Grand Total:", bold: true),
                          _cell(""),
                          _cell(""),
                          _cell("₹ ${grandTotal.toStringAsFixed(2)}",
                              bold: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

    );
  }

  /// ================= HELPERS =================

  static TableRow _row3(String a, String b, String c) {
    return TableRow(children: [_cell(a), _cell(b), _cell(c)]);
  }

  static TableRow _headerRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Colors.grey),
      children: [
        _HeaderCell("S.N."),
        _HeaderCell("Series"),
        _HeaderCell("Book Name"),
        _HeaderCell("Class"),
        _HeaderCell("Subject"),
        _HeaderCell("Qty"),
        _HeaderCell("Rate"),
        _HeaderCell("Amount"),
      ],
    );
  }

  static Widget _cell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style:
        TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

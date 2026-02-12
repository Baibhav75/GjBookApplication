import 'package:flutter/material.dart';
import '../../Model/publication_order_details_model.dart';
import '../../Service/publication_order_details_service.dart';

class OrderTrackingDetailPage extends StatefulWidget {
  final String senderId;

  const OrderTrackingDetailPage({
    super.key,
    required this.senderId,
  });

  @override
  State<OrderTrackingDetailPage> createState() =>
      _OrderTrackingDetailPageState();
}

class _OrderTrackingDetailPageState
    extends State<OrderTrackingDetailPage> {
  late Future<PublicationOrderDetailsResponse> futureData;

  @override
  void initState() {
    super.initState();
    futureData =
        PublicationOrderDetailsService.fetchOrderDetails(widget.senderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('Publication Order Details'),
      ),
      body: FutureBuilder<PublicationOrderDetailsResponse>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          final master = data.master;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _title(),
                const SizedBox(height: 12),

                // 🔹 ORDER META TABLE
                _orderInfoTable(master, data.schools),
                const SizedBox(height: 20),

                // 🔹 ITEMS TABLE
                _itemsTable(data.items),
                const SizedBox(height: 12),

                // 🔹 GRAND TOTAL
                _grandTotal(data.grandTotal),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI =================

  Widget _title() => const Text(
    'Publication Order Details',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    ),
  );

  /// Order meta info (SenderId intentionally hidden)
  Widget _orderInfoTable(
      OrderMaster master, List<String> schools) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 900),
        child: Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(4),
            2: FlexColumnWidth(3),
          },
          children: [
            _row3(
              'Supplier: ${master.publicationName}',
              'Transport: ${master.transport}',
              'Date: ${_formatDate(master.date)}',
            ),
            _row3(
              'School: ${schools.isNotEmpty ? schools.first : ''}',
              '',
              '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemsTable(List<OrderItem> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1100),
        child: Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(4),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(3),
            5: FlexColumnWidth(1),
            6: FlexColumnWidth(2),
            7: FlexColumnWidth(2),
          },
          children: [
            _itemsHeader(),
            ...items.asMap().entries.map(
                  (e) => _itemRow(e.key + 1, e.value),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _itemsHeader() => TableRow(
    decoration: BoxDecoration(color: Colors.grey.shade200),
    children:[
      _cell('S.N', bold: true),
      _cell('Series', bold: true),
      _cell('Book Name', bold: true),
      _cell('Class', bold: true),
      _cell('Subject', bold: true),
      _cell('Qty', bold: true),
      _cell('Rate', bold: true),
      _cell('Amount', bold: true),
    ],
  );

  TableRow _itemRow(int sn, OrderItem item) {
    return TableRow(
      children: [
        _cell(sn.toString()),
        _cell(item.series),
        _cell(item.bookName),
        _cell(item.classes),
        _cell(item.subject),
        _cell(item.qty.toString()),
        _cell('₹ ${item.rate.toStringAsFixed(2)}'),
        _cell('₹ ${item.totalAmount.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _grandTotal(double total) => Align(
    alignment: Alignment.centerRight,
    child: Container(
      padding: const EdgeInsets.all(12),
      color: Colors.green.shade100,
      child: Text(
        'Grand Total : ₹ ${total.toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );

  // ================= HELPERS =================

  TableRow _row3(String a, String b, String c) {
    return TableRow(
      children: [
        _cell(a, bold: true),
        _cell(b, bold: true),
        _cell(c, bold: true),
      ],
    );
  }

  static Widget _cell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}

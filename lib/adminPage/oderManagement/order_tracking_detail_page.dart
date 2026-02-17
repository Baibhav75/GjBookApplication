import 'package:flutter/material.dart';
import '../../Model/order_tracking_detail_model.dart';
import '../../Service/order_tracking_detail_service.dart';

class OrderTrackingDetailPage extends StatefulWidget {
  final String senderId;

  const OrderTrackingDetailPage({super.key, required this.senderId});

  @override
  State<OrderTrackingDetailPage> createState() =>
      _OrderTrackingDetailPageState();
}

class _OrderTrackingDetailPageState
    extends State<OrderTrackingDetailPage> {
  late Future<OrderTrackingDetailResponse> futureData;

  @override
  void initState() {
    super.initState();
    futureData =
        OrderTrackingDetailService.fetchDetails(widget.senderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text("Order Details"),
        centerTitle: true,
      ),
      body: FutureBuilder<OrderTrackingDetailResponse>(
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// =========================
                /// 🔹 ORDER SUMMARY CARD
                /// =========================
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Order Summary",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 20),

                        _summaryRow("Supplier", master.publication),
                        _summaryRow("Transport", master.transport),
                        _summaryRow("Date", _formatDate(master.date)),
                        _summaryRow("School", master.schoolName),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// =========================
                /// 🔹 ITEMS TABLE CARD
                /// =========================
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Items",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24,
                            headingRowHeight: 48,
                            dataRowHeight: 52,
                            headingRowColor:
                            MaterialStateProperty.all(
                                Colors.grey.shade800),
                            columns: const [
                              DataColumn(
                                  label: _HeaderText("S.N")),
                              DataColumn(
                                  label: _HeaderText("Book Name")),
                              DataColumn(
                                  label: _HeaderText("Class")),
                              DataColumn(
                                  label: _HeaderText("Subject")),
                              DataColumn(
                                  label: _HeaderText("Series")),
                              DataColumn(
                                  label: _HeaderText("Qty")),
                              DataColumn(
                                  label: _HeaderText("Rate")),
                              DataColumn(
                                  label: _HeaderText("Amount")),
                            ],
                            rows: List.generate(
                              data.items.length,
                                  (index) {
                                final item = data.items[index];
                                return DataRow(
                                  cells: [
                                    DataCell(
                                        _BodyText("${index + 1}")),
                                    DataCell(
                                        _BodyText(item.bookName)),
                                    DataCell(
                                        _BodyText(item.classes)),
                                    DataCell(
                                        _BodyText(item.subject)),
                                    DataCell(
                                        _BodyText(item.series)),
                                    DataCell(
                                        _BodyText(item.qty.toString())),
                                    DataCell(_BodyText(
                                        "₹ ${item.rate.toStringAsFixed(2)}")),
                                    DataCell(_BodyText(
                                        "₹ ${item.totalAmount.toStringAsFixed(2)}")),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Grand Total
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Total Items: ${data.totalShown}",
                              style: const TextStyle(
                                  fontWeight:
                                  FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Summary Row
  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}

/// Header Text Widget
class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Body Text Widget
class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
      ),
    );
  }
}

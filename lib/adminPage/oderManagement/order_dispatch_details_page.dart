import 'package:flutter/material.dart';
import '../../Model/order_dispatch_invoice_model.dart';
import '../../Service/order_dispatch_invoice_service.dart';

class OrderDispatchDetailsPage extends StatefulWidget {
  final String senderId;

  const OrderDispatchDetailsPage({
    super.key,
    required this.senderId,
  });

  @override
  State<OrderDispatchDetailsPage> createState() =>
      _OrderDispatchDetailsPageState();
}

class _OrderDispatchDetailsPageState
    extends State<OrderDispatchDetailsPage> {

  late Future<OrderDispatchInvoiceModel> futureInvoice;

  @override
  void initState() {
    super.initState();
    futureInvoice =
        OrderDispatchInvoiceService.fetchInvoice(widget.senderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text("Publication Order Details"),
      ),
      body: FutureBuilder<OrderDispatchInvoiceModel>(
        future: futureInvoice,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading invoice"));
          }

          final invoice = snapshot.data!;
          final master = invoice.master;
          final items = invoice.items;

          double grandTotal = items.fold(
              0, (sum, item) => sum + item.totalAmount);

          return SingleChildScrollView(
            child: Column(
              children: [

                /// HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: const [
                      Text(
                        "GJ BOOK WORLD PVT. LTD.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "D-1/20, SECTOR 22, GIDA, GORAKHPUR",
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "GST No: 09AACGG6085B1Z2",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const Divider(thickness: 1),

                /// MASTER DETAILS
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text("Order No: ${master.orderNo}"),
                      Text("Publication: ${master.publication}"),
                      Text("GR No: ${master.grNo}"),
                      Text("Bundal: ${master.bundal}"),
                      Text("Transport: ${master.transport}"),
                      Text("Date: ${master.dates.split("T").first}"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// TABLE (Horizontal Scroll)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                    ),
                    child: DataTable(
                      columnSpacing: 25,
                      headingRowColor:
                      MaterialStateProperty.all(
                          Colors.grey.shade300),
                      border: TableBorder.all(
                        color: Colors.grey.shade400,
                      ),
                      columns: const [
                        DataColumn(label: Text("S.N.")),
                        DataColumn(label: Text("Series")),
                        DataColumn(label: Text("Book Name")),
                        DataColumn(label: Text("Class")),
                        DataColumn(label: Text("Subject")),
                        DataColumn(label: Text("Qty")),
                        DataColumn(label: Text("Rate")),
                        DataColumn(label: Text("Amount")),
                      ],
                      rows: List.generate(
                        items.length,
                            (index) {
                          final item = items[index];

                          return DataRow(
                            cells: [
                              DataCell(Text("${index + 1}")),
                              DataCell(Text(item.series)),
                              DataCell(SizedBox(
                                width: 200,
                                child: Text(
                                  item.bookName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                              DataCell(Text(item.classes)),
                              DataCell(Text(item.subject)),
                              DataCell(Text("${item.qty}")),
                              DataCell(Text("₹ ${item.rate}")),
                              DataCell(
                                  Text("₹ ${item.totalAmount}")),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                /// GRAND TOTAL
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    border: Border.all(
                        color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Grand Total: ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹ $grandTotal",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

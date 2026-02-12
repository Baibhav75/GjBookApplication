import 'package:flutter/material.dart';
import '../SellReturn/ViewBookList.dart';
import '../SellReturn/oderExcelSheet.dart';
import '/Model/order_excel_sheet_model.dart';
import '/Service/order_excel_sheet_service.dart';

class OrderExcelSheetPage extends StatefulWidget {
  const OrderExcelSheetPage({super.key});

  @override
  State<OrderExcelSheetPage> createState() => _OrderExcelSheetPageState();
}

class _OrderExcelSheetPageState extends State<OrderExcelSheetPage> {
  late Future<List<OrderExcelSheet>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = OrderExcelSheetService().fetchOrderExcelSheetList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          "Order Excel Sheet List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: FutureBuilder<List<OrderExcelSheet>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          final orders = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor:
                MaterialStateProperty.all(Colors.grey.shade200),
                columnSpacing: 30,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('Sr No')),
                  DataColumn(label: Text('School Name')),
                  DataColumn(label: Text('Bill No')),
                  DataColumn(label: Text('Order Date')),
                  DataColumn(label: Text('Rec Date')),
                  DataColumn(label: Text('Action')),
                ],
                rows: List.generate(orders.length, (index) {
                  final order = orders[index];

                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Text(
                            order.schoolName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(order.billNo)),
                      DataCell(Text(_formatDate(order.dates))),
                      DataCell(Text(_formatDate(order.recDate))),

                      // ✅ ACTION COLUMN (View Button)
                      DataCell(
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'books') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViewBookDetails(
                                    billNo: order.billNo,
                                  ),
                                ),
                              );
                            } else if (value == 'excel') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OderExcelSheet(
                                    billNo: order.billNo,
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'books',
                              child: Row(
                                children: [
                                  Icon(Icons.menu_book, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Book List'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'excel',
                              child: Row(
                                children: [
                                  Icon(Icons.description, size: 18),
                                  SizedBox(width: 8),
                                  Text('Order Excel Sheet'),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple, // 🔵 Blue background
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Date formatter
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}

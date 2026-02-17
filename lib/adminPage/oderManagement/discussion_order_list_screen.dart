import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Model/discussion_order_list_model.dart';
import '../../Service/discussion_order_service.dart';

class DiscussionOrderListScreen extends StatefulWidget {
  const DiscussionOrderListScreen({super.key});

  @override
  State<DiscussionOrderListScreen> createState() =>
      _DiscussionOrderListScreenState();
}

class _DiscussionOrderListScreenState
    extends State<DiscussionOrderListScreen> {
  late Future<List<DiscussionOrderListModel>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = DiscussionOrderService().fetchOrders();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Discussion Order List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<DiscussionOrderListModel>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final orders = snapshot.data ?? [];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              border: TableBorder.all(color: Colors.grey),
              columns: const [
                DataColumn(label: Text("Sr No.")),
                DataColumn(label: Text("Old OrderDate")),
                DataColumn(label: Text("Order Date")),
                DataColumn(label: Text("SchoolType")),
                DataColumn(label: Text("Bill No")),
                DataColumn(label: Text("Party Name")),
                DataColumn(label: Text("CounterSupply")),
                DataColumn(label: Text("AgentName")),
                DataColumn(label: Text("MobileNo")),
                DataColumn(label: Text("OrderStatus")),
                DataColumn(label: Text("Bill Date")),
                DataColumn(label: Text("Action")),
              ],
              rows: List.generate(orders.length, (index) {
                final order = orders[index];

                return DataRow(cells: [
                  DataCell(Text("${index + 1}")),
                  DataCell(Text(formatDate(order.oldOrderDate))),
                  DataCell(Text(formatDate(order.dates))),
                  DataCell(Text(order.schoolType)),
                  DataCell(Text(order.billNo)),
                  DataCell(Text(order.schoolName)),
                  DataCell(Text(order.counterType)),
                  DataCell(Text(order.agentName ?? "-")),
                  DataCell(Text(order.schoolMobileNo)),
                  const DataCell(Text("Pending")), // static
                  DataCell(Text(formatDate(order.recDate))),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () {
                        // View Action
                      },
                    ),
                  ),
                ]);
              }),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../Model/Oder_list_dispatch_model.dart';
import '../../Service/oder_list_dispatch_service.dart';
import 'order_dispatch_details_page.dart'; // 👈 ADD THIS

class OrderListDispatchView extends StatefulWidget {
  const OrderListDispatchView({super.key});

  @override
  State<OrderListDispatchView> createState() =>
      _OrderListDispatchViewState();
}

class _OrderListDispatchViewState
    extends State<OrderListDispatchView> {

  late Future<List<OrderListDispatchModel>> orderFuture;

  @override
  void initState() {
    super.initState();
    orderFuture = OrderListDispatchService.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Dispatch List"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: FutureBuilder<List<OrderListDispatchModel>>(
        future: orderFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading data",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text("No Dispatch Orders Found"),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 25,
                headingRowColor: MaterialStateProperty.all(
                  Colors.deepPurple.shade50,
                ),

                columns: const [
                  DataColumn(label: Text("Sr No")),
                  DataColumn(label: Text("Order No")),
                  DataColumn(label: Text("Publication")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("GR No")),
                  DataColumn(label: Text("Bundal")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Action")),
                ],

                rows: List.generate(
                  orders.length,
                      (index) {
                    final order = orders[index];

                    return DataRow(
                      cells: [

                        DataCell(Text("${index + 1}")),

                        DataCell(Text(order.orderNo)),

                        DataCell(
                          SizedBox(
                            width: 220,
                            child: Text(
                              order.publication,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        const DataCell(
                          Text(
                            "Dispatched",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        DataCell(Text(order.grNo)),

                        DataCell(Text(order.bundal)),

                        DataCell(
                          Text(
                            order.dates.contains("T")
                                ? order.dates.split("T").first
                                : order.dates,
                          ),
                        ),

                        // ✅ VIEW BUTTON WITH senderId PASS
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDispatchDetailsPage(
                                        senderId: order.senderId,
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              "View",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

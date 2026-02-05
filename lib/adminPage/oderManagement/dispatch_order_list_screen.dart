import 'package:flutter/material.dart';
import '../../Model/dispatch_order_list_model.dart';
import '../../Service/dispatch_order_service.dart';


class DispatchOrderListScreen extends StatefulWidget {
  const DispatchOrderListScreen({super.key});

  @override
  State<DispatchOrderListScreen> createState() =>
      _DispatchOrderListScreenState();
}

class _DispatchOrderListScreenState extends State<DispatchOrderListScreen> {
  late Future<List<DispatchOrderListModel>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = DispatchOrderService.fetchDispatchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6200EA), // optional (purple like your app)
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 BACK ICON WHITE
        ),
        title: const Text(
          'Dispatch Orders',
          style: TextStyle(
            color: Colors.white, // 👈 TITLE TEXT WHITE
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: FutureBuilder<List<DispatchOrderListModel>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return const Center(child: Text('No Dispatch Orders Found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Order No', order.orderNo),
                      _row('GR No', order.grNo),
                      _row('Sender ID', order.senderId),
                      _row('Publication', order.publication),
                      _row('Bundal', order.bundal),
                      _row(
                        'Date',
                        '${order.dates.day}-${order.dates.month}-${order.dates.year}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

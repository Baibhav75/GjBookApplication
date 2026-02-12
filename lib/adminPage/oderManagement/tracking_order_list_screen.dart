import 'package:flutter/material.dart';
import '../../Model/tracking_order_model.dart';
import '../../Service/tracking_order_service.dart';
import 'order_tracking_detail_page.dart';

class TrackingOrderListScreen extends StatefulWidget {
  const TrackingOrderListScreen({super.key});

  @override
  State<TrackingOrderListScreen> createState() =>
      _TrackingOrderListScreenState();
}

class _TrackingOrderListScreenState
    extends State<TrackingOrderListScreen> {
  late Future<List<TrackingOrder>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = TrackingOrderService().fetchTrackingOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          'Tracking Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // back arrow color
        ),
      ),

      body: FutureBuilder<List<TrackingOrder>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!;

          return Column(
            children: [
              // 🔹 TABLE HEADER
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.grey.shade300,
                child: Row(
                  children: const [
                    _HeaderCell('Sr No', flex: 1),
                    _HeaderCell('Order No', flex: 2),
                    _HeaderCell('Publication', flex: 2),
                    _HeaderCell('Date', flex: 2),
                    _HeaderCell('Action', flex: 2),
                  ],
                ),
              ),

              // 🔹 TABLE BODY
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          _BodyCell('${index + 1}', flex: 1),
                          _BodyCell(order.orderNo, flex: 2),
                          _BodyCell(order.publication, flex: 2),
                          _BodyCell(
                            order.date
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                            flex: 2,
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderTrackingDetailPage(
                                        senderId: order.senderId,   // 🔒 hidden but passed

                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('View'),
                              ),
                            ),
                          ),

                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 🔹 Header Cell Widget
class _HeaderCell extends StatelessWidget {
  final String title;
  final int flex;

  const _HeaderCell(this.title, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 🔹 Body Cell Widget
class _BodyCell extends StatelessWidget {
  final String value;
  final int flex;

  const _BodyCell(this.value, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(value),
      ),
    );
  }
}

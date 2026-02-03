import 'package:flutter/material.dart';
import '../../Model/individual_order_model.dart';
import '../../Service/individual_order_service.dart';

class IndividualOrderListScreen extends StatefulWidget {
  const IndividualOrderListScreen({super.key});

  @override
  State<IndividualOrderListScreen> createState() =>
      _IndividualOrderListScreenState();
}

class _IndividualOrderListScreenState
    extends State<IndividualOrderListScreen> {
  late Future<List<IndividualOrder>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = IndividualOrderService().fetchIndividualOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          'Individual Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // back arrow color
        ),
      ),

      body: FutureBuilder<List<IndividualOrder>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!;

          return Column(
            children: [
              // 🔹 HEADER ROW
              Container(
                color: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: const [
                    _HeaderCell('Sr No', flex: 1),
                    _HeaderCell('Sender ID', flex: 2),
                    _HeaderCell('Publication', flex: 3),
                    _HeaderCell('Date', flex: 2),
                    _HeaderCell('Action', flex: 2),
                  ],
                ),
              ),

              // 🔹 DATA ROWS
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                          BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          _BodyCell('${index + 1}', flex: 1),
                          _BodyCell(order.senderId, flex: 2),
                          _BodyCell(order.publication, flex: 3),
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
                                  // 🔹 Navigate to detail / tracking page
                                  // Navigator.push(...)
                                },
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

/// 🔹 Header Cell
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

/// 🔹 Body Cell
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

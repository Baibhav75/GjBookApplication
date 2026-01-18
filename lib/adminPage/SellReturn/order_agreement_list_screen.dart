import 'package:flutter/material.dart';
import '/Model/order_agreement_model.dart';
import '/Service/order_agreement_service.dart';
import 'package:intl/intl.dart';

class OrderAgreementListScreen extends StatefulWidget {
  const OrderAgreementListScreen({super.key});

  @override
  State<OrderAgreementListScreen> createState() =>
      _OrderAgreementListScreenState();
}

class _OrderAgreementListScreenState extends State<OrderAgreementListScreen> {
  late Future<OrderAgreementResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = OrderAgreementService.fetchOrderAgreements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Agreements'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<OrderAgreementResponse>(
        future: _future,
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

          final agreements = snapshot.data!.data;

          if (agreements.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: agreements.length,
            itemBuilder: (context, index) {
              final item = agreements[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Party Name
                      Text(
                        item.partyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.address,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 20),

                      /// Date & ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ID: ${item.id}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy, hh:mm a')
                                .format(item.createDate),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
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
}

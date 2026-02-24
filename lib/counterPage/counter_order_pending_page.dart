import 'package:flutter/material.dart';

class CounterOrderPendingPage extends StatelessWidget {
  const CounterOrderPendingPage({Key? key}) : super(key: key);

  // Mock data for demonstration
  final List<Map<String, String>> pendingOrders = const [
    {"id": "ORD001", "date": "2024-05-20", "amount": "₹1,200", "status": "Pending"},
    {"id": "ORD002", "date": "2024-05-21", "amount": "₹2,500", "status": "Awaiting Payment"},
    {"id": "ORD003", "date": "2024-05-22", "amount": "₹850", "status": "Processing"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Orders", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A73E8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: pendingOrders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                return _buildOrderCard(order);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, String> order) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.assignment, color: Color(0xFF1A73E8)),
        ),
        title: Text("Order #${order['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Date: ${order['date']}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(order['amount'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order['status'] ?? "",
                style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to order details if needed
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No pending orders found", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}

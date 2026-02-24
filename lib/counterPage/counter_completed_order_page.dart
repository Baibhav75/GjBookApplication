import 'package:flutter/material.dart';

class CounterCompletedOrderPage extends StatelessWidget {
  const CounterCompletedOrderPage({Key? key}) : super(key: key);

  // Mock data for professional design demonstration
  final List<Map<String, dynamic>> completedOrders = const [
    {
      "id": "ORD-7829",
      "customer": "Aditya Sharma",
      "date": "2024-05-23",
      "time": "11:45 AM",
      "amount": "₹2,450",
      "items": 4,
      "method": "Online"
    },
    {
      "id": "ORD-7815",
      "customer": "Priya Verma",
      "date": "2024-05-23",
      "time": "10:20 AM",
      "amount": "₹890",
      "items": 2,
      "method": "Cash"
    },
    {
      "id": "ORD-7798",
      "customer": "Rajesh Kumar",
      "date": "2024-05-22",
      "time": "04:15 PM",
      "amount": "₹1,120",
      "items": 3,
      "method": "Online"
    },
    {
      "id": "ORD-7782",
      "customer": "Sneha Gupta",
      "date": "2024-05-22",
      "time": "01:30 PM",
      "amount": "₹3,200",
      "items": 6,
      "method": "Cash"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Completed Orders",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          Expanded(
            child: completedOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: completedOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(completedOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: const Color(0xFF1A73E8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem("Total Orders", "${completedOrders.length}"),
          _summaryItem("Total Value", "₹7,660"),
          _summaryItem("Avg. Order", "₹1,915"),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    bool isOnline = order['method'] == 'Online';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: isOnline ? Colors.indigo : const Color(0xFF10B981),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['id'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1A335E),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "COMPLETED",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order['customer'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            "${order['date']} • ${order['time']}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Icon(
                            isOnline ? Icons.payment : Icons.payments_outlined,
                            size: 14,
                            color: isOnline ? Colors.indigo : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order['method'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isOnline ? Colors.indigo : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${order['items']} Items",
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                          Text(
                            order['amount'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A73E8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No completed orders yet",
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Completed orders will appear here",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}



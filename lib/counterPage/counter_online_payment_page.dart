import 'package:flutter/material.dart';

class CounterOnlinePaymentPage extends StatelessWidget {
  const CounterOnlinePaymentPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> payments = const [
    {
      "ref": "ONL4001",
      "user": "Rahul Sharma",
      "counter": "C-102",
      "class": "Class 10",
      "amount": "₹2,450",
      "time": "14 May 2024 • 11:45 AM",
      "method": "UPI"
    },
    {
      "ref": "ONL4002",
      "user": "Priya Verma",
      "counter": "C-102",
      "class": "Class 9",
      "amount": "₹1,120",
      "time": "14 May 2024 • 10:20 AM",
      "method": "QR"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Online Payments",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(context, payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// REF + AMOUNT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ref: ${payment['ref']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A335E),
                  ),
                ),
                Text(
                  payment['amount'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A73E8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// USER DETAILS
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  payment['user'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.storefront, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("Counter: ${payment['counter']}"),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.school_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("Class: ${payment['class']}"),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(),

            /// TIME + METHOD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      payment['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.payment, size: 14, color: Colors.indigo),
                    const SizedBox(width: 4),
                    Text(
                      payment['method'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Upload screenshot logic
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Image"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // View screenshot logic
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text("View"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CounterWalletHistoryPage extends StatelessWidget {
  const CounterWalletHistoryPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> walletHistory = const [
    {
      "id": "TXN-9021",
      "type": "Credit",
      "amount": "₹1,200",
      "time": "Today, 11:30 AM",
      "source": "Cash Collection",
      "status": "Success"
    },
    {
      "id": "TXN-8998",
      "type": "Credit",
      "amount": "₹450",
      "time": "Today, 10:15 AM",
      "source": "Online Payment",
      "status": "Success"
    },
    {
      "id": "TXN-8954",
      "type": "Debit",
      "amount": "₹3,000",
      "time": "Yesterday, 04:30 PM",
      "source": "Bank Settlement",
      "status": "Success"
    },
    {
      "id": "TXN-8921",
      "type": "Credit",
      "amount": "₹2,500",
      "time": "Yesterday, 02:00 PM",
      "source": "Cash Collection",
      "status": "Success"
    },
    {
      "id": "TXN-8890",
      "type": "Credit",
      "amount": "₹1,100",
      "time": "May 22, 11:15 AM",
      "source": "QR Payment",
      "status": "Success"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Wallet History",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildBalanceCard(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
            child: Row(
              children: [
                Text(
                  "Recent Transactions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Spacer(),
                Icon(Icons.tune, size: 20, color: Color(0xFF1A73E8)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: walletHistory.length,
              itemBuilder: (context, index) {
                return _buildTransactionCard(walletHistory[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current Balance",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "₹14,580.45",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _balanceAction(Icons.arrow_upward, "Add Money"),
              const SizedBox(width: 20),
              _balanceAction(Icons.arrow_downward, "Transfer"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceAction(IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> txn) {
    bool isCredit = txn['type'] == 'Credit';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.add : Icons.remove,
              color: isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn['source'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  txn['time'],
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isCredit ? '+' : '-'} ${txn['amount']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                txn['id'],
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/agent_school_sale_model.dart';
import '../Service/agent_school_sale_service.dart';

class AgentSchoolSalePage extends StatefulWidget {
  final String agentId;

  const AgentSchoolSalePage({Key? key, required this.agentId})
      : super(key: key);

  @override
  State<AgentSchoolSalePage> createState() => _AgentSchoolSalePageState();
}

class _AgentSchoolSalePageState extends State<AgentSchoolSalePage> {
  late Future<AgentSchoolSaleResponse> _futureSale;

  @override
  void initState() {
    super.initState();
    _futureSale =
        AgentSchoolSaleService.getAgentSchoolSale(agentId: widget.agentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Agent School Sale",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // back arrow white
        ),
      ),

      body: FutureBuilder<AgentSchoolSaleResponse>(
        future: _futureSale,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final response = snapshot.data!;
          if (!response.isSuccess) {
            return Center(child: Text(response.message));
          }

          return Column(
            children: [
              _summaryCard(response),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: response.data.length,
                  itemBuilder: (context, index) {
                    return _saleCard(response.data[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------- SUMMARY CARD ----------------
  Widget _summaryCard(AgentSchoolSaleResponse response) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Bills",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                response.totalBills.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Agent ID",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                response.agentId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- SALE CARD ----------------
  Widget _saleCard(AgentSchoolSale sale) {
    final date = DateFormat("dd MMM yyyy, hh:mm a").format(sale.billDate);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sale.schoolName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text("Bill No: ${sale.billNo}"),
            Text("Date: $date"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sale.type,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "₹ ${sale.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

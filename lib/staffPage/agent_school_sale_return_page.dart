import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/agent_school_sale_return_model.dart';
import '../Service/agent_school_sale_return_service.dart';
import 'agent_invoice_return_detail_page.dart';

class AgentSchoolSaleReturnPage extends StatefulWidget {
  final String agentId;

  const AgentSchoolSaleReturnPage({
    Key? key,
    required this.agentId,
  }) : super(key: key);

  @override
  State<AgentSchoolSaleReturnPage> createState() =>
      _AgentSchoolSaleReturnPageState();
}

class _AgentSchoolSaleReturnPageState
    extends State<AgentSchoolSaleReturnPage> {
  late Future<AgentSchoolSaleReturnResponse> _futureReturn;

  @override
  void initState() {
    super.initState();
    _futureReturn =
        AgentSchoolSaleReturnService.getAgentSchoolReturn(
          agentId: widget.agentId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
            ),
          ),
        ),
        title: const Text(
          "Agent School Return",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: FutureBuilder<AgentSchoolSaleReturnResponse>(
        future: _futureReturn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
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
                    return _returnCard(response.data[index]);
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
  Widget _summaryCard(AgentSchoolSaleReturnResponse response) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem(
            icon: Icons.assignment_return,
            label: "Total Returns",
            value: response.totalBills.toString(),
          ),
          _summaryItem(
            icon: Icons.person,
            label: "Agent ID",
            value: response.agentId,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.red),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ---------------- RETURN CARD ----------------
  Widget _returnCard(AgentSchoolSaleReturn sale) {
    final date =
    DateFormat("dd MMM yyyy, hh:mm a").format(sale.billDate);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SCHOOL NAME
              Expanded(
                child: Text(
                  sale.schoolName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // SALE / RETURN ICON (RIGHT SIDE)
              GestureDetector(
                onTap: () {
                  // Use billNo from the model to show invoice details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  AgentInvoiceReturnDetailPage (
                        agentId: widget.agentId,
                        billNo: sale.billNo,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: (sale.type == "Sale"
                        ? Colors.green
                        : Colors.red)
                        .withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    sale.type == "Sale"
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 20,
                    color: sale.type == "Sale" ? Colors.green : Colors.red,
                  ),
                ),
              ),

            ],
          ),//

          const SizedBox(height: 6),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bill No: ${sale.billNo}"),
              Text(
                sale.type,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(date, style: const TextStyle(color: Colors.grey)),

          const Divider(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "- ₹ ${sale.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/agent_school_sale_model.dart';
import '../Service/agent_school_sale_service.dart';
import '../Service/secure_storage_service.dart';
import 'agent_invoice_detail_page.dart';

class AgentSchoolSalePage extends StatefulWidget {
  final String agentId;

  const AgentSchoolSalePage({Key? key, required this.agentId})
      : super(key: key);

  @override
  State<AgentSchoolSalePage> createState() => _AgentSchoolSalePageState();
}

class _AgentSchoolSalePageState extends State<AgentSchoolSalePage> {
  late Future<AgentSchoolSaleResponse> _futureSale;
  final SecureStorageService _storageService = SecureStorageService();
  
  // Final variables to store agentId and totalBills
  String? _finalAgentId;
  int? _finalTotalBills;

  @override
  void initState() {
    super.initState();
    _futureSale = _loadAgentSchoolSale();
  }

  Future<AgentSchoolSaleResponse> _loadAgentSchoolSale() async {
    final response = await AgentSchoolSaleService.getAgentSchoolSale(
      agentId: widget.agentId,
    );
    
    // Store agentId and totalBills when data is successfully fetched
    if (response.isSuccess) {
      // Store in final variables
      _finalAgentId = response.agentId;
      _finalTotalBills = response.totalBills;
      
      // Store in secure storage
      await _storageService.saveAgentSchoolSaleData(
        agentId: response.agentId,
        totalBills: response.totalBills,
      );
    }
    
    return response;
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SCHOOL NAME
                Expanded(
                  child: Text(
                    sale.schoolName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // 🔥 ACTIVE / BOLD ICON
                GestureDetector(
                  onTap: () {
                    // Use billNo from the model to show invoice details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgentInvoiceDetailPage(
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

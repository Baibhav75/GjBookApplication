import 'package:flutter/material.dart';
import '../Model/RecoveryPendingAmount_Model.dart';
import '../Service/recovery_pending_amount_service.dart';

class RecoveryPendingAmountScreen extends StatefulWidget {
  final String employeeId;

  const RecoveryPendingAmountScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<RecoveryPendingAmountScreen> createState() =>
      _RecoveryPendingAmountScreenState();
}

class _RecoveryPendingAmountScreenState
    extends State<RecoveryPendingAmountScreen> {
  final RecoveryPendingAmountService _service = RecoveryPendingAmountService();

  List<RecoveryPendingAmountModel> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final data = await _service.fetchPendingPayments(widget.employeeId);

    if (!mounted) return;

    setState(() {
      _list = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recovery Pending Amount",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: Colors.red.shade400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
            : _list.isEmpty
                ? _buildEmptyState()
                : _buildTableBody(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No pending payments found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.red),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    columnSpacing: 24,
                    dataRowMinHeight: 48,
                    columns: const [
                      DataColumn(label: Text("Sr No")),
                      DataColumn(label: Text("School Name")),
                      DataColumn(label: Text("Address")),
                      DataColumn(label: Text("Amount")),
                      DataColumn(label: Text("Recovery By")),
                      DataColumn(label: Text("Payment Date")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Receipt No")),
                      DataColumn(label: Text("Payment Mode")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: List.generate(_list.length, (index) {
                      final item = _list[index];
                      final isEven = index % 2 == 0;

                      return DataRow(
                        color: WidgetStateProperty.all(
                          isEven ? Colors.white : Colors.red.shade50,
                        ),
                        cells: [
                          DataCell(Text("${index + 1}")),
                          DataCell(Text(item.schoolName ?? "-")),
                          DataCell(Text(item.schoolAddress ?? "-")),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                      "₹ ${item.amount?.toStringAsFixed(2) ?? "0.00"}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(item.recivedByFromSchool ?? "-")),
                          DataCell(Text(item.payMentDate ?? "-")),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (item.status?.toLowerCase() == "pending")
                                    ? Colors.orange.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.status ?? "-",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (item.status?.toLowerCase() == "pending")
                                      ? Colors.orange.shade800
                                      : Colors.blue.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(item.reciptNo ?? "-")),
                          DataCell(Text(item.paymentmode ?? "-")),
                          DataCell(
                            ElevatedButton.icon(
                              onPressed: () {
                                _showDetailsDialog(item);
                              },
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text("View"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(fontSize: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(RecoveryPendingAmountModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Text(item.schoolName ?? "School Details"),
            const Divider(),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem("Address", item.schoolAddress),
              _buildDetailItem("Block", item.schoolBlock),
              _buildDetailItem("District", item.schoolDistrict),
              _buildDetailItem("Amount", "₹ ${item.amount}"),
              _buildDetailItem("Recovery By", item.recivedByFromSchool),
              _buildDetailItem("Payment Date", item.payMentDate),
              _buildDetailItem("Payment Mode", item.paymentmode),
              _buildDetailItem("Receipt No", item.reciptNo),
              _buildDetailItem("Status", item.status),
              _buildDetailItem("Remarks", item.remarks),
              _buildDetailItem("Created By", item.createdBy),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value ?? "-"),
          ],
        ),
      ),
    );
  }
}

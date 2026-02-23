import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/recover_history_list_model.dart';
import '../Service/recover_history_service.dart';

class RecoveryHistoryListScreen extends StatefulWidget {
  final String employeeId;

  const RecoveryHistoryListScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<RecoveryHistoryListScreen> createState() =>
      _RecoveryHistoryListScreenState();
}

class _RecoveryHistoryListScreenState
    extends State<RecoveryHistoryListScreen> {
  late Future<List<RecoverHistoryListModel>> futureData;

  @override
  void initState() {
    super.initState();
    futureData =
        RecoverHistoryService().fetchRecoveryHistory(widget.employeeId);
  }

  String formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Recovery History",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 back button + other icons white
        ),
      ),
      body: FutureBuilder<List<RecoverHistoryListModel>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("No Recovery Data Found"));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minWidth: constraints.maxWidth),
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor:
                        WidgetStateProperty.all(Colors.orangeAccent),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: const [
                          DataColumn(label: Text("Sr No")),
                          DataColumn(label: Text("School Name")),
                          DataColumn(label: Text("Address")),
                          DataColumn(label: Text("Amount")),
                          DataColumn(label: Text("Recovery By")),
                          DataColumn(
                              label: Text("Collected By (Office)")),
                          DataColumn(label: Text("Payment Date")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Receipt No")),
                          DataColumn(label: Text("Payment Mode")),
                          DataColumn(label: Text("Created Date")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(data.length, (index) {
                          final item = data[index];
                          final isEven = index % 2 == 0;

                          return DataRow(
                            color: WidgetStateProperty.all(
                              isEven
                                  ? Colors.white
                                  : Colors.orange.shade100,
                            ),
                            cells: [
                              DataCell(Text("${index + 1}")),
                              DataCell(Text(item.schoolName)),
                              DataCell(Text(item.schoolAddress)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "₹ ${item.amount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                  Text(item.recivedByFromSchool)),
                              DataCell(
                                  Text(item.collectedByInoffice)),
                              DataCell(
                                  Text(formatDate(item.payMentDate))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(item.reciptNo ?? "-")),
                              DataCell(Text(item.paymentMode)),
                              DataCell(Text(item.createDate.toString())),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Details"),
                                        content: Text(
                                          "School: ${item.schoolName}\n"
                                              "Amount: ₹${item.amount}\n"
                                              "Status: ${item.status}",
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.orangeAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("View"),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
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
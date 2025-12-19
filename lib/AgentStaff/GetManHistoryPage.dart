import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/getman_history_model.dart';
import '../Service/getman_history_service.dart';

class GetManHistoryPage extends StatefulWidget {
  const GetManHistoryPage({Key? key}) : super(key: key);

  @override
  State<GetManHistoryPage> createState() => _GetManHistoryPageState();
}

class _GetManHistoryPageState extends State<GetManHistoryPage> {
  final GetManHistoryService _service = GetManHistoryService();
  late Future<GetManHistoryModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("GetMan History"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<GetManHistoryModel?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return const Center(child: Text("No history found"));
          }

          final list = snapshot.data!.data.reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              final date = DateFormat('dd MMM yyyy, hh:mm a').format(
                DateTime.parse(item.createDate),
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name ?? "-",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          if (item.itemType != null)
                            Chip(
                              label: Text(item.itemType!),
                              backgroundColor: Colors.blue.shade100,
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      _row("Item", item.itemName),
                      _row("Qty", item.qty),
                      _row("Rate", item.rate != null ? "₹ ${item.rate}" : null),
                      _row("Amount", "₹ ${item.amount.toStringAsFixed(2)}",
                          bold: true),
                      _row("Remarks", item.remarks),
                      _row("Date", date),

                      if (item.image.isNotEmpty &&
                          item.image.startsWith("http")) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.image,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const SizedBox(),
                          ),
                        ),
                      ],
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

  Widget _row(String label, String? value, {bool bold = false}) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

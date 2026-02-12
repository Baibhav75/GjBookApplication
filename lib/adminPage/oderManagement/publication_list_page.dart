import 'package:flutter/material.dart';
import '../../Model/publication_order_management_model.dart';
import '../../Service/publication_order_management_service.dart';
import '/adminPage/oderManagement/publication_ledger_page.dart';

class PublicationOrderManagementPage extends StatefulWidget {
  const PublicationOrderManagementPage({super.key});

  @override
  State<PublicationOrderManagementPage> createState() =>
      _PublicationOrderManagementPageState();
}

class _PublicationOrderManagementPageState
    extends State<PublicationOrderManagementPage> {
  late Future<PublicationOrderManagementResponse> futureData;

  @override
  void initState() {
    super.initState();
    futureData =
        PublicationOrderManagementService.fetchPublicationOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white, // title + icons
        title: const Text(
          'Publication Order Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: FutureBuilder<PublicationOrderManagementResponse>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.records.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          final records = snapshot.data!.records;
          final totalPurchase = snapshot.data!.totalPurchase;

          return Column(
            children: [
              // 🔹 TABLE (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                      MaterialStateProperty.all(Colors.grey.shade200),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Sr No')),
                        DataColumn(label: Text('Order No')),
                        DataColumn(label: Text('Publication Name')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Publication ID')),
                        DataColumn(label: Text('Action')), // ✅ NEW
                      ],
                      rows: List.generate(records.length, (index) {
                        final item = records[index];
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(item.orderNo)),
                            DataCell(Text(item.publicationName)),
                            DataCell(
                              Text(
                                '${item.date.day}-${item.date.month}-${item.date.year}',
                              ),
                            ),
                            DataCell(Text(item.publicationId)),

                            // ✅ VIEW BUTTON
                            DataCell(
                              ElevatedButton(
                                onPressed: () {
                                  _openLedger(item);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: const Text('View'),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                  ),
                ),
              ),

              // 🔻 TOTAL PURCHASE (BOTTOM)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Purchase',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹ ${totalPurchase.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openLedger(PublicationOrderRecord item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicationLedgerPage(
          publicationId: item.publicationId,

        ),
      ),
    );
  }


}

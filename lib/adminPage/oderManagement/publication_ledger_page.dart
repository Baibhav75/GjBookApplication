import 'package:flutter/material.dart';

import '../../Model/publication_ledger_model.dart';
import '../../Service/publication_ledger_service.dart';

class PublicationLedgerPage extends StatefulWidget {
  final String publicationId;

  const PublicationLedgerPage({
    super.key,
    required this.publicationId,
  });

  @override
  State<PublicationLedgerPage> createState() =>
      _PublicationLedgerPageState();
}

class _PublicationLedgerPageState extends State<PublicationLedgerPage> {
  late Future<PublicationLedgerResponse> futureLedger;

  @override
  void initState() {
    super.initState();
    futureLedger =
        PublicationLedgerService.fetchLedger(widget.publicationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('Ledger Statement'),
      ),
      body: FutureBuilder<PublicationLedgerResponse>(
        future: futureLedger,
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

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _companyHeader(),
                const Divider(thickness: 1),

                _title(),
                const SizedBox(height: 16),

                // ✅ Publication + Address (ONE TABLE)
                _publicationInfoTable(data),
                const SizedBox(height: 6),

                // ✅ Current Date
                _currentDateRow(),
                const SizedBox(height: 16),

                // ✅ Ledger Table
                _ledgerTable(data.ledger),
                const SizedBox(height: 12),

                // ✅ Summary
                _summaryRow('Total Credit', data.totalCredit),
                _closingBalance(data.closingBalance),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _companyHeader() => Column(
    children: const [
      Text(
        'GJ BOOK WORLD PVT. LTD.',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 4),
      Text(
        'D-1/20, SECTOR 22, GIDA, GORAKHPUR',
        style: TextStyle(fontSize: 13),
      ),
      SizedBox(height: 4),
      Text(
        'GST No: 09AAGCG6058B1Z2 | CIN No: U22222UP2015PTC068597',
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _title() => const Center(
    child: Text(
      'Publication Order Ledger Statement',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      ),
    ),
  );

  // ================= INFO TABLE =================

  Widget _publicationInfoTable(PublicationLedgerResponse data) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(6),
      },
      children: [
        _infoTableRow('Publication', data.publicationName),
        _infoTableRow('Address', data.address),
      ],
    );
  }

  TableRow _infoTableRow(String label, String value) {
    return TableRow(
      children: [
        _cell(label, bold: true),
        _cell(value),
      ],
    );
  }

  Widget _currentDateRow() {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Current Date : $date',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  // ================= LEDGER TABLE =================

  Widget _ledgerTable(List<PublicationLedgerItem> ledger) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        _ledgerHeader(),
        ...ledger.map(
              (e) => TableRow(
            children: [
              _cell(e.orderDate),
              _cell(e.orderNo),
              _cell('₹ ${e.credit.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _ledgerHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children:[
        _cell('Order Date', bold: true),
        _cell('Order No', bold: true),
        _cell('Credit', bold: true),
      ],
    );
  }

  // ================= SUMMARY =================

  Widget _summaryRow(String label, double value) => Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label : ₹ ${value.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );

  Widget _closingBalance(double value) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(12),
    color: Colors.blue.shade50,
    child: Text(
      'Closing Balance : ₹ ${value.toStringAsFixed(2)}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );

  // ================= COMMON CELL =================

  static Widget _cell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

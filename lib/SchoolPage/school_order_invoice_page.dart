import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/school_order_invoice_model.dart';
import '../Service/school_order_invoice_service.dart';

class SchoolOrderInvoicePage extends StatefulWidget {
  final String mobileNo;

  const SchoolOrderInvoicePage({
    Key? key,
    required this.mobileNo,
  }) : super(key: key);

  @override
  State<SchoolOrderInvoicePage> createState() =>
      _SchoolOrderInvoicePageState();
}

class _SchoolOrderInvoicePageState
    extends State<SchoolOrderInvoicePage> {
  late Future<SchoolOrderInvoiceResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = SchoolOrderInvoiceService.fetchInvoice(
      ownerMobile: widget.mobileNo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: "₹");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "School Order Invoice",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<SchoolOrderInvoiceResponse>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Failed to load invoice"));
          }

          final data = snapshot.data!.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _headerCard(data.header),
              const SizedBox(height: 12),
              ...data.publications.map(
                    (p) => _publicationCard(p, currency),
              ),
              const SizedBox(height: 12),
              _summaryCard(data.summary, currency),
            ],
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  Widget _headerCard(InvoiceHeader h) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              h.schoolName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text("Owner: ${h.ownerName}"),
            Text("Mobile: ${h.ownerMobile}"),
            Text("${h.address}, ${h.district}, ${h.state}"),
            const Divider(),
            Text("Bill Date: ${DateFormat('dd MMM yyyy').format(h.billDate)}"),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  Widget _publicationCard(Publication p, NumberFormat currency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          p.publicationName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(p.series),
        children: [
          ...p.items.map(
                (i) => ListTile(
              title: Text(i.bookName),
              subtitle:
              Text("${i.subject} | ${i.className} | Qty ${i.qty}"),
              trailing: Text(currency.format(i.amount)),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Total Qty: ${p.totalQty}"),
                Text(
                  "Subtotal: ${currency.format(p.subTotal)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --------------------------------------------------
  Widget _summaryCard(InvoiceSummary s, NumberFormat currency) {
    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Grand Qty: ${s.grandQty}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Grand Total: ${currency.format(s.grandTotal)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

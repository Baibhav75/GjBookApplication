import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/agent_invoice_return_detail_model.dart';
import '../Service/agent_invoice_return_service.dart';

class AgentInvoiceReturnDetailPage extends StatefulWidget {
  final String agentId;
  final String billNo;

  const AgentInvoiceReturnDetailPage({
    super.key,
    required this.agentId,
    required this.billNo,
  });

  @override
  State<AgentInvoiceReturnDetailPage> createState() =>
      _AgentInvoiceReturnDetailPageState();
}

class _AgentInvoiceReturnDetailPageState
    extends State<AgentInvoiceReturnDetailPage> {
  late Future<AgentInvoiceReturnDetailResponse> _future;

  void _loadInvoiceData() {
    setState(() {
      _future = AgentInvoiceReturnService.fetchInvoiceDetail(
        agentId: widget.agentId,
        billNo: widget.billNo,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _future = AgentInvoiceReturnService.fetchInvoiceDetail(
      agentId: widget.agentId,
      billNo: widget.billNo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Invoice ReturnDetail",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvoiceData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<AgentInvoiceReturnDetailResponse>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load data'));
          }

          final data = snapshot.data!.data;
          final currency = NumberFormat.currency(symbol: '₹');

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _headerCard(data.header),
              const SizedBox(height: 12),
              ...data.publications.map((p) => _publicationCard(p, currency)),
              const SizedBox(height: 12),
              _summaryCard(data.summary, currency),
            ],
          );
        },
      ),
    );
  }

  Widget _headerCard(InvoiceHeader h) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(h.partyName,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(h.address),
            const Divider(),
            _row('Invoice No', h.invoiceNo),
            _row(
              'Date',
              DateFormat('dd MMM yyyy').format(h.billDate),
            ),
            _row('Agent', h.agentName),
            _row('Transport', h.transport),
          ],
        ),
      ),
    );
  }

  Widget _publicationCard(Publication p, NumberFormat currency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(p.publicationName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(p.series),
        children: [
          ...p.items.map((i) => ListTile(
            title: Text(i.bookName),
            subtitle: Text('${i.subject} | ${i.className} | Qty ${i.qty}'),
            trailing: Text(currency.format(i.amount)),
          )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Subtotal: ${currency.format(p.subTotal)}'),
                Text(
                  'Commission (${p.commissionPercent}%): ${currency.format(p.commissionAmount)}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(InvoiceSummary s, NumberFormat currency) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Grand Total: ${currency.format(s.grandTotal)}',
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Total Commission: ${currency.format(s.totalCommission)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

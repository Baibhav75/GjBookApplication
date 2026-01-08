import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Model/agent_invoice_detail_model.dart';
import '../Service/agent_invoice_service.dart';
import '../Service/secure_storage_service.dart';

class AgentInvoiceDetailPage extends StatefulWidget {
  final String agentId;
  final String billNo;

  const AgentInvoiceDetailPage({
    super.key,
    required this.agentId,
    required this.billNo,
  });

  @override
  State<AgentInvoiceDetailPage> createState() =>
      _AgentInvoiceDetailPageState();
}

class _AgentInvoiceDetailPageState
    extends State<AgentInvoiceDetailPage> {
  late Future<AgentInvoiceDetailResponse> _future;
  final SecureStorageService _storageService = SecureStorageService();
  
  // Store API URL, AgentId, and totalBills
  late final String _apiUrl;
  String? _storedAgentId;
  int? _storedTotalBills;
  bool _isLoadingStoredData = true;

  @override
  void initState() {
    super.initState();
    _apiUrl = AgentInvoiceService.getApiUrl(
      agentId: widget.agentId,
      billNo: widget.billNo,
    );
    _loadStoredData();
    _loadInvoiceData();
  }

  void _loadInvoiceData() {
    setState(() {
      _future = AgentInvoiceService.getInvoiceDetail(
        agentId: widget.agentId,
        billNo: widget.billNo,
      );
    });
  }

  Future<void> _loadStoredData() async {
    try {
      final agentId = await _storageService.getAgentId();
      final totalBills = await _storageService.getAgentTotalBills();
      if (mounted) {
        setState(() {
          _storedAgentId = agentId;
          _storedTotalBills = totalBills;
          _isLoadingStoredData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStoredData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Invoice Detail",
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
      body: FutureBuilder<AgentInvoiceDetailResponse>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          }

          if (snapshot.data == null || !snapshot.data!.status) {
            return _buildErrorWidget(
              snapshot.data?.message ?? 'Failed to load invoice details',
            );
          }

          final data = snapshot.data!.data;

          return RefreshIndicator(
            onRefresh: () async {
              _loadInvoiceData();
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _infoListCard(),
                const SizedBox(height: 12),
                _headerCard(data.header),
                const SizedBox(height: 12),
                if (data.publications.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('No publications found'),
                      ),
                    ),
                  )
                else
                  ...data.publications.map(_publicationCard),
                const SizedBox(height: 12),
                _summaryCard(data.summary),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading invoice',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInvoiceData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- INFO LIST CARD ----------------
  Widget _infoListCard() {
    return Card(
      elevation: 2,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            _infoItem(
              "Agent ID",
              _isLoadingStoredData
                  ? "Loading..."
                  : (_storedAgentId ?? widget.agentId),
            ),
            const Divider(height: 24),
            _infoItem(
              "Total Bills",
              _isLoadingStoredData
                  ? "Loading..."
                  : (_storedTotalBills?.toString() ?? "N/A"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isUrl ? Colors.blue : null,
                    ),
                  ),
                ),
                if (isUrl)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('API URL copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copy URL',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _headerCard(InvoiceHeader h) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              h.partyName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (h.address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      h.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _headerInfoRow("Invoice No", h.invoiceNo),
            _headerInfoRow(
              "Date",
              DateFormat('dd MMM yyyy, hh:mm a').format(h.billDate),
            ),
            _headerInfoRow("Agent", h.agentName),
            if (h.transport.isNotEmpty)
              _headerInfoRow("Transport", h.transport),
          ],
        ),
      ),
    );
  }

  Widget _headerInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PUBLICATION ----------------
  Widget _publicationCard(Publication p) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: const Icon(Icons.book, color: Colors.blue),
        title: Text(
          p.publicationName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            p.series,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
        children: [
          ...p.items.map((item) => _buildInvoiceItem(item)),
          const Divider(height: 1),
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Subtotal: ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currencyFormat.format(p.subTotal),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Commission (${p.commissionPercent}%): ",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      currencyFormat.format(p.commissionAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(InvoiceItem item) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        item.bookName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          "${item.subject} | ${item.className} | Qty: ${item.qty}",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currencyFormat.format(item.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (item.qty > 1)
            Text(
              '${currencyFormat.format(item.rate)} × ${item.qty}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- SUMMARY ----------------
  Widget _summaryCard(InvoiceSummary s) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    return Card(
      elevation: 3,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Grand Total: ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  currencyFormat.format(s.grandTotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Total Commission: ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                Text(
                  currencyFormat.format(s.totalCommission),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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

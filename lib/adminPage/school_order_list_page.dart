import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/Service/school_order_service.dart';
import '/Model/school_order_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;


class InvoiceSearchScreen extends StatefulWidget {
  const InvoiceSearchScreen({super.key});

  @override
  State<InvoiceSearchScreen> createState() => _InvoiceSearchScreenState();
}

class _InvoiceSearchScreenState extends State<InvoiceSearchScreen> {
  final TextEditingController _billNoController = TextEditingController();
  final OrderFormService _service = OrderFormService();
  OrderFormInvoice? _invoice;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _searchInvoice() async {
    if (_billNoController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a Bill Number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _invoice = null;
    });

    try {
      final invoice = await _service.getInvoiceByBillNo(_billNoController.text);
      setState(() {
        _invoice = invoice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Search'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _billNoController,
                        decoration: InputDecoration(
                          labelText: 'Bill Number',
                          prefixIcon: const Icon(Icons.receipt),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _searchInvoice,
                          icon: _isLoading
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : const Icon(Icons.search),
                          label: Text(_isLoading ? 'Searching...' : 'Search Invoice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Error Message
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Invoice Preview or Full View
              if (_invoice != null) ...[
                const SizedBox(height: 20),
                Expanded(
                  child: InvoiceDetailView(invoice: _invoice!),
                ),
              ] else if (_isLoading) ...[
                const SizedBox(height: 40),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class InvoiceDetailView extends StatefulWidget {
  final OrderFormInvoice invoice;

  const InvoiceDetailView({super.key, required this.invoice});

  @override
  State<InvoiceDetailView> createState() => _InvoiceDetailViewState();
}

class _InvoiceDetailViewState extends State<InvoiceDetailView> {
  bool _showAllPublications = false;
  List<bool> _expandedPublications = [];

  @override
  void initState() {
    super.initState();
    _expandedPublications = List<bool>.filled(
      widget.invoice.data.publications.length,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoiceData = widget.invoice.data;
    final visiblePublications = _showAllPublications
        ? invoiceData.publications
        : invoiceData.publications.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(invoiceData.header),

          const SizedBox(height: 16),

          // Publications Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Publications (${invoiceData.publications.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      if (invoiceData.publications.length > 3)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllPublications = !_showAllPublications;
                            });
                          },
                          child: Text(
                            _showAllPublications ? 'Show Less' : 'View All',
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Publications List
                  ...visiblePublications.asMap().entries.map((entry) {
                    final index = entry.key;
                    final publication = entry.value;

                    return _buildPublicationCard(publication, index);
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Summary Card
          _buildSummaryCard(invoiceData.summary),

          const SizedBox(height: 20),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Header header) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INVOICE #${header.invoiceNo}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'SELF TRANSPORT',
                    style: TextStyle(
                      color: Colors.deepPurple[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('School', header.schoolName),
            _buildInfoRow('Address', header.address),
            _buildInfoRow('Bill Date',
                '${header.billDate.day}/${header.billDate.month}/${header.billDate.year}'),
            if (header.board != null)
              _buildInfoRow('Board', header.board!),
            if (header.remark != null)
              _buildInfoRow('Remark', header.remark!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicationCard(Publication publication, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publication.publicationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    publication.series,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    '${publication.totalQty} items',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Subtotal: ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: '₹${publication.subTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${publication.items.length} books',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: publication.items.map((item) => _buildItemRow(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.bookName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.subject} - ${item.className}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              'Qty: ${item.qty}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '₹${item.rate}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '₹${item.amount}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Summary summary) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Items:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${summary.grandQty} items',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GRAND TOTAL:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  '₹${summary.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Implement share functionality
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Implement print functionality
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//invoice_utils file


class InvoiceUtils {
  static Future<void> generatePdf(OrderFormInvoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(invoice.data.header),
              pw.SizedBox(height: 20),
              _buildPublicationsTable(invoice.data.publications),
              pw.SizedBox(height: 20),
              _buildSummary(invoice.data.summary),
            ],
          );
        },
      ),
    );

    // Save or share the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildHeader(Header header) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INVOICE #${header.invoiceNo}',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('School: ${header.schoolName}'),
        pw.Text('Address: ${header.address}'),
        pw.Text('Date: ${header.billDate.toString()}'),
        if (header.remark != null) pw.Text('Remark: ${header.remark}'),
      ],
    );
  }

  static pw.Widget _buildPublicationsTable(List<Publication> publications) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Publication',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Items',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Subtotal',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),

        ...publications.map((pub) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(pub.publicationName),
                  pw.Text(pub.series, style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(pub.totalQty.toString()),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('₹${pub.subTotal.toStringAsFixed(2)}'),
            ),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildSummary(Summary summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'GRAND TOTAL',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '₹${summary.grandTotal.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceStats {
  static Map<String, int> getClassWiseStats(List<Publication> publications) {
    final Map<String, int> classStats = {};

    for (var publication in publications) {
      for (var item in publication.items) {
        classStats.update(
          item.className,
              (value) => value + item.qty,
          ifAbsent: () => item.qty,
        );
      }
    }

    return classStats;
  }

  static Map<String, int> getSubjectWiseStats(List<Publication> publications) {
    final Map<String, int> subjectStats = {};

    for (var publication in publications) {
      for (var item in publication.items) {
        subjectStats.update(
          item.subject,
              (value) => value + item.qty,
          ifAbsent: () => item.qty,
        );
      }
    }

    return subjectStats;
  }
}
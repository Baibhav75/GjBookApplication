
import 'package:flutter/material.dart';
import '../../Model/viewbooklist_model.dart';
import '../../Service/book_service.dart';

class ViewBookDetails extends StatefulWidget {
  final String billNo;

  const ViewBookDetails({
    super.key,
    required this.billNo,
  });

  @override
  State<ViewBookDetails> createState() => _ViewBookDetailsState();
}

class _ViewBookDetailsState extends State<ViewBookDetails> {
  // ---------------- DATA & STATE ----------------
  final BookService _bookService = BookService();
  BookSummaryResponse? _bookData;
  bool _isLoading = false;
  String _errorMessage = '';
  final ScrollController _scrollController = ScrollController();

  // ---------------- LIFECYCLE ----------------
  @override
  void initState() {
    super.initState();
    _fetchBookData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _bookService.getClassWiseBookSummary(widget.billNo);
      setState(() {
        _bookData = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      debugPrint('Error fetching book data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _bookData?.schoolName.isNotEmpty == true
              ? _bookData!.schoolName
              : "Book Order Details",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5B21B6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _bookData == null
                  ? _buildEmptyView()
                  : _buildMainContent(),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchBookData,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text("No Data Found"));
  }

  Widget _buildFloatingActions() {
    return FloatingActionButton(
      onPressed: _fetchBookData,
      child: const Icon(Icons.refresh),
    );
  }

  Widget _buildMainContent() {
    final data = _bookData!;

    return Column(
      children: [
        // Bill Info Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple.shade50,
          width: double.infinity,
          child: Column(
            children: [
              Text(
                "Bill No: ${data.billNo}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (data.schoolName.isNotEmpty)
                Text(
                  data.schoolName,
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),

        // Table Content
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTable(data),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BookSummaryResponse data) {
    // Define exact column widths based on the image content proportionality
    final Map<int, TableColumnWidth> columnWidths = {
      0: const FixedColumnWidth(50),  // SrNo
      1: const FixedColumnWidth(250), // Publication
      2: const FixedColumnWidth(150), // Series
      3: const FixedColumnWidth(250), // Book Name
      4: const FixedColumnWidth(150), // Subject
      5: const FixedColumnWidth(60),  // Qty
      6: const FixedColumnWidth(80),  // Rate
      7: const FixedColumnWidth(100), // Amount
    };

    List<TableRow> rows = [];

    // 1. Sticky-like Header Row
    rows.add(
      TableRow(
        decoration: BoxDecoration(color: Colors.cyan.shade100),
        children: const [
          _HeaderCell("SrNo"),
          _HeaderCell("Publication"),
          _HeaderCell("Series"),
          _HeaderCell("Book Name"),
          _HeaderCell("Subject"),
          _HeaderCell("Qty"),
          _HeaderCell("Rate"),
          _HeaderCell("Amount"),
        ],
      ),
    );

    // 2. Iterate Classes
    for (var classData in data.data) {
      // Class Section Header
      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade300),
          children: [
            _ClassHeaderCell("", isLeft: true),
            _ClassHeaderCell(""),
            _ClassHeaderCell(""), 
            _ClassHeaderCell("Class : ${classData.className}", isCenterText: true), // Center in BookName col
            _ClassHeaderCell(""),
            _ClassHeaderCell(""),
            _ClassHeaderCell(""),
            _ClassHeaderCell("", isRight: true),
          ],
        ),
      );

      // Books
      for (int i = 0; i < classData.items.length; i++) {
        final item = classData.items[i];
        rows.add(
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            children: [
              _DataCell((i + 1).toString()),
              _DataCell(item.publication),
              _DataCell(item.series),
              _DataCell(item.bookName),
              _DataCell(item.subject),
              _DataCell(item.totalQty.toStringAsFixed(0)),
              _DataCell("₹${item.rate.toStringAsFixed(2)}"),
              _DataCell("₹${item.totalAmount.toStringAsFixed(2)}"),
            ],
          ),
        );
      }
      
      // Class Total Row (Optional but good for table view)
       rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
             const _DataCell(""),
             const _DataCell(""),
             const _DataCell(""),
             const _HeaderCell("TOTAL"), // Bold text
             const _DataCell(""),
             _HeaderCell(classData.classTotalQty.toStringAsFixed(0)),
             _HeaderCell("₹${classData.classTotalRate.toStringAsFixed(2)}"),
             _HeaderCell("₹${classData.classTotalAmount.toStringAsFixed(2)}"),
          ],
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _ClassHeaderCell extends StatelessWidget {
  final String text;
  final bool isCenterText;
  final bool isLeft;
  final bool isRight;

  const _ClassHeaderCell(this.text, {
    this.isCenterText = false,
    this.isLeft = false,
    this.isRight = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300, 
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        overflow: TextOverflow.visible,
        softWrap: false,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
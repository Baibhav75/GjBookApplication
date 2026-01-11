import 'package:flutter/material.dart';

class Orderbooknow extends StatefulWidget {
  const Orderbooknow({super.key});

  @override
  State<Orderbooknow> createState() => _OrderbooknowState();
}

class _OrderbooknowState extends State<Orderbooknow> {
  final List<Map<String, dynamic>> books = [
    {'sn': '1', 'subject': 'Hindi', 'book': 'अक्षरा', 'publication': 'Mayank', 'price': 155, 'qty': 0},
    {'sn': '2', 'subject': 'English', 'book': 'Smart Kids Eng Reader', 'publication': 'ARC Advance', 'price': 155, 'qty': 0},
    {'sn': '3', 'subject': 'Math', 'book': 'Literary Math', 'publication': 'ARC Advance', 'price': 155, 'qty': 0},
    {'sn': '4', 'subject': 'Science', 'book': 'People and the World Around', 'publication': 'Nav Cares', 'price': 155, 'qty': 0},
    {'sn': '5', 'subject': 'G.K', 'book': 'People and the World Around', 'publication': 'Nav Cares', 'price': 155, 'qty': 0},
    {'sn': '6', 'subject': 'Science', 'book': 'People and the World Around', 'publication': 'Nav Cares', 'price': 155, 'qty': 0},
    {'sn': '7', 'subject': 'English Grammar', 'book': 'People and the World Around', 'publication': 'Nav Cares', 'price': 155, 'qty': 0},
  ];

  /// 🔹 GRAND TOTAL (TYPE SAFE)
  int get grandTotal {
    return books.fold<int>(
      0,
          (sum, item) => sum + (item['price'] as int) * (item['qty'] as int),
    );
  }

  /// 🔹 Get selected books with quantity > 0
  List<Map<String, dynamic>> get selectedBooks {
    return books.where((book) => (book['qty'] as int) > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editable Book Table',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      /// 🔹 TABLE
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.black),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(50),
              1: FixedColumnWidth(120),
              2: FixedColumnWidth(260),
              3: FixedColumnWidth(200),
              4: FixedColumnWidth(80),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(100),
            },
            children: [
              _headerRow(),
              ...books.map(_dataRow).toList(),
            ],
          ),
        ),
      ),

      /// 🔹 BOTTOM BAR WITH DISABLED SUBMIT
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                grandTotal == 0
                    ? 'Add at least one item'
                    : 'Total: ₹$grandTotal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: grandTotal == 0 ? Colors.red : Colors.black,
                ),
              ),
            ),

            /// ✅ SUBMIT BUTTON (DISABLED WHEN TOTAL = 0)
            ElevatedButton(
              onPressed: grandTotal == 0 ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'SUBMIT',
                style: TextStyle(color: Colors.white),
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// 🔹 HEADER ROW
  TableRow _headerRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFEDE7F6)),
      children: [
        _cell('S.N.', true),
        _cell('Subject', true),
        _cell('Book Name', true),
        _cell('Publication', true),
        _cell('Price', true),
        _cell('Qty', true),
        _cell('Amount', true),
      ],
    );
  }

  /// 🔹 DATA ROW
  TableRow _dataRow(Map<String, dynamic> book) {
    final int amount = (book['price'] as int) * (book['qty'] as int);

    return TableRow(
      children: [
        _cell(book['sn']),
        _cell(book['subject']),
        _cell(book['book']),
        _cell(book['publication']),
        _cell(book['price'].toString()),
        _qtyCell(book),
        _cell(amount.toString()),
      ],
    );
  }

  /// 🔹 NORMAL CELL
  Widget _cell(String text, [bool isHeader = false]) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /// 🔹 EDITABLE QTY CELL (STARTS FROM 0)
  Widget _qtyCell(Map<String, dynamic> book) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextFormField(
        initialValue: book['qty'].toString(),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: (value) {
          final int qty = int.tryParse(value) ?? 0;
          setState(() {
            book['qty'] = qty < 0 ? 0 : qty;
          });
        },
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  /// 🔹 SUBMIT ACTION WITH DIALOG BOX
  void _submitOrder() {
    // Log order details
    debugPrint('Submitted Order:');
    for (var book in selectedBooks) {
      debugPrint(
          '${book['subject']} | Qty: ${book['qty']} | Amount: ₹${book['price'] * book['qty']}');
    }
    debugPrint('Grand Total: ₹$grandTotal');

    // Show confirmation dialog
    _showConfirmationDialog();
  }

  /// 🔹 SHOW CONFIRMATION DIALOG
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 10),
              Text('Order Confirmation'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please review your order:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Selected items list
                if (selectedBooks.isEmpty)
                  const Text('No items selected', style: TextStyle(color: Colors.grey))
                else
                  ...selectedBooks.map((book) {
                    final amount = (book['price'] as int) * (book['qty'] as int);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${book['subject']} (x${book['qty']})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }).toList(),

                const Divider(height: 20, thickness: 1),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹$grandTotal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Text(
                  'Do you want to proceed with this order?',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _processOrder(); // Process the order
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('CONFIRM ORDER'),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 PROCESS ORDER AFTER CONFIRMATION
  void _processOrder() {
    // Here you would typically send the order to your backend
    // For now, we'll just show a success message

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Order Submitted Successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Optional: Reset quantities or navigate to another screen
    // setState(() {
    //   for (var book in books) {
    //     book['qty'] = 0;
    //   }
    // });
  }
}
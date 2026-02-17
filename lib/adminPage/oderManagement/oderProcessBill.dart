import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderProcessBill extends StatefulWidget {
  const OrderProcessBill({super.key});

  @override
  State<OrderProcessBill> createState() => _OrderProcessBillState();
}

class _OrderProcessBillState extends State<OrderProcessBill> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _billNoController = TextEditingController(text: '83');
  final TextEditingController _partyNameController = TextEditingController(text: '29. L.P.M. SCHOOL GOLA ( ADITI BOOK EMPORIUM) F');
  final TextEditingController _addressController = TextEditingController(text: 'GOLA GORAKHPUR U.P.');
  final TextEditingController _schoolStatusController = TextEditingController(text: 'DISCUSSIONSCHOOL');
  final TextEditingController _mobileController = TextEditingController(text: '9838639268');
  final TextEditingController _counterTypeController = TextEditingController(text: 'BOOK SUPLY');
  final TextEditingController _agentNameController = TextEditingController(text: 'GOVIND JAIWSAL');

  // Selected Values
  String? selectedSchoolType;
  DateTime? orderDate;
  String? selectedPublication;
  String? selectedTransport;
  String? selectedSeries;
  String? selectedTitle;

  // Dummy Data
  final List<String> schoolTypes = ['- Select Type -', 'NEW', 'OLD'];
  final List<String> publications = ['ORIENT BLACKSWAN PUBLICATION', 'S. CHAND', 'NCERT'];
  final List<String> transports = ['- Select Transport -', 'VRL', 'GATI', 'BLUE DART'];
  final List<String> seriesList = ['GULMOHAR, 1-5', 'STARDUST', 'COMMUNICATE IN ENGLISH'];
  final List<String> titles = ['ENGLISH', 'MATHEMATICS', 'SCIENCE'];

  // Table Data
  List<OrderItem> items = [
    OrderItem(bookName: 'LITRATURE', classes: 'Class 1', subject: 'ENGLISH', rate: 1.0, qty: 0),
    OrderItem(bookName: 'LITRATURE', classes: 'Class 2', subject: 'ENGLISH', rate: 1.0, qty: 2),
    OrderItem(bookName: 'LITRATURE', classes: 'Class 3', subject: 'ENGLISH', rate: 1.0, qty: 0),
    OrderItem(bookName: 'LITRATURE', classes: 'Class 4', subject: 'ENGLISH', rate: 1.0, qty: 0),
    OrderItem(bookName: 'LITRATURE', classes: 'Class 5', subject: 'ENGLISH', rate: 1.0, qty: 0),
    OrderItem(bookName: 'THE ENGLISH LANGUAGE', classes: 'Class 1', subject: 'ENGLISH', rate: 1.0, qty: 0),
    OrderItem(bookName: 'THE ENGLISH LANGUAGE', classes: 'Class 2', subject: 'ENGLISH', rate: 1.0, qty: 0),
    OrderItem(bookName: 'THE ENGLISH LANGUAGE', classes: 'Class 3', subject: 'ENGLISH', rate: 1.0, qty: 4),
    OrderItem(bookName: 'THE ENGLISH LANGUAGE', classes: 'Class 4', subject: 'ENGLISH', rate: 1.0, qty: 0),
    OrderItem(bookName: 'THE ENGLISH LANGUAGE', classes: 'Class 5', subject: 'ENGLISH', rate: 1.0, qty: 0),
  ];

  double get grandTotal => items.fold(0, (sum, item) => sum + item.amount);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: orderDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => orderDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1), // Purple background
        iconTheme: const IconThemeData(color: Colors.white), // Back icon white
        title: Text(
          'Order Process Bill',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white, // ✅ Text color white
          ),
        ),
        centerTitle: false, // optional
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // Form Fields Row 1
              Row(
                children: [
                  Expanded(child: _buildLabelField('Bill No.', _billNoController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdownField('School Type', schoolTypes, selectedSchoolType, (val) => setState(() => selectedSchoolType = val))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(orderDate == null ? 'dd-mm-yyyy' : DateFormat('dd-MM-yyyy').format(orderDate!)),
                                const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2
              Row(
                children: [
                  Expanded(flex: 2, child: _buildLabelField('Party Name (School)', _partyNameController)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildLabelField('Party Address', _addressController)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildLabelField('School Status', _schoolStatusController)),
                ],
              ),
              const SizedBox(height: 12),

              // Row 3
              Row(
                children: [
                  Expanded(child: _buildLabelField('Owner Mobile No', _mobileController)),
                  const SizedBox(width: 16),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),

              // Row 4
              Row(
                children: [
                  Expanded(child: _buildLabelField('Counter type', _counterTypeController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLabelField('Agent Name', _agentNameController)),
                ],
              ),
              const SizedBox(height: 12),

              // Row 5
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                    'Publication', 
                    publications, 
                    selectedPublication, 
                    (val) {
                      setState(() {
                         selectedPublication = val;
                         // Reset series and title when publication changes
                         selectedSeries = null;
                         selectedTitle = null;
                      });
                    })),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdownField('Transport', transports, selectedTransport, (val) => setState(() => selectedTransport = val))),
                ],
              ),

              // Series and Title (Visible only after Publication selected)
              if (selectedPublication != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDropdownField('Series', seriesList, selectedSeries, (val) => setState(() => selectedSeries = val))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDropdownField('Title', titles, selectedTitle, (val) => setState(() => selectedTitle = val))),
                  ],
                ),
              ],

              // Items Table Section
              if (selectedTitle != null) ...[
                const SizedBox(height: 24),
                const Text('Items in Selected Series', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildItemsTable(),
                const SizedBox(height: 16),
                _buildTotalsSection(),
              ],

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text('-- Select --', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Center(child: Text('Book Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                Expanded(flex: 2, child: Center(child: Text('Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                Expanded(flex: 2, child: Center(child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                Expanded(flex: 1, child: Center(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                Expanded(flex: 1, child: Center(child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                Expanded(flex: 1, child: Center(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              ],
            ),
          ),
          // Group Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Series: ${selectedSeries ?? ""} | Subject: ${selectedTitle ?? ""}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                Text('Publication: ${selectedPublication ?? ""}', 
                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(item.bookName, style: const TextStyle(fontSize: 11)),
                    )),
                    Expanded(flex: 2, child: Center(child: Text(item.classes, style: const TextStyle(fontSize: 11)))),
                    Expanded(flex: 2, child: Center(child: Text(item.subject, style: const TextStyle(fontSize: 11)))),
                    Expanded(flex: 1, child: Center(child: _buildQtyInput(index))),
                    Expanded(flex: 1, child: Center(child: Text(item.rate.toStringAsFixed(2), style: const TextStyle(fontSize: 11)))),
                    Expanded(flex: 1, child: Center(child: Text(item.amount.toStringAsFixed(2), style: const TextStyle(fontSize: 11)))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQtyInput(int index) {
    return Container(
      width: 40,
      height: 30,
      child: TextField(
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        ),
        onChanged: (val) {
          setState(() {
            items[index].qty = int.tryParse(val) ?? 0;
          });
        },
        controller: TextEditingController(text: items[index].qty == 0 ? '' : items[index].qty.toString()),
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Subtotal (${selectedSeries} - ${selectedTitle}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(width: 40),
            Text(grandTotal.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Grand Total :', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(width: 40),
            Text(grandTotal.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(width: 40),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Save Entry', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Go to View', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}

class OrderItem {
  final String bookName;
  final String classes;
  final String subject;
  final double rate;
  int qty;

  OrderItem({
    required this.bookName,
    required this.classes,
    required this.subject,
    required this.rate,
    this.qty = 0,
  });

  double get amount => rate * qty;
}

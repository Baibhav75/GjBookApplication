import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GetManPage extends StatefulWidget {
  const GetManPage({Key? key}) : super(key: key);

  @override
  State<GetManPage> createState() => _GetManPageState();
}

class _GetManPageState extends State<GetManPage> {
  final _nameController = TextEditingController();
  final _infoController = TextEditingController();
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  final _remarkController = TextEditingController();

  bool isCheckIn = true;
  double amount = 0.0;

  final String currentDate =
  DateFormat('dd MMM yyyy').format(DateTime.now());

  void calculateAmount() {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    setState(() => amount = qty * rate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("GetMan Entry"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER CARD
            _sectionCard(
              title: "Entry Details",
              child: Column(
                children: [
                  _readOnlyField("Date", currentDate, Icons.calendar_today),

                  const SizedBox(height: 12),

                  /// CHECK IN / OUT
                  Row(
                    children: [
                      Expanded(
                        child: _segmentButton(
                          text: "Check In",
                          selected: isCheckIn,
                          onTap: () => setState(() => isCheckIn = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _segmentButton(
                          text: "Check Out",
                          selected: !isCheckIn,
                          onTap: () => setState(() => isCheckIn = false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: "Person Information",
              child: Column(
                children: [
                  _textField("Name", _nameController, Icons.person),
                  _textField("Information", _infoController, Icons.info_outline),
                ],
              ),
            ),

            _sectionCard(
              title: "Item Details",
              child: Column(
                children: [
                  _textField("Item Name", _itemController, Icons.inventory_2),

                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          "Quantity",
                          _qtyController,
                          Icons.confirmation_number,
                          calculateAmount,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _numberField(
                          "Rate",
                          _rateController,
                          Icons.currency_rupee,
                          calculateAmount,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _readOnlyField(
                    "Amount",
                    "₹ ${amount.toStringAsFixed(2)}",
                    Icons.calculate,
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: "Remarks & Proof",
              child: Column(
                children: [
                  _textField(
                    "Remark",
                    _remarkController,
                    Icons.note_alt,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text("Capture Image"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Camera action here")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SUBMIT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Form Submitted")),
                  );
                },
                child: const Text(
                  "Submit Entry",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _segmentButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.blueGrey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _textField(
      String label,
      TextEditingController controller,
      IconData icon, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _numberField(
      String label,
      TextEditingController controller,
      IconData icon,
      VoidCallback onChanged,
      ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _readOnlyField(String label, String value, IconData icon) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: value,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

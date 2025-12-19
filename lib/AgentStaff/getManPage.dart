import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../Service/getman_service.dart';
import 'GetManHistoryPage.dart';

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
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();

  final GetManService _service = GetManService();

  bool isCheckIn = true;
  bool isSubmitting = false;

  final String currentDate =
  DateFormat('dd MMM yyyy').format(DateTime.now());

  // 📸 Camera image
  File? _capturedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // ---------------- VALIDATION ----------------

  bool get isItemValid {
    final amountValue = double.tryParse(_amountController.text) ?? 0;
    return amountValue > 0;
  }

  // ---------------- CAMERA ONLY ----------------

  Future<void> _openCamera() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera, // ✅ ONLY CAMERA
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _capturedImage = File(photo.path);
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submitEntry() async {
    if (_nameController.text.trim().isEmpty) {
      _showError("Name is required");
      return;
    }

    if (_itemController.text.trim().isEmpty) {
      _showError("Item name is required");
      return;
    }

    final amountValue = double.tryParse(_amountController.text);
    if (amountValue == null || amountValue <= 0) {
      _showError("Please enter a valid amount");
      return;
    }

    setState(() => isSubmitting = true);

    final response = await _service.submitEntry(
      name: _nameController.text.trim(),
      information: _infoController.text.trim(),
      itemType: isCheckIn ? "CheckIn" : "CheckOut",
      itemName: _itemController.text.trim(),
      qty: _qtyController.text.trim(),
      rate: _rateController.text.trim(),
      amount: amountValue,
      remarks: _remarkController.text.trim(),
       imageFile: _capturedImage, // 🔥 future ready
    );

    setState(() => isSubmitting = false);

    if (response != null && response.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
      _clearForm();
    } else {
      _showError("Failed to submit entry");
    }
  }

  void _clearForm() {
    _nameController.clear();
    _infoController.clear();
    _itemController.clear();
    _qtyController.clear();
    _rateController.clear();
    _amountController.clear();
    _remarkController.clear();
    setState(() => _capturedImage = null);
  }

  void _calculateAmount() {
    final qty = double.tryParse(_qtyController.text);
    final rate = double.tryParse(_rateController.text);

    if (qty == null || rate == null || qty <= 0 || rate <= 0) {
      _amountController.clear();
      return;
    }

    _amountController.text = (qty * rate).toStringAsFixed(2);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("GetMan Entry"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,


        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GetManHistoryPage(),
                ),
              );
            },
          ),
        ],

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionCard(
              title: "Entry Details",
              child: Column(
                children: [
                  _readOnlyField("Date", currentDate, Icons.calendar_today),
                  const SizedBox(height: 12),
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
                            "Quantity", _qtyController, Icons.confirmation_number),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _numberField(
                            "Rate", _rateController, Icons.currency_rupee),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _calculateAmount,
                    icon: const Icon(Icons.calculate),
                    label: const Text("Calculate Amount"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  _numberField("Amount", _amountController, Icons.currency_rupee),
                ],
              ),
            ),

            // 📸 CAMERA SECTION
            _sectionCard(
              title: "Capture Image",
              child: GestureDetector(
                onTap: _openCamera,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade100,
                  ),
                  child: _capturedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _capturedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Tap to open camera"),
                    ],
                  ),
                ),
              ),
            ),

            _sectionCard(
              title: "Remarks",
              child: _textField(
                "Remark",
                _remarkController,
                Icons.note_alt,
                maxLines: 2,
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                (isSubmitting || !isItemValid) ? null : _submitEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Submit Entry",
                  style:
                  TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

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
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue)),
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
              fontWeight: FontWeight.w600),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _numberField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _infoController.dispose();
    _itemController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }
}

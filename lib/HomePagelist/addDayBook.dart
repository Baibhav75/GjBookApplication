import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '/Model/day_book_model.dart';
import '/Service/day_book_service.dart';

class AddDayBook extends StatefulWidget {
  const AddDayBook({super.key});

  @override
  State<AddDayBook> createState() => _AddDayBookState();
}

class _AddDayBookState extends State<AddDayBook> {

  @override
  void dispose() {
    _companyController.dispose();
    _amountController.dispose();
    _expenseController.dispose();
    _receiptController.dispose();
    _mobileController.dispose();
    _remarkController.dispose();
    _dayBookService.dispose();
    super.dispose();
  }

  // Controllers
  final _companyController = TextEditingController();
  final _amountController = TextEditingController();
  final _expenseController = TextEditingController();
  final _receiptController = TextEditingController();
  final _mobileController = TextEditingController();
  final _remarkController = TextEditingController();

  // Form variables
  String? _crdr;
  String? _pickedFilePath;

  bool _isLoading = false;
  bool _testingConnection = false;
  String _connectionStatus = '';

  final DayBookService _dayBookService = DayBookService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testConnection();
    });
  }

  // -------------------- CONNECTION TEST --------------------
  Future<void> _testConnection() async {
    setState(() {
      _testingConnection = true;
      _connectionStatus = 'Testing connection to server...';
    });

    try {
      final result = await _dayBookService.testConnection();
      setState(() {
        _connectionStatus = result['message'] as String;
      });

      if (!(result['success'] as bool)) {
        _showWarningSnackbar(_connectionStatus);
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection test failed: $e';
      });
      _showErrorSnackbar(_connectionStatus);
    } finally {
      if (mounted) {
        setState(() {
          _testingConnection = false;
        });
      }
    }
  }

  // -------------------- PICK FILE --------------------
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedFilePath = result.files.single.path!;
        });
      }
    } catch (e) {
      _showErrorSnackbar('File selection failed: $e');
    }
  }

  // -------------------- SUBMIT --------------------
  Future<void> _onSubmit() async {
    if (_companyController.text.isEmpty) {
      _showErrorSnackbar('Please enter Company/Party Name');
      return;
    }

    if (_crdr == null) {
      _showErrorSnackbar('Please select CR/DR');
      return;
    }

    if (_amountController.text.isEmpty) {
      _showErrorSnackbar('Please enter amount');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dayBook = DayBookModel(
        particularName: _companyController.text.trim(),
        type: _crdr,
        amount: amount,
        expenseVoucherNo: _expenseController.text.trim().isEmpty
            ? null
            : _expenseController.text.trim(),
        receiptVoucherNo: _receiptController.text.trim().isEmpty
            ? null
            : _receiptController.text.trim(),
        mobileNo: _mobileController.text.trim().isEmpty
            ? null
            : _mobileController.text.trim(),
        remarks: _remarkController.text.trim().isEmpty
            ? null
            : _remarkController.text.trim(),
        image: _pickedFilePath,
      );

      final result = await _dayBookService.createDayBook(dayBook);

      if (result['success'] == true) {
        _showSuccessSnackbar(result['message'] as String);
        _clearForm();
      } else {
        _showErrorSnackbar(result['message'] as String);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to create day book: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _clearForm() {
    _companyController.clear();
    _amountController.clear();
    _expenseController.clear();
    _receiptController.clear();
    _mobileController.clear();
    _remarkController.clear();

    setState(() {
      _crdr = null;
      _pickedFilePath = null;
    });
  }

  // -------------------- SNACKBARS --------------------
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showWarningSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Add Day Book", 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _testingConnection ? null : _testConnection,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[900]!, const Color(0xFFF0F4F8)],
            stops: const [0.0, 0.2],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "General Information",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.blueGrey
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      _buildInput(
                        label: "Company/Party Name",
                        isRequired: true,
                        controller: _companyController,
                        hint: "Search or enter name",
                        icon: Icons.business_rounded,
                      ),

                      _buildInput(
                        label: "Transaction Type",
                        isRequired: true,
                        icon: Icons.swap_vert_rounded,
                        child: DropdownButtonFormField<String>(
                          value: _crdr,
                          hint: const Text("-- Select Transaction Type --"),
                          items: const [
                            DropdownMenuItem(value: "Credit", child: Text("Credit")),
                            DropdownMenuItem(value: "Debit", child: Text("Debit")),
                          ],
                          onChanged: (v) => setState(() => _crdr = v),
                          decoration: _fieldDecoration(null, null),
                        ),
                      ),

                      _buildInput(
                        label: "Amount (\u20B9)",
                        isRequired: true,
                        controller: _amountController,
                        hint: "0.00",
                        keyboard: TextInputType.number,
                        icon: Icons.account_balance_wallet_rounded,
                      ),

                      const Divider(height: 40),
                      const Center(
                        child: Text(
                          "Voucher & Contact",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.blueGrey
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _buildInput(
                              label: "Expense No",
                              controller: _expenseController,
                              hint: "Exp #",
                              icon: Icons.receipt_long_rounded,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildInput(
                              label: "Receipt No",
                              controller: _receiptController,
                              hint: "Rec #",
                              icon: Icons.receipt_rounded,
                            ),
                          ),
                        ],
                      ),

                      _buildInput(
                        label: "Mobile Number",
                        controller: _mobileController,
                        hint: "+91 xxxxxxxxxx",
                        keyboard: TextInputType.phone,
                        icon: Icons.phone_android_rounded,
                      ),

                      _buildInput(
                        label: "Remark",
                        controller: _remarkController,
                        hint: "Any additional details...",
                        maxLines: 3,
                        icon: Icons.notes_rounded,
                      ),

                      _buildInput(
                        label: "Attachments",
                        icon: Icons.attach_file_rounded,
                        child: InkWell(
                          onTap: _pickFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.cloud_upload_outlined, color: Colors.blue[800]),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _pickedFilePath == null
                                        ? "Upload receipt or document"
                                        : _pickedFilePath!.split('/').last,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _pickedFilePath == null ? Colors.grey : Colors.black87
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.blue[800]!, Colors.blue[900]!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "SAVE ENTRY",
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- HELPERS --------------------
  Widget _buildInput({
    required String label,
    bool isRequired = false,
    TextEditingController? controller,
    String? hint,
    Widget? child,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.blue[900]),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
              ),
              if (isRequired)
                const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          child ??
              TextFormField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboard,
                style: const TextStyle(fontSize: 15),
                decoration: _fieldDecoration(hint, null),
              ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String? hint, IconData? suffixIcon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue[900]!, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}

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

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dayBook = DayBookModel(
        company: _companyController.text.trim(),
        crdr: _crdr,
        amount: _amountController.text.trim(),
        expenseNo: _expenseController.text.trim().isEmpty ? null : _expenseController.text.trim(),
        receiptNo: _receiptController.text.trim().isEmpty ? null : _receiptController.text.trim(),
        mobile: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
        filePath: _pickedFilePath,
        createdAt: DateTime.now(),
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
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text("Add Day Book", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testingConnection ? null : _testConnection,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CONNECTION STATUS


            const SizedBox(height: 10),

            // -------------------- FORM --------------------
            _buildInput(
              label: "Company/Party",
              isRequired: true,
              controller: _companyController,
              hint: "Enter Company/Party Name",
            ),

            _buildInput(
              label: "Select Cr/Dr",
              isRequired: true,
              child: DropdownButtonFormField<String>(
                value: _crdr,
                hint: const Text("-- Select CR/DR --"),
                items: const [
                  DropdownMenuItem(value: "CR", child: Text("CR")),
                  DropdownMenuItem(value: "DR", child: Text("DR")),
                ],
                onChanged: (v) => setState(() => _crdr = v),
                decoration: _fieldDecoration(null),
              ),
            ),

            _buildInput(
              label: "Amount",
              isRequired: true,
              controller: _amountController,
              hint: "Enter Amount",
              keyboard: TextInputType.number,
            ),

            _buildInput(
              label: "Expense Voucher No",
              controller: _expenseController,
              hint: "Enter Expense Voucher No",
            ),

            _buildInput(
              label: "Receipt Voucher No",
              controller: _receiptController,
              hint: "Enter Receipt Voucher No",
            ),

            _buildInput(
              label: "Mobile Number",
              controller: _mobileController,
              hint: "Enter Mobile Number",
              keyboard: TextInputType.phone,
            ),

            _buildInput(
              label: "Remark",
              controller: _remarkController,
              hint: "Enter Remark",
              maxLines: 3,
            ),

            _buildInput(
              label: "Attach File",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Choose File"),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _pickedFilePath == null
                        ? "No file selected"
                        : _pickedFilePath!.split('/').last,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ${isRequired ? '*' : ''}",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          child ??
              TextFormField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboard,
                decoration: _fieldDecoration(hint),
              ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3498db), width: 2),
      ),
    );
  }
}

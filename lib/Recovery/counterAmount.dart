import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CounterAmountPage extends StatefulWidget {
  const CounterAmountPage({Key? key}) : super(key: key);

  @override
  State<CounterAmountPage> createState() => _CounterAmountPageState();
}

class _CounterAmountPageState extends State<CounterAmountPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  String? selectedEmployee;
  String? selectedPaymentType;

  File? receiptImage;

  final List<String> employeeList = [
    "Rahul",
    "Amit",
    "Vikas",
    "Suresh"
  ];

  final List<String> paymentTypeList = [
    "Cash",
    "Account"
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        receiptImage = File(pickedFile.path);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (receiptImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload receipt image")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved Successfully")),
      );

      // TODO: API Call Here
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Counter Amount"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// Employee Dropdown
              DropdownButtonFormField<String>(
                value: selectedEmployee,
                decoration: const InputDecoration(
                  labelText: "Employee Name",
                  border: OutlineInputBorder(),
                ),
                items: employeeList
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEmployee = value;
                  });
                },
                validator: (value) =>
                value == null ? "Please select employee" : null,
              ),

              const SizedBox(height: 16),

              /// Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter amount";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// Account / Cash Dropdown
              DropdownButtonFormField<String>(
                value: selectedPaymentType,
                decoration: const InputDecoration(
                  labelText: "Account / Cash",
                  border: OutlineInputBorder(),
                ),
                items: paymentTypeList
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPaymentType = value;
                  });
                },
                validator: (value) =>
                value == null ? "Select payment type" : null,
              ),

              const SizedBox(height: 16),

              /// Receipt Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: receiptImage == null
                      ? const Center(
                    child: Text("Upload Receipt Image"),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      receiptImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Remark
              TextFormField(
                controller: _remarkController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Remark",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              /// Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16,
                    color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
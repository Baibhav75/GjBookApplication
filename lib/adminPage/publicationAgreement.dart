import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PublicationAgreementPage extends StatefulWidget {
  const PublicationAgreementPage({super.key});

  @override
  State<PublicationAgreementPage> createState() => _PublicationAgreementPageState();
}

class _PublicationAgreementPageState extends State<PublicationAgreementPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _publicationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _checkNumberController = TextEditingController();

  File? _agreementFile;
  File? _checkFile;

  VoidCallback? get _refreshData => null;

  Future<void> _pickFile(bool isAgreement) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        if (isAgreement) {
          _agreementFile = File(result.files.single.path!);
        } else {
          _checkFile = File(result.files.single.path!);
        }
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Form Submitted Successfully!")),
      );
    }
  }

  Widget _buildFilePicker({
    required String label,
    required File? file,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          flex: 5,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.attach_file),
            label: Text(file == null ? 'Choose File' : 'File Selected'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publication'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // 🔔 Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Add your notification handler here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),

          // 🔄 Refresh Icon
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData, // ✅ already defined in your state
          ),

          // ⚙️ Popup Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              _handlePopupMenuSelection(value);
            },
            itemBuilder: (BuildContext context) {
              return ['Profile', 'Settings', 'Help', 'Logout']
                  .map((String choice) => PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              ))
                  .toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.article, color: Colors.blue),
                      SizedBox(width: 6),
                      Text(
                        "Publication Agreement",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),
                  _buildTextField("Publication", _publicationController, "Enter Publication"),
                  _buildTextField("Address", _addressController, "Enter full Address"),
                  _buildTextField("Mobile No", _mobileController, "Mobile Number",
                      keyboardType: TextInputType.phone),
                  _buildTextField("Email", _emailController, "Enter Email",
                      keyboardType: TextInputType.emailAddress),
                  _buildTextField("Checks Number", _checkNumberController, "Enter Check Number"),
                  const SizedBox(height: 10),
                  _buildFilePicker(
                    label: "Agreement From",
                    file: _agreementFile,
                    onPressed: () => _pickFile(true),
                  ),
                  const SizedBox(height: 10),
                  _buildFilePicker(
                    label: "Checks",
                    file: _checkFile,
                    onPressed: () => _pickFile(false),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
            ),
          ),
        ],
      ),
    );
  }
}

void _handlePopupMenuSelection(String value) {
}

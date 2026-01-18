import 'package:flutter/material.dart';

class NewTicketScreen extends StatefulWidget {
  final String schoolName; // coming from backend

  const NewTicketScreen({
    super.key,
    required this.schoolName,
  });

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _contactController =
  TextEditingController();
  final TextEditingController _messageController =
  TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (_formKey.currentState!.validate()) {
      // 🔹 API CALL WILL GO HERE
      final contactNo = _contactController.text;
      final message = _messageController.text;

      debugPrint("School: ${widget.schoolName}");
      debugPrint("Contact: $contactNo");
      debugPrint("Message: $message");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket submitted successfully")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Ticket"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔹 SCHOOL NAME (READ ONLY)
              TextFormField(
                initialValue: widget.schoolName,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "School Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 CONTACT NUMBER
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Contact No",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Contact number is required";
                  }
                  if (v.length != 10) {
                    return "Enter valid 10 digit number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// 🔹 MESSAGE
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Message cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// 🔹 SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 16),
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

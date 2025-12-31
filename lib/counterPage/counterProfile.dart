import 'package:flutter/material.dart';
import '../Model/counter_profile_model.dart';
import '../Service/counter_profile_service.dart';

class CounterProfile extends StatefulWidget {
  final String mobileNo;

  const CounterProfile({Key? key, required this.mobileNo}) : super(key: key);

  @override
  State<CounterProfile> createState() => _CounterProfileState();
}

class _CounterProfileState extends State<CounterProfile> {
  late Future<CounterProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture =
        CounterProfileService.fetchProfile(mobileNo: widget.mobileNo);
  }

  Widget _item(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? 'N/A' : value),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Counter Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<CounterProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data?.data == null) {
            return const Center(child: Text("Failed to load profile"));
          }

          final data = snapshot.data!.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade100,
                  child:
                  const Icon(Icons.person, size: 50, color: Colors.blue),
                ),
                const SizedBox(height: 8),

                Text(
                  data.counterBoyName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  data.counterName,
                  style: const TextStyle(color: Colors.grey),
                ),

                _section("Basic Information"),
                _item("Counter ID", data.counterId, Icons.badge),
                _item("Mobile", data.mobile, Icons.phone),
                _item("School Name", data.schoolName, Icons.school),
                _item("Cash Limit", "₹ ${data.cashLimit}",
                    Icons.currency_rupee),

                _section("Personal Details"),
                _item("Father Name", data.fatherName, Icons.man),
                _item("Mother Name", data.motherName, Icons.woman),

                _section("Documents"),
                _item("Agreement", "Uploaded", Icons.file_present),
                _item("Cancel Check", "Uploaded", Icons.file_present),
                _item("Marksheet", "Uploaded", Icons.file_present),
                _item("Aadhar Card", "Uploaded", Icons.file_present),
              ],
            ),
          );
        },
      ),
    );
  }
}

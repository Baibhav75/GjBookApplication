import 'package:flutter/material.dart';
import '../Model/getman_profile_model.dart';
import '../Service/getman_profile_service.dart';

class GetManProfilePage extends StatefulWidget {
  final String mobileNo;

  const GetManProfilePage({Key? key, required this.mobileNo}) : super(key: key);

  @override
  State<GetManProfilePage> createState() => _GetManProfilePageState();
}

class _GetManProfilePageState extends State<GetManProfilePage> {
  late Future<GetManProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture =
        GetManProfileService().fetchProfile(widget.mobileNo);
  }

  Widget _item(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Security Guard Profile',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: FutureBuilder<GetManProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 8),
                Text(profile.employeeName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(profile.designation),

                _section("Basic Information"),
                _item("Employee ID", profile.employeeId, Icons.badge),
                _item("Email", profile.email, Icons.email),
                _item("Mobile", profile.mobile, Icons.phone),
                _item("Alternate", profile.alternate, Icons.phone_android),
                _item("Department", profile.department, Icons.apartment),
                _item("Employee Type", profile.employeeType, Icons.people),

                _section("Personal Details"),
                _item("Father Name", profile.fatherName, Icons.man),
                _item("Mother Name", profile.motherName, Icons.woman),
                _item("DOB", profile.dob, Icons.cake),
                _item("Gender", profile.gender, Icons.male),
                _item("Marital Status", profile.maritalStatus, Icons.family_restroom),

                _section("Address"),
                _item("Permanent Address", profile.permanentAddress, Icons.home),
                _item("Current Address", profile.currentAddress, Icons.location_on),

                _section("Job Details"),
                _item("Joining Date", profile.joiningDate, Icons.date_range),
                _item("Salary", "₹ ${profile.salary}", Icons.currency_rupee),
              ],
            ),
          );
        },
      ),
    );
  }
}

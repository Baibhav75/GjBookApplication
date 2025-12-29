import 'package:flutter/material.dart';

class counterProfile extends StatelessWidget {
  final String mobileNo;

  const counterProfile({Key? key, required this.mobileNo}) : super(key: key);

  // ================= STATIC DATA =================
  final Map<String, String> profile = const {
    "employeeId": "SG-1024",
    "employeeName": "Ramesh Kumar",
    "designation": "Security Guard",
    "email": "ramesh.guard@example.com",
    "mobile": "9876543210",
    "alternate": "9123456789",
    "department": "Security",
    "employeeType": "Full Time",

    "fatherName": "Suresh Kumar",
    "motherName": "Sunita Devi",
    "dob": "12 Aug 1992",
    "gender": "Male",
    "maritalStatus": "Married",

    "permanentAddress":
    "Village Rampur, Post Rampur, District Gorakhpur, Uttar Pradesh",
    "currentAddress":
    "Sector 22, Noida, Gautam Buddh Nagar, Uttar Pradesh",

    "joiningDate": "01 Jan 2022",
    "salary": "15000",
  };

  // ================= UI HELPERS =================
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
            color: Colors.blue),
      ),
    );
  }

  // ================= MAIN =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Security Guard Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // PROFILE HEADER
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 50, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(profile["employeeName"]!,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text(profile["designation"]!,
                style: const TextStyle(color: Colors.grey)),

            _section("Basic Information"),
            _item("Employee ID", profile["employeeId"]!, Icons.badge),
            _item("Email", profile["email"]!, Icons.email),
            _item("Mobile", profile["mobile"]!, Icons.phone),
            _item("Alternate", profile["alternate"]!, Icons.phone_android),
            _item("Department", profile["department"]!, Icons.apartment),
            _item("Employee Type", profile["employeeType"]!, Icons.people),

            _section("Personal Details"),
            _item("Father Name", profile["fatherName"]!, Icons.man),
            _item("Mother Name", profile["motherName"]!, Icons.woman),
            _item("DOB", profile["dob"]!, Icons.cake),
            _item("Gender", profile["gender"]!, Icons.male),
            _item("Marital Status", profile["maritalStatus"]!,
                Icons.family_restroom),

            _section("Address"),
            _item("Permanent Address", profile["permanentAddress"]!,
                Icons.home),
            _item("Current Address", profile["currentAddress"]!,
                Icons.location_on),

            _section("Job Details"),
            _item("Joining Date", profile["joiningDate"]!,
                Icons.date_range),
            _item("Salary", "₹ ${profile["salary"]}",
                Icons.currency_rupee),
          ],
        ),
      ),
    );
  }
}

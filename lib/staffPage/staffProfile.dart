import 'package:flutter/material.dart';
import '../Model/staff_profile_model.dart';
import '../Service/staff_profile_service.dart';

class StaffProfilePage extends StatefulWidget {
  final String mobileNo;

  const StaffProfilePage({super.key, required this.mobileNo});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  StaffProfileModel? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// ---------------- FETCH PROFILE API -----------------
  Future<void> loadProfile() async {
    try {
      final service = StaffProfileService();
      final data = await service.fetchProfile(widget.mobileNo);

      setState(() {
        profile = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        profile = null;
      });
    }
  }

  /// ------------------- UI HELPERS ----------------------

  Widget _buildItem(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          value.isEmpty ? "N/A" : value,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 20, bottom: 8),
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

  /// ------------------- MAIN UI -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("AgentStaff Profile"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? const Center(
              child: Text(
                "No Profile Found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : _buildProfileBody(),
    );
  }

  /// ---------------- PROFILE BODY -----------------------

  Widget _buildProfileBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PROFILE HEADER
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile!.employeeName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profile!.designation,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),

          _sectionTitle("Basic Information"),
          _buildItem("Agent Id", profile!.employeeId, Icons.badge),
          _buildItem("Email", profile!.email, Icons.email),
          _buildItem("Mobile", profile!.mobile, Icons.phone),
          _buildItem("Alternate No", profile!.alternate, Icons.phone_android),
          _buildItem("Department", profile!.department, Icons.account_tree),
          _buildItem("Designation", profile!.designation, Icons.work),
          _buildItem("Employee Type", profile!.employeeType, Icons.people_alt),

          _sectionTitle("Personal Details"),
          _buildItem("Father Name", profile!.fatherName, Icons.man),
          _buildItem("Mother Name", profile!.motherName, Icons.woman),
          _buildItem("DOB", profile!.dob, Icons.calendar_today),
          _buildItem("Gender", profile!.gender, Icons.male),
          _buildItem(
            "Marital Status",
            profile!.maritalStatus,
            Icons.family_restroom,
          ),

          _sectionTitle("Address Details"),
          _buildItem(
            "Permanent Address",
            profile!.permanentAddress,
            Icons.home,
          ),
          _buildItem(
            "Current Address",
            profile!.currentAddress,
            Icons.location_on,
          ),

          _sectionTitle("Job Details"),
          _buildItem("Joining Date", profile!.joiningDate, Icons.date_range),
          _buildItem("Salary", "₹ ${profile!.salary}", Icons.currency_rupee),
        ],
      ),
    );
  }
}

import 'package:bookworld/staffPage/addSchoolPage.dart';
import 'package:bookworld/staffPage/attendanceCheckIn.dart';
import 'package:bookworld/staffPage/staffChangePassword.dart';
import 'package:bookworld/staffPage/staffProfile.dart';
import 'package:flutter/material.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/home_screen.dart';

import 'AddSurvey.dart';

  class StaffPage extends StatefulWidget {
  final String agentName;
  final String employeeType;
  final String email;
  final String password;
  final String mobile;

  const StaffPage({
    Key? key,
    required this.agentName,
    required this.employeeType,
    required this.email,
    required this.password,
    required this.mobile,
  }) : super(key: key);

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  int _currentIndex = 0;

  late String staffName;
  late String staffEmail;
  late String staffPosition;
  late String staffId;
  late String staffMobile;

  @override
  void initState() {
    super.initState();

    staffName = widget.agentName;
    staffEmail = widget.email;
    staffPosition = widget.employeeType;
    staffId = "EMP-${widget.password}";
    staffMobile = widget.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _showNotifications, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        ],
      ),

      drawer: _buildDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dashboardOverview(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // DRAWER
  // ---------------------------------------------------

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _drawerHeader(),
          _drawerTile(Icons.dashboard, "Dashboard", 0),

          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaffHistoryPage(mobileNo: staffMobile),
                ),
              );
            },
          ),

          _drawerTile(Icons.history, "Attendance History", 2),

          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            children: [
              ListTile(
                leading: const Icon(Icons.assignment_add, color: Colors.blue),
                title: const Text("Change Password"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  ChangePasswordPage()),
                  );
                },
              ),
            ],
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: _logout,
          )
        ],
      ),
    );
  }

  Widget _drawerHeader() {
    return Container(
      height: 200,
      color: Colors.blue[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 10),
          Text(staffName, style: const TextStyle(color: Colors.white, fontSize: 18)),
          Text(staffPosition, style: const TextStyle(color: Colors.white70)),
          Text(staffMobile, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }

  // ---------------------------------------------------
  // DASHBOARD OVERVIEW
  // ---------------------------------------------------

  Widget _dashboardOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Dashboard Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "View All",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              )
            ],
          ),

          const SizedBox(height: 28),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
            childAspectRatio: 0.65,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceCheckIn(
                        agentName: staffName,
                        employeeType: staffPosition,
                        mobile: staffMobile,
                      ),
                    ),
                  );
                },
                child: _dashboardItem(Icons.school, "Attendance", Colors.orange),
              ),

              _dashboardItem(Icons.history, "History", Colors.blue),
              _dashboardItem(Icons.assignment, "Survey History", Colors.purple),


              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddSurvey()),
                  );
                },
                child: _dashboardItem(Icons.school, "Add School", Colors.orange),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffHistoryPage(
                        mobileNo: staffMobile,   // <-- pass your variable here
                      ),
                    ),
                  );
                },
                child: _dashboardItem(Icons.person, "Profile", Colors.orange),
              ),



              _dashboardItem(Icons.settings, "Setting", Colors.teal),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  ChangePasswordPage()),
                  );
                },
                child:_dashboardItem(Icons.assignment_add, "Change Password", Colors.cyan),


              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddSchoolPage()),
                  );
                },
                child:_dashboardItem(Icons.assignment_add, "Add Survey", Colors.cyan),


              ),
            ],

          ),
        ],
      ),
    );
  }

  Widget _dashboardItem(IconData icon, String title, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,   // ← prevents extra height usage
      children: [
        Container(
          height: 55,   // ← reduced height
          width: 55,    // ← reduced width
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28), // ← smaller icon
        ),
        const SizedBox(height: 6),
        Flexible(                              // ← prevents overflow
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,                       // ← avoid long text overflow
            overflow: TextOverflow.ellipsis,   // ← safe text wrapping
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }


  // ---------------------------------------------------
  // BUTTON ACTIONS
  // ---------------------------------------------------

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No Notifications")),
    );
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dashboard Refreshed")),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Change password coming soon")),
    );
  }

  void _logout() async {
    final storage = SecureStorageService();
    await storage.clearAllCredentials();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}

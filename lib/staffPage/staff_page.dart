import 'dart:io';
import 'package:bookworld/staffPage/schoolAgent.dart';

import '/staffPage/staffhistory.dart';

import 'package:bookworld/staffPage/surver_detail.dart';
import 'package:bookworld/Model/survey_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bookworld/staffPage/addSchoolPage.dart';
import 'package:bookworld/staffPage/attendanceCheckIn.dart';
import 'package:bookworld/staffPage/attendanceCheckOut.dart';
import 'package:bookworld/staffPage/staffChangePassword.dart';
import 'package:bookworld/staffPage/staffProfile.dart';
import 'package:flutter/material.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/home_screen.dart';

import 'AddSurvey.dart';

// --------------------------------------------------
// STAFF PAGE MAIN CLASS
// --------------------------------------------------

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

              // 🔥 ADD ANIMATED BANNER BELOW APPBAR
              AnimatedBanner(),
              SizedBox(height: 20),

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

          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("attendance history"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaffHistoryPage(mobileNo: '',),
                ),
              );
            },
          ),

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
                    MaterialPageRoute(builder: (_) => ChangePasswordPage()),
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

              // -------- Attendance Button ---------
              GestureDetector(
                onTap: () async {
                  final storageService = SecureStorageService();
                  final hasCheckedIn = await storageService.hasCheckedIn();

                  if (hasCheckedIn) {
                    final checkInData = await storageService.getCheckInData();
                    _navigateToCheckout(context, checkInData);
                  } else {
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
                  }
                },
                child: _dashboardItem(Icons.work_history
                    , "Attendance", Colors.green),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryPage(mobileNo: '',),
                    ),
                  );
                },
                child: _dashboardItem(
                  Icons.history,
                  "Attendance History",
                  Colors.orange,
                ),
              ),






              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddSurvey()),
                  );
                },
                child: _dashboardItem(Icons.assignment, "survey History", Colors.deepPurpleAccent),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffHistoryPage(
                        mobileNo: staffMobile,
                      ),
                    ),
                  );
                },
                child: _dashboardItem(Icons.account_circle, "Profile", Colors.lightBlueAccent),
              ),



              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChangePasswordPage()),
                  );
                },
                child: _dashboardItem(Icons.password, "Change Password", Colors.cyan),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddSchoolPage()),
                  );
                },
                child: _dashboardItem(Icons.search, "Add Survey", Colors.cyan),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SchoolAgentPage()),// school agent
                  );
                },
                child: _dashboardItem(Icons.cast_for_education, "Add school list", Colors.cyan),
              ),
            ],

          ),
        ],
      ),
    );
  }

  Widget _dashboardItem(IconData icon, String title, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

  void _logout() async {
    final storage = SecureStorageService();
    await storage.clearAllCredentials();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  // ---------------------------------------------------
  // CHECKOUT NAVIGATION
  // ---------------------------------------------------

  void _navigateToCheckout(BuildContext context, Map<String, String?> checkInData) {
    try {
      final checkInTimeStr = checkInData['time'];
      if (checkInTimeStr == null || checkInTimeStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid check-in data. Please check in again.')),
        );
        return;
      }

      final checkInTime = DateTime.parse(checkInTimeStr);

      final photoPath = checkInData['photoPath'];
      File? checkInPhoto;
      if (photoPath != null && photoPath.isNotEmpty) {
        final photoFile = File(photoPath);
        if (photoFile.existsSync()) {
          checkInPhoto = photoFile;
        }
      }

      final latStr = checkInData['latitude'];
      final lngStr = checkInData['longitude'];
      Position? checkInPosition;
      if (latStr != null && lngStr != null) {
        final lat = double.tryParse(latStr);
        final lng = double.tryParse(lngStr);
        if (lat != null && lng != null) {
          checkInPosition = Position(
            latitude: lat,
            longitude: lng,
            timestamp: checkInTime,
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }

      final address = checkInData['address'] ?? 'Location not available';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceCheckOut(
            checkInTime: checkInTime,
            checkInPhoto: checkInPhoto,
            checkInPosition: checkInPosition,
            checkInAddress: address,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading check-in: ${e.toString()}')),
      );
      SecureStorageService().clearCheckInData();
    }
  }
}

// -------------------------------------------------------------
// ANIMATED BANNER WIDGET (BEAUTIFUL SLIDE + GRADIENT)
// -------------------------------------------------------------

class AnimatedBanner extends StatefulWidget {
  @override
  _AnimatedBannerState createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<AnimatedBanner>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _slide = Tween<Offset>(
      begin: Offset(-0.05, 0),
      end: Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade500,
              Colors.lightBlueAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.campaign, color: Colors.white, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Welcome Back! Have a productive day ahead 🚀",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

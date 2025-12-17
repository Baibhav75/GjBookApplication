/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/home_screen.dart';

import 'attendanceCheckIn.dart';
import 'attendanceCheckOut.dart';
import 'staffhistory.dart';
import 'staffChangePassword.dart';
import 'addSchoolPage.dart';
import 'schoolAgent.dart';
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

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: _showNotifications, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        ],
      ),

      drawer: _buildDrawer(),
      bottomNavigationBar: _animatedFooter(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AnimatedBanner(),
              const SizedBox(height: 20),
              _dashboardOverview(),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // DRAWER
  // --------------------------------------------------

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
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
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Attendance History"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage(mobileNo: '')),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.password),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChangePasswordPage()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DASHBOARD
  // --------------------------------------------------

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
                    MaterialPageRoute(builder: (_) => schoolAgent()),// school agent
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

  Widget _dashboardItem(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ANIMATED FOOTER
  // --------------------------------------------------

  Widget _animatedFooter() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.dashboard, "Home", 0),
          _footerItem(Icons.work_history, "Attendance", 1),
          _footerItem(Icons.assignment, "Survey", 2),
          _footerItem(Icons.person, "Profile", 3),
          _footerItem(Icons.settings, "Settings", 4),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String label, int index) {
    final bool selected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);

        if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const HistoryPage(mobileNo: '')));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddSurvey()));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(icon, color: selected ? Colors.blue : Colors.grey),
            ),
            Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.blue : Colors.grey)),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ACTIONS
  // --------------------------------------------------

  void _handleAttendance() async {
    final storage = SecureStorageService();
    final checkedIn = await storage.hasCheckedIn();

    if (checkedIn) {
      final data = await storage.getCheckInData();
      _navigateToCheckout(context, data);
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
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No notifications")));
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Refreshed")));
  }

  void _logout() async {
    await SecureStorageService().clearAllCredentials();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _navigateToCheckout(
      BuildContext context,
      Map<String, String?> checkInData,
      ) {
    try {
      // 1️⃣ Validate check-in time
      final checkInTimeStr = checkInData['time'];
      if (checkInTimeStr == null || checkInTimeStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid check-in data. Please check in again.'),
          ),
        );
        return;
      }

      final DateTime checkInTime = DateTime.parse(checkInTimeStr);

      // 2️⃣ Load check-in photo (if exists)
      File? checkInPhoto;
      final photoPath = checkInData['photoPath'];
      if (photoPath != null && photoPath.isNotEmpty) {
        final file = File(photoPath);
        if (file.existsSync()) {
          checkInPhoto = file;
        }
      }

      // 3️⃣ Create Position object (IMPORTANT FIX)
      Position? checkInPosition;
      final latStr = checkInData['latitude'];
      final lngStr = checkInData['longitude'];

      if (latStr != null && lngStr != null) {
        final double? lat = double.tryParse(latStr);
        final double? lng = double.tryParse(lngStr);

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

      // 4️⃣ Address fallback
      final String address =
          checkInData['address'] ?? 'Location not available';

      // 5️⃣ Navigate to Checkout page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceCheckOut(
            checkInTime: checkInTime,
            checkInPhoto: checkInPhoto,
            checkInPosition: checkInPosition, // ✅ REQUIRED PARAM FIXED
            checkInAddress: address,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading check-in: $e')),
      );

      SecureStorageService().clearCheckInData();
    }
  }

}

// --------------------------------------------------
// ANIMATED BANNER
// --------------------------------------------------

class AnimatedBanner extends StatefulWidget {
  @override
  State<AnimatedBanner> createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<AnimatedBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _slide = Tween(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: [
            Icon(Icons.campaign, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Welcome Back! Have a productive day 🚀",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'dart:io';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/staffPage/schoolAgent.dart';

import '../Service/staff_profile_service.dart';
import '/staffPage/staffhistory.dart';
import '/staffPage/add_school_survey_page.dart';

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
import 'agent_school_sale_page.dart';

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

  // ✅ DASHBOARD DEFAULT DATA
  late String userName;
  late String mobileNo;
  double totalTarget = 50000;
  double expenseLimit = 15000;
  double totalLimit = 30000;

  @override
  void initState() {
    super.initState();

    staffName = widget.agentName;
    staffEmail = widget.email;
    staffPosition = widget.employeeType;
    staffMobile = widget.mobile;

    // ✅ banner ke liye
    userName = staffName;
    mobileNo = staffMobile;


    _saveEmployeeId(); // 🔥 CALL HERE
  }
  Future<void> _saveEmployeeId() async {
    try {
      final service = StaffProfileService();
      final profile = await service.fetchProfile(widget.mobile);

      if (profile != null && profile.employeeId.isNotEmpty) {
        await SecureStorageService().saveStaffCredentials(
          username: widget.mobile,
          password: widget.password,
          employeeType: widget.employeeType,
          agentName: widget.agentName,
          employeeId: profile.employeeId, // ✅ REAL EMPLOYEE ID
        );

        debugPrint("Employee ID saved: ${profile.employeeId}");
      }
    } catch (e) {
      debugPrint("Failed to save employee ID: $e");
    }
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
              AnimatedBanner(
                userName: staffName,
                mobileNo: staffMobile,
                totalTarget: 50000,
                expenseLimit: 15000,
                totalLimit: 30000,
              ),

              const SizedBox(height: 20),
              _dashboardOverview(),
              const SizedBox(height: 80), // ⬅️ SPACE FOR FOOTER
            ],
          ),
        ),
      ),

      // 🔥 ADD THIS
      bottomNavigationBar: AnimatedFooter(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          // OPTIONAL: NAVIGATION LOGIC
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => HistoryPage(mobileNo: staffMobile)
                ));
          }
          if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => StaffProfilePage(mobileNo: staffMobile)));
          }
        },
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
                  builder: (_) => StaffProfilePage(mobileNo: staffMobile),
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
                  builder: (_) => HistoryPage(mobileNo: staffMobile,),
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

          const SizedBox(height: 20),

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
                      builder: (_) => HistoryPage(mobileNo: staffMobile),
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
                    MaterialPageRoute(builder: (_) => schoolAgent()),
                  );
                },
                child: _dashboardItem(Icons.edit, "survey edit", Colors.deepPurpleAccent),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffProfilePage(
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
                onTap: () async {
                  final storage = SecureStorageService();

                  final employeeId = await storage.getStaffEmployeeId();

                  if (employeeId == null || employeeId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Employee ID not found")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgentSchoolSalePage(
                        agentId: employeeId, // ✅ dynamic AgentId
                      ),
                    ),
                  );
                },
                child: _dashboardItem(
                  Icons.sd_card_alert,
                  "sale",
                  Colors.orange,
                ),
              ),

              GestureDetector(
                onTap: () async {
                  final storage = SecureStorageService();

                  final employeeId = await storage.getStaffEmployeeId();

                  if (employeeId == null || employeeId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Employee ID not found")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddSchoolSurveyPage(
                        agentId: employeeId, // ✅ dynamic AgentId
                      ),
                    ),
                  );
                },
                child: _dashboardItem(
                  Icons.cast_for_education,
                  "Add school list",
                  Colors.cyan,
                ),
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
// ---------------------------------------------------
// 🔥 ANIMATED FOOTER (CUSTOM BOTTOM BAR)
// ---------------------------------------------------
class AnimatedFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedFooter({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72, // ✅ reduced height
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.grid_view, "Dashboard", 0),
          _item(Icons.history, "Attendance history", 1),
          _item(Icons.search, "Search", 2),
          _item(Icons.account_circle, "profile", 3),
          _item(Icons.bar_chart, "Reports", 4),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 ICON ANIMATION
            AnimatedScale(
              scale: isSelected ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFF0C6BE3)
                    : Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 4),

            // 🔥 TEXT SMOOTH SLIDE + FADE
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: isSelected
                  ? Text(
                label,
                key: ValueKey(label),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0C6BE3),
                ),
              )
                  : const SizedBox(key: ValueKey("empty")),
            ),
          ],
        ),
      ),
    );
  }
}





// -------------------------------------------------------------
// ANIMATED BANNER WIDGET (BEAUTIFUL SLIDE + GRADIENT)
// -------------------------------------------------------------

class AnimatedBanner extends StatefulWidget {
  final String userName;
  final String mobileNo;
  final double totalTarget;
  final double expenseLimit;
  final double totalLimit;

  const AnimatedBanner({
    Key? key,
    required this.userName,
    required this.mobileNo,
    required this.totalTarget,
    required this.expenseLimit,
    required this.totalLimit,
  }) : super(key: key);

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slide = Tween<Offset>(
      begin: const Offset(-0.04, 0),
      end: const Offset(0.04, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.lightBlueAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------
            // TOP ROW : USER INFO
            // -------------------------------------------------
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "📞 ${widget.mobileNo}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.campaign, color: Colors.white, size: 26),
              ],
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------
            // DIVIDER
            // -------------------------------------------------
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white.withOpacity(0.3),
            ),

            const SizedBox(height: 14),

            // -------------------------------------------------
            // STATS ROW
            // -------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem(
                  "Target",
                  "₹${widget.totalTarget.toStringAsFixed(0)}",
                ),
                _statItem(
                  "Expense",
                  "₹${widget.expenseLimit.toStringAsFixed(0)}",
                ),
                _statItem(
                  "Limit",
                  "₹${widget.totalLimit.toStringAsFixed(0)}",
                ),
              ],
            ),

            const SizedBox(height: 12),

            // -------------------------------------------------
            // FOOTER MESSAGE
            // -------------------------------------------------
            const Text(
              "Have a productive day ahead 🚀",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // SMALL STAT ITEM WIDGET
  // -------------------------------------------------
  Widget _statItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
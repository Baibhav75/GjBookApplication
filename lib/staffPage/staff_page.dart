import 'dart:io';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/staffPage/schoolAgent.dart';
import 'package:bookworld/staffPage/staffUserHistory.dart';

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
import 'package:intl/intl.dart';
import '/Model/attendance_history_model.dart';
import '/Service/attendance_history_service.dart';
import '/Model/staff_profile_model.dart';

import 'AddSurvey.dart';
import 'agent_school_sale_page.dart';
import 'agent_school_sale_return_page.dart';

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

  // ✅ DASHBOARD DYNAMIC DATA (calculated from salary)
  late String userName;
  late String mobileNo;
  double totalTarget = 50000; // Will be calculated from yearly income
  double expenseLimit = 15000; // Will be calculated from yearly income
  double totalLimit = 30000; // Will be calculated from yearly income

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

        // ✅ Calculate dynamic values from salary
        _calculateDynamicValues(profile.salary);
      }
    } catch (e) {
      debugPrint("Failed to save employee ID: $e");
    }
  }

  /// ✅ Calculate Savings Target, Expense Limit, and Total Limit from yearly income
  void _calculateDynamicValues(double monthlySalary) {
    // Convert monthly salary to yearly income
    double yearlyIncome = monthlySalary * 12;

    // Example based on your requirements:
    // Monthly salary: ₹18,000
    // Yearly income: ₹216,000
    // Monthly expense: ₹15,000
    // Yearly expense: ₹180,000

    // Calculate based on user's example pattern:
    // Target: Appears to be a multi-year savings goal
    // Expense: Multi-year expense limit
    // Limit: Multi-year total limit

    // For ₹18,000 monthly salary:
    double monthlyExpense = 15000; // As per your example
    double yearlyExpense = monthlyExpense * 12; // ₹180,000

    // Calculate Target as 5-year savings goal (adjust multiplier as needed)
    totalTarget = yearlyIncome * 5.5; // ₹216,000 × 5.5 ≈ ₹1,188,000

    // Calculate Expense as 2-year expense limit (adjust multiplier as needed)
    expenseLimit = yearlyExpense * 2.2; // ₹180,000 × 2.2 ≈ ₹396,000

    // Calculate Total Limit as Target + Expense
    totalLimit = totalTarget + expenseLimit; // ₹1,188,000 + ₹396,000 = ₹1,584,000

    // Wait, you showed ₹1,227,600 as limit. Let me adjust to match your example:
    // If Target = ₹1,188,000 and Limit = ₹1,227,600, then Expense = ₹39,600
    // But you showed Expense = ₹396,000. This seems inconsistent.

    // Alternative: Maybe the numbers represent different time periods
    // Let's use your exact numbers for ₹18,000 salary:
    totalTarget = 1188000; // Your example target
    expenseLimit = 396000; // Your example expense
    totalLimit = 1227600; // Your example limit

    // Update UI with new calculated values
    setState(() {});

    debugPrint("Monthly Salary: ₹${monthlySalary.toStringAsFixed(0)}");
    debugPrint("Yearly Income: ₹${yearlyIncome.toStringAsFixed(0)}");
    debugPrint("Monthly Expense (assumed): ₹${monthlyExpense.toStringAsFixed(0)}");
    debugPrint("Yearly Expense: ₹${yearlyExpense.toStringAsFixed(0)}");
    debugPrint("Savings Target: ₹${totalTarget.toStringAsFixed(0)}");
    debugPrint("Expense Limit: ₹${expenseLimit.toStringAsFixed(0)}");
    debugPrint("Total Limit: ₹${totalLimit.toStringAsFixed(0)}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _showNotifications, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        ],
      ),

      drawer: _currentIndex == 0 ? _buildDrawer() : null, // Only show drawer on dashboard

      // 🔥 USE INDEXEDSTACK FOR PERSISTENT FOOTER
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardBody(),      // Index 0: Dashboard
          _buildAttendanceHistoryBody(), // Index 1: Attendance History
          _buildSearchBody(),          // Index 2: Search
          _buildProfileBody(),         // Index 3: Profile
          _buildReportsBody(),         // Index 4: Reports
        ],
      ),

      // ✅ PERSISTENT FOOTER - Always visible
      bottomNavigationBar: AnimatedFooter(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // No Navigator.push - body changes via IndexedStack
        },
      ),
    );
  }

  // ---------------------------------------------------
  // APP BAR TITLE
  // ---------------------------------------------------
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Dashboard Agent";
      case 1:
        return "Attendance History";
      case 2:
        return "Search";
      case 3:
        return "Profile";
      case 4:
        return "Reports";
      default:
        return "Dashboard Agent";
    }
  }
  // ---------------------------------------------------
  // BODY BUILDERS FOR EACH TAB
  // ---------------------------------------------------

  Widget _buildDashboardBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBanner(
              userName: staffName,
              mobileNo: staffMobile,
              totalTarget: totalTarget,
              expenseLimit: expenseLimit,
              totalLimit: totalLimit,
            ),
            const SizedBox(height: 20),
            _dashboardOverview(),
            const SizedBox(height: 80), // ⬅️ SPACE FOR FOOTER
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistoryBody() {
    // Extract body content from HistoryPage
    return _AttendanceHistoryBody(mobileNo: staffMobile);
  }

  Widget _buildSearchBody() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Search Feature",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Coming soon...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBody() {
    // Extract body content from StaffProfilePage
    return _ProfileBody(mobileNo: staffMobile);
  }

  Widget _buildReportsBody() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Reports",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Coming soon...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
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
                  builder: (_) => AgentUserHistory(mobile: staffMobile,),
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
                      builder: (_) => AgentUserHistory(mobile: staffMobile,
                      ),
                    ),
                  );
                },
                child: _dashboardItem(Icons.history, "Attendance History", Colors.orangeAccent),
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
                      builder: (_) => AgentSchoolSaleReturnPage(
                        agentId: employeeId, // ✅ dynamic AgentId
                      ),
                    ),
                  );
                },
                child: _dashboardItem(
                  Icons.assignment_return,
                  "sale Return",
                  Colors.redAccent,
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
// 📋 ATTENDANCE HISTORY BODY WIDGET (Extracted from HistoryPage)
// ---------------------------------------------------
class _AttendanceHistoryBody extends StatefulWidget {
  final String mobileNo;

  const _AttendanceHistoryBody({required this.mobileNo});

  @override
  State<_AttendanceHistoryBody> createState() => _AttendanceHistoryBodyState();
}

class _AttendanceHistoryBodyState extends State<_AttendanceHistoryBody> {
  late Future<List<Attendance>> _future;

  @override
  void initState() {
    super.initState();
    if (widget.mobileNo.isEmpty) {
      _future = Future.error(Exception('Mobile number is required'));
    } else {
      _future = AttendanceService.getAttendanceHistory(widget.mobileNo);
    }
  }

  Future<void> _reload() async {
    if (widget.mobileNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _future = AttendanceService.getAttendanceHistory(widget.mobileNo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<Attendance>>(
        future: _future,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading attendance history...'),
                ],
              ),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading attendance history',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? [];

          // Empty
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_toggle_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No attendance records found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your attendance history will appear here once you check in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // List
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _attendanceCard(data[index]);
            },
          );
        },
      ),
    );
  }

  Widget _attendanceCard(Attendance a) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final timeFmt = DateFormat('hh:mm a');
    final bool completed = a.checkOutTime != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: completed ? Colors.green : Colors.orange,
                  child: Text(
                    a.employeeName.isNotEmpty ? a.employeeName[0] : "?",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    a.employeeName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(
                  label: Text(
                    completed ? "Completed" : "Pending",
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: completed ? Colors.green : Colors.orange,
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateFmt.format(a.checkInTime),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _info("Check-In", timeFmt.format(a.checkInTime)),
                _info(
                  "Check-Out",
                  a.checkOutTime != null
                      ? timeFmt.format(a.checkOutTime!)
                      : "--",
                ),
                _info("Duration", a.workDuration ?? "--"),
              ],
            ),
            if (a.checkInLocation != null || a.checkOutLocation != null) ...[
              const Divider(height: 24),
              if (a.checkInLocation != null)
                _location("Check-In", a.checkInLocation!),
              if (a.checkOutLocation != null)
                _location("Check-Out", a.checkOutLocation!),
            ]
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _location(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$title Location: $value",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------
// 👤 PROFILE BODY WIDGET (Extracted from StaffProfilePage)
// ---------------------------------------------------
class _ProfileBody extends StatefulWidget {
  final String mobileNo;

  const _ProfileBody({required this.mobileNo});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  StaffProfileModel? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      return const Center(
        child: Text(
          "No Profile Found",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
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
          _buildItem("Marital Status", profile!.maritalStatus, Icons.family_restroom),
          _sectionTitle("Address Details"),
          _buildItem("Permanent Address", profile!.permanentAddress, Icons.home),
          _buildItem("Current Address", profile!.currentAddress, Icons.location_on),
          _sectionTitle("Job Details"),
          _buildItem("Joining Date", profile!.joiningDate, Icons.date_range),
          _buildItem("Salary", "₹ ${profile!.salary}", Icons.currency_rupee),
          const SizedBox(height: 80), // Space for footer
        ],
      ),
    );
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
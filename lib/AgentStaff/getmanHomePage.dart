import 'package:bookworld/AgentStaff/GuardAttendanceIn.dart';
import 'package:bookworld/AgentStaff/getManPage.dart';
import 'package:bookworld/Hr_Page/HrAttendanceIn.dart';
import 'package:flutter/material.dart';
import '../Service/secure_storage_service.dart';
import '../home_screen.dart';
import '../staffPage/attendanceCheckIn.dart';
import '../staffPage/itAttendanceCheckIn.dart';
import '../staffPage/staffProfile.dart';
import 'GetManHistoryPage.dart';
import 'GuardAttendanceOut.dart';
import 'getmanProfile.dart';

class getmanHomePage extends StatefulWidget {
  const getmanHomePage({Key? key}) : super(key: key);

  @override
  State<getmanHomePage> createState() => _getmanHomePageState();
}

class _getmanHomePageState extends State<getmanHomePage> {
  int _currentIndex = 0;

  String _staffName = '';
  String _staffMobileNo = '';
  String _employeeId = ''; // Add this

  @override
  void initState() {
    super.initState();
    _loadStaffDetails();
  }

  /// 🔹 Load GetMan / SecurityGuard details
  Future<void> _loadStaffDetails() async {
    try {
      final storage = SecureStorageService();
      final mobile = await storage.getStaffMobileNo();
      final credentials = await storage.getStaffCredentials();

      setState(() {
        _staffMobileNo = mobile ?? '';
        _staffName = credentials['agentName'] ?? 'Security Guard';
        // Try to get employeeId from storage, fallback to mobile if not available
        _employeeId = credentials['employeeId'] ?? mobile ?? '';
      });
    } catch (e) {
      debugPrint("Error loading staff details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Dashboard guard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),

      body: _getPage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1A73E8),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.done), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Receipts"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: "Reports",
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DRAWER
  // ---------------------------------------------------------------------------

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(color: Color(0xFF1A73E8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  _staffName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _staffMobileNo,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'ID: $_employeeId',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Attendance Menu Item
          ListTile(
            leading: const Icon(Icons.done, color: Colors.blue),
            title: const Text("Attendance"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItAttendanceCheckIn(
                         // ✅ fixed value
                    // ✅ exists
                  ),
                ),
              );

            },
          ),

          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  GuardAttendanceIn(mobile: _staffMobileNo, guardName:_staffName,),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAGE SWITCHING
  // ---------------------------------------------------------------------------

  Widget _getPage() {
    switch (_currentIndex) {
      case 0:
        return _homeContent();
      case 1:
        return const Center(child: Text("Search"));
      case 2:
        return const Center(child: Text("Receipts"));
      case 3:
        return const Center(child: Text("Reports"));
      default:
        return _homeContent();
    }
  }

  // ---------------------------------------------------------------------------
  // HOME CONTENT (NO DASHBOARD)
  // ---------------------------------------------------------------------------

  Widget _homeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBanner(
            name: _staffName,
            mobileNo: _staffMobileNo,
            employeeId: _employeeId, // Pass employeeId to banner
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 25,
              crossAxisSpacing: 25,
              children: [
                _menuItem("Attendance", Icons.done, Colors.orange, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItAttendanceCheckIn(

                      ),
                    ),
                  );
                }),

                _menuItem("History", Icons.history, Colors.purple, () {
                  // Add history page navigation
                }),

                _menuItem("Get Pass", Icons.badge, Colors.blue, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GetManPage()),
                  );
                }),

                _menuItem("View Pass", Icons.receipt, Colors.teal, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GetManHistoryPage()),
                  );
                }),

                _menuItem("Change Password", Icons.lock, Colors.red, () {}),

                _menuItem("Logout", Icons.logout, Colors.black, _logout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> _logout() async {
    final storage = SecureStorageService();
    await storage.clearAllCredentials();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// ANIMATED BANNER - Updated to show employeeId
// ---------------------------------------------------------------------------

class AnimatedBanner extends StatefulWidget {
  final String name;
  final String mobileNo;
  final String employeeId;

  const AnimatedBanner({
    Key? key,
    required this.name,
    required this.mobileNo,
    required this.employeeId,
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.mobileNo,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (widget.employeeId.isNotEmpty)
                  Text(
                    "ID: ${widget.employeeId}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
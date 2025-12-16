import 'package:flutter/material.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/home_screen.dart';

import '../staffPage/staffhistory.dart';

class Hrmainpage extends StatefulWidget {
  const Hrmainpage ({Key? key}) : super(key: key);

  @override
  State<Hrmainpage > createState() => _HrmainpageState();
}

class _HrmainpageState extends State<Hrmainpage > {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ---------------------- DRAWER ADDED HERE ----------------------
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF19CAB9),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF19CAB9),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Collect Fee"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Receipts"),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: "Reports"),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎨 DRAWER DESIGN (Dashboard • Profile • Settings • Change Password • Logout)
  // ---------------------------------------------------------------------------

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFF19CAB9),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.teal, size: 40),
                ),
                SizedBox(height: 10),
                Text(
                  "Counter User",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "counter01",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Items
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.teal),
            title: const Text("Dashboard"),
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text("Profile"),
            onTap: () {
              // navigate to profile page (if exists)
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings, color: Colors.teal),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.key, color: Colors.orange),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.pop(context);
            },
          ),


          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAGES (same as before)
  // ---------------------------------------------------------------------------

  Widget _getPage() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildCollectFeePage();
      case 2:
        return _buildSearchPage();
      case 3:
        return _buildReceiptsPage();
      case 4:
        return _buildReportsPage();
      default:
        return _buildDashboard();
    }
  }

  // ---------------------------------------------------------------------------
  // 🎨 DASHBOARD UI
  // ---------------------------------------------------------------------------

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBanner(),
          const SizedBox(height: 20), // Reduced from 25

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Dashboard Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Slightly smaller
              ),
              Text(
                "View All",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12), // Reduced from 15

          Container(
            padding: const EdgeInsets.all(16), // Reduced from 20
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12, // Reduced spacing
              crossAxisSpacing: 12, // Reduced spacing
              childAspectRatio: 0.85, // Optimal ratio
              children: [
                _menuItem("Attendance\nRegular", Icons.present_to_all, Colors.green, () {
                  // Navigate to staffhistory screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPage(mobileNo: '',), // Use correct class name
                    ),
                  );
                }),

                _menuItem("Today\nAttendance", Icons.today, Colors.orange, () {
                  setState(() => _currentIndex = 2);
                }),
                _menuItem("Monthly\nRepeat", Icons.calendar_month, Colors.purple, () {
                  setState(() => _currentIndex = 3);
                }),
                _menuItem("Available\nStock", Icons.inventory_2, Colors.blue, () {
                  setState(() => _currentIndex = 4);
                }),
                _menuItem("Sell Now", Icons.shopping_cart_checkout, Colors.blue, () {}),
                _menuItem("Order Now", Icons.add_shopping_cart, Colors.red, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, Color color, VoidCallback onTap) {
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
          ),
        ],
      ),
    );
  }

  // Placeholder pages
  Widget _buildCollectFeePage() => const Center(child: Text("Collect Fee Page"));
  Widget _buildSearchPage() => const Center(child: Text("Search Page"));
  Widget _buildReceiptsPage() => const Center(child: Text("Receipts Page"));
  Widget _buildReportsPage() => const Center(child: Text("Reports Page"));

  // ---------------------------------------------------------------------------
  // 🚪 LOGOUT
  // ---------------------------------------------------------------------------

  void _logout() async {
    try {
      final storage = SecureStorageService();
      await storage.clearAllCredentials();
    } catch (e) {
      print("Error clearing storage: $e");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}

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
              Colors.teal,
              Colors.teal,
              Colors.tealAccent,

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

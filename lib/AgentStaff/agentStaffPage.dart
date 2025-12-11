import 'package:flutter/material.dart';

class agentStaffHomePage extends StatefulWidget {
  const agentStaffHomePage({Key? key}) : super(key: key);

  @override
  State<agentStaffHomePage> createState() => _agentStaffHomePageState();
}

class _agentStaffHomePageState extends State<agentStaffHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Staff Home",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),

      body: _buildDashboard(),
    );
  }

  // ----------------------------------------------------------
  // ⭐ DRAWER
  // ----------------------------------------------------------
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            accountName: const Text("Staff User", style: TextStyle(fontSize: 18)),
            accountEmail: const Text("staff@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue, size: 40),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.blue),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Profile"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blue),
            title: const Text("Settings"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {},
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ⭐ DASHBOARD UI
  // ----------------------------------------------------------
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBanner(),
          const SizedBox(height: 20),

          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _menuItem("Attendance", Icons.check_circle, Colors.green),
              _menuItem("Students", Icons.people, Colors.orange),
              _menuItem("Homework", Icons.book, Colors.purple),
              _menuItem("Reports", Icons.assessment, Colors.blue),
              _menuItem("Messages", Icons.message, Colors.teal),
              _menuItem("Notice Board", Icons.campaign, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ⭐ MENU ITEM COMPONENT
  // ----------------------------------------------------------
  Widget _menuItem(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// ⭐ ANIMATED BANNER WIDGET
// ----------------------------------------------------------
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
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _slide = Tween<Offset>(
      begin: Offset(-0.04, 0),
      end: Offset(0.04, 0),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue, Colors.lightBlueAccent],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: const [
            Icon(Icons.campaign, color: Colors.white, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Welcome Staff! Have a great day 😊",
                style:
                TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

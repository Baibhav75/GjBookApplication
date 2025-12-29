import 'package:flutter/material.dart';
import '../Service/secure_storage_service.dart';
import '../home_screen.dart';

class RecoveryHomePage extends StatefulWidget {
  const RecoveryHomePage({Key? key}) : super(key: key);

  @override
  State<RecoveryHomePage> createState() => _RecoveryHomePageState();
}

class _RecoveryHomePageState extends State<RecoveryHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFFEF6C00),
        title: const Text(
          "Recovery Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: _buildDashboard(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFEF6C00),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Schools"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ===================== DASHBOARD =====================
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryCards(),
          const SizedBox(height: 20),

          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _menuItem("Assigned Schools", Icons.school, Colors.blue),
              _menuItem("Collect Amount", Icons.payments, Colors.green),
              _menuItem("Recovery History", Icons.history, Colors.orange),
              _menuItem("Pending Dues", Icons.warning, Colors.red),
              _menuItem("Reports", Icons.bar_chart, Colors.purple),
              _menuItem("Profile", Icons.person, Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== SUMMARY =====================
  Widget _summaryCards() {
    return Row(
      children: [
        _summaryCard("Today's Collection", "₹ 12,500", Colors.green),
        const SizedBox(width: 12),
        _summaryCard("Pending Amount", "₹ 48,300", Colors.red),
      ],
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== MENU ITEM =====================
  Widget _menuItem(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // TODO: navigation add later
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== DRAWER =====================
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFFEF6C00),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child:
                  Icon(Icons.person, size: 36, color: Colors.deepOrange),
                ),
                SizedBox(height: 10),
                Text(
                  "Recovery Agent",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text("Agent ID: RC-01",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              Navigator.pop(context);
              await SecureStorageService().clearAllCredentials();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

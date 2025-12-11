import 'package:bookworld/staffPage/staff_login_page.dart';
import 'package:flutter/material.dart';
import 'AgentStaff/agentLoginPage.dart';
import 'Hr_Page/hrLogin_screen.dart';
import 'SchoolPage/school login.dart';
import 'adminPage/adminLogin.dart';
import 'counterPage/counterLogin.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          'GJ Book World',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 550, // ⭐ Body container small & centered
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),

            child: Column(
              children: [
                const SizedBox(height: 15),

                // ⭐ IMAGE BELOW APPBAR
                SizedBox(
                  height: 130,
                  child: Image.asset(
                    "assets/bookimg.png",
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),

                // Welcome Text
                Text(
                  'Welcome to GJ Book World ',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Please select your login type',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),

                // ⭐ Small Grid Layout
                SizedBox(
                  height: 420,
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,

                    children: [
                      _loginTile(
                        title: "Admin",
                        icon: Icons.admin_panel_settings,
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                          );
                        },
                      ),
                      _loginTile(
                        title: "AgentStaff",
                        icon: Icons.real_estate_agent,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StaffLoginPage()),
                          );
                        },
                      ),
                      _loginTile(
                        title: "School",
                        icon: Icons.school,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SchoolLoginPage()),
                          );
                        },
                      ),
                      _loginTile(
                        title: "Counter",
                        icon: Icons.point_of_sale,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CounterLoginPage()),
                          );
                        },
                      ),
                      _loginTile(
                        title: "Staff",
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const agentStaffLoginPage()),
                          );
                        },
                      ),
                      _loginTile(
                        title: "HR",
                        icon: Icons.person_outline,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const hrLoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ Small Classic Login Tile Box
  Widget _loginTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 3),
              blurRadius: 6,
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 22, color: color),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }
}

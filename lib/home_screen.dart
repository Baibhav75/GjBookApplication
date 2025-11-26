import 'package:bookworld/staffPage/staff_login_page.dart';
import 'package:flutter/material.dart';

import 'SchoolPage/school login.dart';
import 'adminPage/adminLogin.dart';
import 'counterPage/counterLogin.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _handleLogin(String userType) {
    print('$userType login clicked');
    // Add your navigation logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GJ Book World ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome text
              Text(
                'Welcome to School Book',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Please select your login type',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 50),

              // Login buttons
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                  children: [
                    _buildLoginButton(
                      title: 'Admin Login',
                      icon: Icons.admin_panel_settings,
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                        );
                      },
                    ),
                    _buildLoginButton(
                      title: 'Staff Login',
                      icon: Icons.people,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StaffLoginPage()),
                        );
                      },
                    ),
                    _buildLoginButton(
                      title: 'School Login',
                      icon: Icons.school,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SchoolLoginPage()),
                        );
                      },
                    ),
                    _buildLoginButton(
                      title: 'Counter Login',
                      icon: Icons.point_of_sale,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CounterLoginPage()),
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
    );
  }

  Widget _buildLoginButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
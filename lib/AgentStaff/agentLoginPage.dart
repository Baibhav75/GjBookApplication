import 'package:flutter/material.dart';
import 'agentStaffPage.dart';
import 'getManPage.dart';
import '../Service/secure_storage_service.dart';

class AgentStaffLoginPage extends StatefulWidget {
  const AgentStaffLoginPage({Key? key}) : super(key: key);

  @override
  State<AgentStaffLoginPage> createState() => _AgentStaffLoginPageState();
}

class _AgentStaffLoginPageState extends State<AgentStaffLoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  // ✅ POSITION DROPDOWN
  String? _selectedPosition;
  final List<String> _positions = [
    "GetMan",
    "Staff Login",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Staff Login",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LOGO
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/MOLL Services Logo.png',
                  width: 125,
                  height: 125,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Staff Login",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 40),

              /// MOBILE NUMBER
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Mobile Number",
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ✅ CHOOSE POSITION
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                hint: const Text("Choose Position"),
                items: _positions.map((position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPosition = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_mobileController.text.isEmpty ||
                        _passwordController.text.isEmpty ||
                        _selectedPosition == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                        ),
                      );
                      return;
                    }

                    // Save mobile number for later use
                    _saveMobileNumber(_mobileController.text);

                    // ✅ ROLE BASED LOGIN
                    if (_selectedPosition == "GetMan") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GetManPage(),
                        ),
                      );
                    } else if (_selectedPosition == "Staff Login") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const agentStaffHomePage(),
                        ),
                      );
                    }
                  },

                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to save mobile number
  void _saveMobileNumber(String mobileNo) async {
    try {
      final storage = SecureStorageService();
      // We'll save the mobile number with a temporary key for now
      // In a real implementation, this would be saved properly during actual login
      await storage.saveStaffCredentials(
        username: mobileNo, // Using mobile as username for now
        password: _passwordController.text,
        mobileNo: mobileNo, // Save the mobile number
      );
    } catch (e) {
      print("Error saving mobile number: $e");
    }
  }
}


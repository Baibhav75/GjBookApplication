import 'package:flutter/material.dart';
import '../Service/agent_login_service.dart';
import '../Service/secure_storage_service.dart';
import '../Model/agent_login_model.dart';
import 'staff_page.dart';

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({Key? key}) : super(key: key);

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String dropdownEmployeeType = "Agent";

  bool _isLoading = false;
  bool _obscure = true;

  final AgentLoginService _loginService = AgentLoginService();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _loginService.login(
      mobile: _mobileController.text.trim(),
      password: _passwordController.text.trim(),
      employeeType: dropdownEmployeeType,
    );

    if (result == null) {
      _showMessage("Something went wrong. Try again");
    } else if (result.status == "Success") {
      _showMessage("Login Successful!");

      // Save credentials to secure storage for auto-login
      try {
        final storageService = SecureStorageService();
        await storageService.saveStaffCredentials(
          username: _mobileController.text.trim(),
          password: _passwordController.text.trim(),
          employeeType: dropdownEmployeeType,
          agentName: result.agentName, // Save agent name
        );
      } catch (e) {
        // Log error but continue with navigation
        print('Error saving staff credentials: $e');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StaffPage(
            agentName: result.agentName,
            employeeType: result.employeeType,
            email: result.agentAdminEmail,
            password: result.agentPassword,
            mobile: _mobileController.text.trim(),
          ),
        ),
      );

    } else {
      _showMessage(result.message);
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Staff Login"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Icon(Icons.people, size: 90, color: Colors.green[800]),
              const SizedBox(height: 10),
              Text(
                "Staff Portal",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 30),

              // Mobile Number
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Mobile Number", Icons.phone_android),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter mobile number";
                  if (v.length < 10) return "Invalid number";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter password";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Employee Type Dropdown
              DropdownButtonFormField<String>(
                value: dropdownEmployeeType,
                items: ["Agent", "Staff", "Admin"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    dropdownEmployeeType = v!;
                  });
                },
                decoration: _inputDecoration("Employee Type", Icons.person),
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

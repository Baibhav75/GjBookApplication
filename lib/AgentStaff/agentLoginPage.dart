import 'package:flutter/material.dart';

import '../Model/agent_getman_login_model.dart';
import '../Model/security_guard_login_model.dart';

import '../Service/agent_getman_login_service.dart';
import '../Service/security_guard_login_service.dart';
import '../Service/secure_storage_service.dart';

import 'agentStaffPage.dart';
import 'getmanHomePage.dart';
import 'testPage.dart'; // ✅ ADD THIS

class AgentStaffLoginPage extends StatefulWidget {
  const AgentStaffLoginPage({Key? key}) : super(key: key);

  @override
  State<AgentStaffLoginPage> createState() => _AgentStaffLoginPageState();
}

class _AgentStaffLoginPageState extends State<AgentStaffLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // 🔐 LOGIN HANDLER
  // ---------------------------------------------------------------------------

  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _showMessage("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storage = SecureStorageService();
      final mobile = _mobileController.text.trim();
      final password = _passwordController.text.trim();

      if (mobile.isEmpty || password.isEmpty) {
        _showMessage("Mobile number and password are required");
        return;
      }

      debugPrint("Staff Login Request: Mobile=$mobile");

      // ✅ STAFF LOGIN ONLY (NO POSITION)
      final AgentGetManLoginModel response =
      await AgentGetManLoginService.login(
        mobile: mobile,
        password: password,
      );

      if (!response.isSuccess) {
        _showMessage(response.message);
        return;
      }

      // ✅ Save staff credentials (fixed role)
      await storage.saveAgentGetManCredentials(
        mobileNo: mobile,
        role: "STAFF",
        name: response.agentName,
        email: response.agentAdminEmail,
        employeeId: response.employeeId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const agentStaffHomePage(),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("Staff Login Error: $e");
      debugPrint("Stack Trace: $stackTrace");

      if (mounted) {
        _showMessage("Login failed. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  // ---------------------------------------------------------------------------
  // 🧠 HELPER
  // ---------------------------------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 🎨 UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Staff Login",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/MOLL Services Logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 30),

              // ---------------- POSITION ----------------


              // ---------------- MOBILE ----------------
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                v == null || v.length != 10
                    ? "Invalid mobile number"
                    : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  hintText: "Mobile Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- PASSWORD ----------------
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (v) =>
                v == null || v.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ---------------- LOGIN BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style:
                    TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

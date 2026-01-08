import 'package:bookworld/staffPage/staff_page.dart';
import 'package:flutter/material.dart';

import '../AgentStaff/getmanHomePage.dart';
import '../Service/agent_login_service.dart';
import '../Service/secure_storage_service.dart';
import '../Service/staff_profile_service.dart';
import '../Model/agent_login_model.dart';

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({Key? key}) : super(key: key);

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// POSITION DROPDOWN
  String dropdownPosition = "AGENT";
  final List<String> _positions = ["AGENT",];

  bool _isLoading = false;
  bool _obscure = true;

  final AgentLoginService _loginService = AgentLoginService();
  final SecureStorageService _storageService = SecureStorageService();

  // ================= LOGIN FUNCTION =================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String mobile = _mobileController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      final AgentLoginModel? result = await _loginService.login(
        mobile: mobile,
        password: password,
        position: dropdownPosition,
      );

      if (result == null) {
        _showMessage("Something went wrong. Please try again.");
        return;
      }

      if (result.status.toLowerCase() != "success") {
        _showMessage(result.message);
        return;
      }

      /// FETCH EMPLOYEE ID FROM PROFILE
      String? employeeId;
      String email = result.agentAdminEmail.isNotEmpty 
          ? result.agentAdminEmail 
          : "";
      
      try {
        final profileService = StaffProfileService();
        final profile = await profileService.fetchProfile(mobile);
        if (profile != null && profile.employeeId.isNotEmpty) {
          employeeId = profile.employeeId;
          // Use email from profile if available
          if (profile.email.isNotEmpty) {
            email = profile.email;
          }
        }
      } catch (e) {
        debugPrint("Failed to fetch employee ID: $e");
      }

      /// SAVE LOGIN DATA WITH EMPLOYEE ID AND EMAIL
      await _storageService.saveStaffCredentials(
        username: mobile,
        password: password,
        employeeType: dropdownPosition,
        agentName: result.agentName,
        mobileNo: mobile,
        employeeId: employeeId,
        email: email,
      );

      if (!mounted) return;

      /// ================= ROLE BASED NAVIGATION =================
      if (dropdownPosition == "AGENT") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StaffPage(
              agentName: result.agentName,
              employeeType: dropdownPosition,
              email: email,
              password: password,
              mobile: mobile,
            ),
          ),
        );

      } else if (dropdownPosition == "SecurityGuard") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const getmanHomePage(),
          ),
        );
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      _showMessage("Login failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= SNACKBAR =================
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("AgentStaff Login"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/MOLL Services Logo.png',
                width: 100,
                height: 100,
              ),

              const SizedBox(height: 20),

              Text(
                "AgentStaff Portal",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),

              const SizedBox(height: 30),

              /// POSITION
              DropdownButtonFormField<String>(
                value: dropdownPosition,
                items: _positions
                    .map(
                      (pos) => DropdownMenuItem(
                    value: pos,
                    child: Text(pos),
                  ),
                )
                    .toList(),
                onChanged: (value) =>
                    setState(() => dropdownPosition = value!),
                validator: (v) =>
                v == null ? "Please select position" : null,
                decoration: _inputDecoration(
                  "Select Position",
                  Icons.work_outline,
                ),
              ),

              const SizedBox(height: 20),

              /// MOBILE
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration:
                _inputDecoration("Mobile Number", Icons.phone),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter mobile number";
                  }
                  if (v.length != 10) {
                    return "Enter valid 10 digit number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter password" : null,
              ),

              const SizedBox(height: 30),

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  )
                      : const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

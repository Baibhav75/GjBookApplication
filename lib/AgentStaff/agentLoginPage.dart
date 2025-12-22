import 'package:flutter/material.dart';

import '../Model/agent_getman_login_model.dart';
import '../Model/security_guard_login_model.dart';

import '../Service/agent_getman_login_service.dart';
import '../Service/security_guard_login_service.dart';
import '../Service/secure_storage_service.dart';

import 'agentStaffPage.dart';
import 'getmanHomePage.dart';

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

  String? _selectedPosition;

  /// Available roles
  final List<String> _positions = ["Agent", "SecurityGuard"];

  // ---------------------------------------------------------------------------
  // 🔐 LOGIN HANDLER
  // ---------------------------------------------------------------------------

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || _selectedPosition == null) {
      _showMessage("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storage = SecureStorageService();
      final mobile = _mobileController.text.trim();
      final password = _passwordController.text.trim();

      // ================= SECURITY GUARD LOGIN =================
      if (_selectedPosition == "SecurityGuard") {
        final SecurityGuardLoginModel result =
        await SecurityGuardLoginService.login(
          mobile: mobile,
          password: password,
        );

        if (!result.isSuccess) {
          _showMessage(result.message);
          return;
        }

        await storage.saveAgentGetManCredentials(
          mobileNo: mobile,
          role: "SECURITY_GUARD",
          name: result.name,
          email: result.email,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const getmanHomePage()),
        );
      }

      // ================= AGENT LOGIN =================
      else {
        final AgentGetManLoginModel response =
        await AgentGetManLoginService.login(
          mobile: mobile,
          password: password,
          position: "Agent",
        );

        if (!response.isSuccess) {
          _showMessage(response.message);
          return;
        }

        await storage.saveAgentGetManCredentials(
          mobileNo: mobile,
          role: "AGENT",
          name: response.agentName,
          email: response.agentAdminEmail,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const agentStaffHomePage()),
        );
      }
    } catch (e) {
      _showMessage("Login failed. Please try again");
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
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                hint: const Text("Choose Position"),
                items: _positions
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _selectedPosition = v),
                validator: (v) =>
                v == null ? "Please select position" : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

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
                    onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
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
                    style: TextStyle(
                        color: Colors.white, fontSize: 16),
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

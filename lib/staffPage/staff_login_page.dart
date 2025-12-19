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

  String dropdownEmployeeType = "AgentStaff";

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
        employeeType: dropdownEmployeeType,
      );

      if (result == null) {
        _showMessage("Something went wrong. Please try again.");
      } else if (result.status == "Success") {
        _showMessage("Login Successful");

        // ✅ SAVE LOGIN DATA (IMPORTANT)
        await _storageService.saveStaffCredentials(
          username: mobile,
          password: password,
          employeeType: dropdownEmployeeType,
          agentName: result.agentName,
          mobileNo: mobile, // ✅ MUST
        );



        // ✅ NAVIGATE
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StaffPage(
              agentName: result.agentName,
              employeeType: result.employeeType,
              email: result.agentAdminEmail,
              password: result.agentPassword,
              mobile: mobile,
            ),
          ),
        );
      } else {
        _showMessage(result.message);
      }
    } catch (e) {
      _showMessage("Login failed. Please try again.");
      debugPrint("Login Error: $e");
    }

    setState(() => _isLoading = false);
  }

  // ================= SNACKBAR =================
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // LOGO
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/MOLL Services Logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "AgentStaff Portal",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),

              const SizedBox(height: 30),

              // MOBILE
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  "Mobile Number",
                  Icons.phone_android,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter mobile number";
                  if (v.length != 10) return "Enter valid 10 digit number";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // PASSWORD
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
                    onPressed: () {
                      setState(() => _obscure = !_obscure);
                    },
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

              const SizedBox(height: 30),

              // LOGIN BUTTON
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
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
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

  // ================= INPUT DECORATION =================
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

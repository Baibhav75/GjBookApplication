import 'package:flutter/material.dart';
import '../Model/agent_getman_login_model.dart';
import '../Service/agent_getman_login_service.dart';
import '../Service/secure_storage_service.dart';
import 'agentStaffPage.dart';
import 'getmanHomePage.dart';
import '../Model/security_guard_login_model.dart';
import '../Service/security_guard_login_service.dart';

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

  /// API expects Position = Agent / GetMan
  final List<String> _positions = ["Agent", "SecurityGuard"];

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || _selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storage = SecureStorageService();

      // 🔹 SECURITY GUARD LOGIN
      if (_selectedPosition == "SecurityGuard") {
        final SecurityGuardLoginModel result =
        await SecurityGuardLoginService.login(
          mobile: _mobileController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (result.isSuccess) {
          await storage.saveAgentGetManCredentials(
            mobileNo: _mobileController.text.trim(),
            role: "SECURITYGUARD",
            name: result.name,
            email: result.email,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const getmanHomePage()),
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result.message)));
        }
      }

      // 🔹 AGENT LOGIN
      else {
        final response = await AgentGetManLoginService.login(
          mobile: _mobileController.text.trim(),
          password: _passwordController.text.trim(),
          position: "Agent",
        );

        if (response.isSuccess) {
          await storage.saveAgentGetManCredentials(
            mobileNo: _mobileController.text.trim(),
            role: "AGENT",
            name: response.agentName,
            email: response.agentAdminEmail,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const agentStaffHomePage()),
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(response.message)));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Please try again")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



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

              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                v == null || v.length != 10 ? "Invalid mobile number" : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  hintText: "Mobile Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (v) =>
                v == null || v.length < 4 ? "Invalid password" : null,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 30),

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
                    style: TextStyle(color: Colors.white, fontSize: 16),
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

import 'package:flutter/material.dart';
import '../Service/counter_login_service.dart';
import '../Service/secure_storage_service.dart';
import '../Model/counter_login_model.dart';
import 'counter_main_page.dart';

class CounterLoginPage extends StatefulWidget {
  const CounterLoginPage({Key? key}) : super(key: key);

  @override
  State<CounterLoginPage> createState() => _CounterLoginPageState();
}

class _CounterLoginPageState extends State<CounterLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mobileCtrl =
  TextEditingController(text: "9897382328");
  final TextEditingController _passwordCtrl =
  TextEditingController(text: "123456");

  bool _isLoading = false;
  bool _obscureText = true;

  final SecureStorageService _storageService = SecureStorageService();

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      CounterLoginModel response = await CounterLoginService.login(
        mobileNo: _mobileCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (!mounted) return;

      if (response.isSuccess) {
        // Save counter details securely
        await _storageService.saveCounterCredentials(
          counterId: response.counterBoyNo,
          password: response.counterBoyPassword,
          counterName: response.counterBoyName,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CounterMainPage()),
        );
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError("Login failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6A1B9A);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Counter Login"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Image.asset(
              'assets/MOLL Services Logo.png',
              width: 120,
              height: 120,
            ),

            const SizedBox(height: 15),

            Text(
              "Counter Portal",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 35),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _mobileCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration("Mobile Number", Icons.phone),
                    validator: (v) =>
                    v!.isEmpty ? "Mobile number required" : null,
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscureText,
                    decoration: _inputDecoration(
                      "Password",
                      Icons.lock,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                    validator: (v) =>
                    v!.isEmpty ? "Password required" : null,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                          : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label,
      IconData icon, {
        Widget? suffix,
      }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

import 'package:bookworld/SchoolPage/school_page_screen.dart';
import 'package:flutter/material.dart';

import '../Model/school_login_model.dart';
import '../Service/school_login_service.dart';
import '../Service/secure_storage_service.dart';

class SchoolLoginPage extends StatefulWidget {
  const SchoolLoginPage({Key? key}) : super(key: key);

  @override
  State<SchoolLoginPage> createState() => _SchoolLoginPageState();
}

class _SchoolLoginPageState extends State<SchoolLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _schoolIdCtrl =
  TextEditingController(text: "8383838934");
  final TextEditingController _passwordCtrl =
  TextEditingController(text: "12345");

  bool _isLoading = false;
  bool _obscureText = true;

  final SecureStorageService _storageService = SecureStorageService();

  @override
  void dispose() {
    _schoolIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ================= LOGIN =================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final SchoolLoginModel result =
      await SchoolLoginService.login(
        mobile: _schoolIdCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (!result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Save required info only
      await _storageService.saveSchoolCredentials(
        schoolId: result.ownerNumber,
        username: result.ownerName,
        password: _passwordCtrl.text.trim(), // API limitation
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SchoolPageScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFEF6C00);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("School Login"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 25),

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

            Text(
              "School Portal",
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
                    controller: _schoolIdCtrl,
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: const Icon(Icons.school),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                    v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                    v!.isEmpty ? "Required" : null,
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
                        color: Colors.white,
                        strokeWidth: 2,
                      )
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
}

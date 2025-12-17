import 'package:flutter/material.dart';
import 'counter_main_page.dart';
import 'package:bookworld/Service/secure_storage_service.dart';

class CounterLoginPage extends StatefulWidget {
  const CounterLoginPage({Key? key}) : super(key: key);

  @override
  State<CounterLoginPage> createState() => _CounterLoginPageState();
}

class _CounterLoginPageState extends State<CounterLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _counterIdCtrl =
  TextEditingController(text: "counter01");
  final TextEditingController _passwordCtrl =
  TextEditingController(text: "12345");

  bool _isLoading = false;
  bool _obscureText = true;

  final SecureStorageService _storageService = SecureStorageService();

  @override
  void dispose() {
    _counterIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    const demoUser = "counter01";
    const demoPass = "12345";

    await _storageService.saveCounterCredentials(
      counterId: demoUser,
      password: demoPass,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CounterMainPage()),
    );

    setState(() => _isLoading = false);
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
                  // READ-ONLY AUTO-FILLED COUNTER ID
                  TextFormField(
                    controller: _counterIdCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Counter ID",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // READ-ONLY AUTO-FILLED PASSWORD
                  TextFormField(
                    controller: _passwordCtrl,
                    readOnly: true,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
}

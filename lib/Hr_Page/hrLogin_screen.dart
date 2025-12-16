import 'package:bookworld/Hr_Page/HrMainPage.dart';
import 'package:flutter/material.dart';
import 'package:bookworld/Model/hr_login_model.dart';
import 'package:bookworld/Service/hr_login_service.dart';

class hrLoginScreen extends StatefulWidget {
  const hrLoginScreen({super.key});

  @override
  State<hrLoginScreen> createState() => _hrLoginScreenState();
}

class _hrLoginScreenState extends State<hrLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> fade1;
  late Animation<double> fade2;
  late Animation<double> fade3;
  late Animation<double> fade4;

  late Animation<Offset> slide1;
  late Animation<Offset> slide2;
  late Animation<Offset> slide3;
  late Animation<Offset> slide4;

  late Animation<double> iconScale;

  bool _obscure = true;
  bool _isLoading = false;

  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  final HrLoginService _loginService = HrLoginService();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fade1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );
    fade2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5)),
    );
    fade3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6)),
    );
    fade4 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8)),
    );

    slide1 = Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    slide2 = Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut)));

    slide3 = Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut)));

    slide4 = Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _mobile.dispose();
    _pass.dispose();
    super.dispose();
  }

  /// 🔐 LOGIN FUNCTION
  Future<void> _login() async {
    if (_mobile.text.isEmpty || _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile & password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      HrLoginModel result = await _loginService.hrLogin(
        mobile: _mobile.text.trim(),
        password: _pass.text.trim(),
      );

      if (result.status.toLowerCase() == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Hrmainpage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF19CAB9);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          'HR Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                ScaleTransition(
                  scale: iconScale,
                  child:
                  Icon(Icons.work_outline, size: 90, color: primaryGreen),
                ),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: fade1,
                  child: SlideTransition(
                    position: slide1,
                    child: const Text(
                      "HR Login",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                FadeTransition(
                  opacity: fade2,
                  child: SlideTransition(
                    position: slide2,
                    child: _roundedField(
                      controller: _mobile,
                      hint: "Mobile Number",
                      icon: Icons.phone_android,
                      keyboard: TextInputType.phone,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: fade3,
                  child: SlideTransition(
                    position: slide3,
                    child: _roundedField(
                      controller: _pass,
                      hint: "Password",
                      icon: Icons.lock,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                FadeTransition(
                  opacity: fade4,
                  child: SlideTransition(
                    position: slide4,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

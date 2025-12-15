import 'package:bookworld/Hr_Page/HrMainPage.dart';
import 'package:flutter/material.dart';

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

  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Fade Animations
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

    // Slide Animations
    slide1 = Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    slide2 = Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.1, 0.7, curve: Curves.easeOut)));

    slide3 = Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)));

    slide4 = Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    // Icon bounce animation
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

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF19CAB9);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          'HR Login',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600, // Optional: makes text bold
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // This sets all AppBar icons to white
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// *** Icon Animation ***
                ScaleTransition(
                  scale: iconScale,
                  child: Icon(Icons.work_outline, size: 90, color: primaryGreen),
                ),
                const SizedBox(height: 16),

                /// *** Title Animation ***
                FadeTransition(
                  opacity: fade1,
                  child: SlideTransition(
                    position: slide1,
                    child: const Text(
                      "HR Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.teal, // Changed to white
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                /// *** Mobile Field Animation ***
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

                /// *** Password Field Animation ***
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
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// *** Login Button Animation ***
                FadeTransition(
                  opacity: fade4,
                  child: SlideTransition(
                    position: slide4,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Hrmainpage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // <-- TEXT COLOR UPDATED
                          ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

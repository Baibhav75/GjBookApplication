import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:bookworld/Service/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _textOpacityAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Create scale animation (big to small)
    _scaleAnimation = Tween<double>(
      begin: 2.5, // Start very big
      end: 1.0,   // End at normal size
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Create opacity animation for image (fade in)
    _opacityAnimation = Tween<double>(
      begin: 0.0, // Start invisible
      end: 1.0,   // End fully visible
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ));

    // Create opacity animation for text (delayed fade in)
    _textOpacityAnimation = Tween<double>(
      begin: 0.0, // Start invisible
      end: 1.0,   // End fully visible
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn), // Start after image animation
    ));

    // Start animation
    _controller.forward();

    _navigateToAppropriateScreen();
  }

  _navigateToAppropriateScreen() async {
    // Wait for animation and minimum splash time
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Check for stored credentials and auto-login
    final initialScreen = await _authService.getInitialScreen();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => initialScreen),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Image with scale and opacity
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3 * _opacityAnimation.value),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/images/bookimg.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if image not found
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Image.asset(
                                'assets/bookimg.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),

                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App title with delayed fade animation
                Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Text(
                    'GJ Book World',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Subtitle with delayed fade animation
                Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Text(
                    'Education Management System',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Loading indicator with delayed appearance
                Opacity(
                  opacity: _controller.value > 0.7 ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
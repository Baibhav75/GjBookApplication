import 'package:flutter/material.dart';
import 'school_page_screen.dart'; // Import the school page
import 'package:bookworld/Service/secure_storage_service.dart';

class SchoolLoginPage extends StatefulWidget {
  const SchoolLoginPage({Key? key}) : super(key: key);

  @override
  State<SchoolLoginPage> createState() => _SchoolLoginPageState();
}

class _SchoolLoginPageState extends State<SchoolLoginPage> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SecureStorageService _storageService = SecureStorageService();

  // Default credentials
  final String _defaultSchoolId = 'SCH001';
  final String _defaultUsername = 'school';
  final String _defaultPassword = 'school123';

  // Loading state
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      final schoolId = _schoolIdController.text.trim();
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Save credentials securely
      try {
        await _storageService.saveSchoolCredentials(
          schoolId: schoolId.isNotEmpty ? schoolId : _defaultSchoolId,
          username: username.isNotEmpty ? username : _defaultUsername,
          password: password.isNotEmpty ? password : _defaultPassword,
        );
      } catch (e) {
        print('Error saving credentials: $e');
      }

      // Navigate directly to school page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SchoolPageScreen()),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _autoFillCredentials() {
    setState(() {
      _schoolIdController.text = _defaultSchoolId;
      _usernameController.text = _defaultUsername;
      _passwordController.text = _defaultPassword;
    });
  }

  void _quickLogin() async {
    // Save counter-like credentials (no user input required)
    try {
      await _storageService.saveSchoolCredentials(
        schoolId: _defaultSchoolId,
        username: _defaultUsername,
        password: _defaultPassword,
      );
    } catch (e) {
      print('Error saving credentials: $e');
    }
    
    // Direct login without any credentials
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SchoolPageScreen()),
      );
    }
  }

  @override
  void dispose() {
    _schoolIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('School Login'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Header
                Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.orange[800],
                ),
                const SizedBox(height: 20),
                Text(
                  'School Portal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your credentials to access school dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // School ID Field
                TextFormField(
                  controller: _schoolIdController,
                  decoration: InputDecoration(
                    labelText: 'School ID',
                    hintText: 'Enter your school ID',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Login to School Portal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Quick Login Button (No credentials needed)
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: _quickLogin,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.green[400]!),
                    ),
                    child: Text(
                      'Quick Login (No Credentials)',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Auto-fill Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: _autoFillCredentials,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.orange[300]!),
                    ),
                    child: Text(
                      'Auto-fill Demo Credentials',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange[100]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Demo Credentials (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'School ID: $_defaultSchoolId\nUsername: $_defaultUsername\nPassword: $_defaultPassword',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can use Quick Login button to skip credential entry',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
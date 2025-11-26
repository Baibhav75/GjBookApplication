import 'package:flutter/material.dart';
import 'counter_main_page.dart';
import 'package:bookworld/Service/secure_storage_service.dart';

class CounterLoginPage extends StatefulWidget {
  const CounterLoginPage({Key? key}) : super(key: key);

  @override
  State<CounterLoginPage> createState() => _CounterLoginPageState();
}

class _CounterLoginPageState extends State<CounterLoginPage> {
  bool _isLoading = false;
  final SecureStorageService _storageService = SecureStorageService();

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    // Save counter credentials (no user input required)
    try {
      await _storageService.saveCounterCredentials();
    } catch (e) {
      print('Error saving credentials: $e');
    }

    // Direct navigation to counter main page
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CounterMainPage()),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Counter Login'),
        backgroundColor: Colors.purple[800],
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
          child: Column(
            children: [
              const SizedBox(height: 50),

              // Header
              Icon(
                Icons.point_of_sale,
                size: 80,
                color: Colors.purple[800],
              ),
              const SizedBox(height: 20),
              Text(
                'Counter Portal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Fee collection and counter management system',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Direct Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
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
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Enter Counter Portal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Features Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.purple[800],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Counter Portal Features',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildFeatureItem('Fee Collection'),
                    _buildFeatureItem('Receipt Generation'),
                    _buildFeatureItem('Student Search'),
                    _buildFeatureItem('Payment History'),
                    _buildFeatureItem('Daily Reports'),
                    _buildFeatureItem('Cash Management'),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Counter Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No credentials required. Direct access to counter operations and fee management system.',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.purple[600],
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            feature,
            style: TextStyle(
              color: Colors.purple[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
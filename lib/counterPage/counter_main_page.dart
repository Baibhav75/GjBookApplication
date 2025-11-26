import 'package:flutter/material.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/home_screen.dart';

import 'counterLogin.dart';

class CounterMainPage extends StatefulWidget {
  const CounterMainPage({Key? key}) : super(key: key);

  @override
  State<CounterMainPage> createState() => _CounterMainPageState();
}

class _CounterMainPageState extends State<CounterMainPage> {
  int _currentIndex = 0;
  double _todayCollection = 12500.00;
  int _transactionsToday = 45;
  int _pendingReceipts = 3;

  // Sample student data for fee collection
  final List<Map<String, dynamic>> _recentTransactions = [
    {'student': 'Alice Johnson', 'grade': '10A', 'amount': 2500.00, 'time': '09:15 AM', 'status': 'Paid'},
    {'student': 'Bob Smith', 'grade': '9B', 'amount': 2300.00, 'time': '10:30 AM', 'status': 'Paid'},
    {'student': 'Carol Davis', 'grade': '11C', 'amount': 2700.00, 'time': '11:45 AM', 'status': 'Pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Counter Portal'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotifications();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.purple[800],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Collect Fee',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Receipts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildCollectFeePage();
      case 2:
        return _buildSearchPage();
      case 3:
        return _buildReceiptsPage();
      case 4:
        return _buildReportsPage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.purple[100],
                    child: Icon(
                      Icons.point_of_sale,
                      size: 30,
                      color: Colors.purple[800],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Counter Dashboard',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Fee Collection Center',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Counter #1 - Active',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Today's Summary
          const Text(
            "Today's Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Collection',
                  '₹${_todayCollection.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  'Transactions',
                  '$_transactionsToday',
                  Icons.swap_horiz,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Pending Receipts',
                  '$_pendingReceipts',
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  'Students Served',
                  '42',
                  Icons.people,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildActionCard('Collect Fee', Icons.payment, Colors.green),
              _buildActionCard('Print Receipt', Icons.print, Colors.blue),
              _buildActionCard('Search Student', Icons.search, Colors.orange),
              _buildActionCard('View Reports', Icons.assessment, Colors.purple),
            ],
          ),
          const SizedBox(height: 30),

          // Recent Transactions
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._recentTransactions.map((transaction) =>
                      _buildTransactionItem(transaction)
                  ).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          print('$title tapped');
          // Navigate to respective page based on action
          if (title == 'Collect Fee') {
            setState(() {
              _currentIndex = 1;
            });
          } else if (title == 'Search Student') {
            setState(() {
              _currentIndex = 2;
            });
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: transaction['status'] == 'Paid' ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['student'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Grade ${transaction['grade']} • ${transaction['time']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${transaction['amount']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                transaction['status'],
                style: TextStyle(
                  fontSize: 12,
                  color: transaction['status'] == 'Paid' ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectFeePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collect Fee',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enter student details to collect fee',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),

          // Student Search Form
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Student ID/Roll Number',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _searchStudent();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[800],
                      ),
                      child: const Text(
                        'Search Student',
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
          const SizedBox(height: 30),

          // Fee Details (would appear after student search)
          const Text(
            'Fee Structure',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildFeeItem('Tuition Fee', 1500.00),
          _buildFeeItem('Transport Fee', 800.00),
          _buildFeeItem('Library Fee', 200.00),
          _buildFeeItem('Sports Fee', 300.00),
          _buildFeeItem('Other Charges', 200.00),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹3000.00',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _collectFee();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
              ),
              child: const Text(
                'Collect Fee & Print Receipt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String feeType, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(feeType),
          Text('₹$amount'),
        ],
      ),
    );
  }

  Widget _buildSearchPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Student Search',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Search for student records and fee details',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Receipt Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'View and manage fee receipts',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Daily Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Generate and view counter reports',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _searchStudent() {
    // Implement student search functionality
    print('Searching student...');
  }

  void _collectFee() {
    // Implement fee collection functionality
    print('Collecting fee...');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fee collected successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Counter Notifications'),
          content: const Text('No new notifications at the counter'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    // Clear secure storage
    try {
      final storageService = SecureStorageService();
      await storageService.clearAllCredentials();
    } catch (e) {
      print('Error clearing credentials: $e');
    }
    
    // Navigate to HomeScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}
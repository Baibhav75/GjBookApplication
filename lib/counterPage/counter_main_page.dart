import 'package:flutter/material.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/home_screen.dart';

import '../AgentStaff/getmanProfile.dart';
import 'counterChangePassword.dart';
import 'counterProfile.dart';
import 'counter_details_page.dart';
import 'counter_order_pending_page.dart';
import 'counter_today_sell_page.dart';
import 'counter_online_payment_page.dart';
import 'counter_cash_payment_page.dart';
import 'counter_transaction_history_page.dart';
import 'counter_completed_order_page.dart';
import 'counter_total_sell_page.dart';
import 'counter_wallet_history_page.dart';

class CounterMainPage extends StatefulWidget {
  const CounterMainPage({Key? key}) : super(key: key);

  @override
  State<CounterMainPage> createState() => _CounterMainPageState();
}

class _CounterMainPageState extends State<CounterMainPage> {
  int _currentIndex = 0;

  String _counterName = '';
  String _counterId = '';
  String _counterMobile= '';

  @override
  void initState() {
    super.initState();
    _loadCounterDetails();
  }

  Future<void> _loadCounterDetails() async {
    final storage = SecureStorageService();

    final name = await storage.getCounterName();
    final id = await storage.getCounterId();

    if (!mounted) return;

    setState(() {
      _counterName = name ?? 'Counter User';
      _counterId = id ?? '';
      _counterMobile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          _counterName.isNotEmpty
              ? "Welcome, $_counterName"
              : "Dashboard",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadCounterDetails();
            },
          ),
        ],
      ),

      body: _getPage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1A73E8),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Collect Fee"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Receipts"),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: "Reports"),
        ],
      ),
    );
  }


  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFF1A73E8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  _counterName.isNotEmpty
                      ? _counterName
                      : "Counter User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_counterId.isNotEmpty)
                  Text(
                    "ID: $_counterId",
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.blue),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),

          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CounterProfile(mobileNo: _counterId,),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.key, color: Colors.orange),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CounterChangePasswordPage(mobileNo: _counterId),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("v1.0.2", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }


  Widget _getPage() {
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
          AnimatedBanner(userName: _counterName ,),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Dashboard Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "View All",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.85,
              children: [
                _menuItem(
                  "Counter Details",
                  Icons.storefront, // better shop icon
                  Colors.green,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CounterDetailsPage(counterData: {
                          'name': _counterName,
                          'id': _counterId,
                        }),
                      ),
                    );
                  },
                ),

                _menuItem(
                  "Pending Order",
                  Icons.pending_actions, // correct
                  Colors.orange,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CounterOrderPendingPage()),
                    );
                  },
                ),

                _menuItem(
                  "Completed Order",
                  Icons.check_circle_outline, // correct completed icon
                  Colors.blue,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CounterCompletedOrderPage()),
                    );
                  },
                ),

                _menuItem(
                  "Stock",
                  Icons.inventory_2_outlined, // correct stock icon
                  Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CounterTodaySellPage()),
                        );
                  },
                ),
                _menuItem(
                  "Today Sell",
                  Icons.today, // correct
                  Colors.red,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CounterTodaySellPage()),
                        );

                  },
                ),
                _menuItem(
                  "Total Sell",
                  Icons.bar_chart, // better analytics icon
                  Colors.deepPurple,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CounterTotalSellPage()),
                    );
                  },
                ),
                _menuItem(
                  "Online Payment",
                  Icons.payment, // correct
                  Colors.indigo,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CounterTransactionHistoryPage()),
                    );
                  },
                ),
                _menuItem(
                  "Cash Payment",
                  Icons.payments_outlined, // correct cash icon
                  Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CounterTransactionHistoryPage()),
                        );
                    // Add navigation here
                  },
                ),
                _menuItem(
                  "Wallet History",
                  Icons.account_balance_wallet_outlined, // correct wallet icon
                  Colors.brown,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CounterWalletHistoryPage()),
                    );
                  },
                ),
              ],

            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Placeholder pages
  Widget _buildCollectFeePage() => const Center(child: Text("Collect Fee Page"));
  Widget _buildSearchPage() => const Center(child: Text("Search Page"));
  Widget _buildReceiptsPage() => const Center(child: Text("Receipts Page"));
  Widget _buildReportsPage() => const Center(child: Text("Reports Page"));


  void _logout() async {
    try {
      final storage = SecureStorageService();
      await storage.clearAllCredentials();
    } catch (e) {
      print("Error clearing storage: $e");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}

class AnimatedBanner extends StatefulWidget {
  final String userName;

  const AnimatedBanner({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  _AnimatedBannerState createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<AnimatedBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slide = Tween<Offset>(
      begin: const Offset(-0.02, 0),
      end: const Offset(0.02, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade500,
              Colors.lightBlueAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign, color: Colors.white, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.userName.isNotEmpty
                    ? "Welcome back, ${widget.userName}! Have a productive day 🚀"
                    : "Welcome back! Have a productive day 🚀",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

        ),
      ),
    );
  }
}

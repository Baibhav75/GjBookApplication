import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bookworld/HomePagelist/addDayBook.dart';
import 'package:bookworld/adminPage/BilingPurchase/purchaseNotForSale.dart';
import 'package:bookworld/adminPage/HRMViewEmployee.dart';
import 'package:bookworld/adminPage/ViewCompanyPage.dart';
import 'package:bookworld/adminPage/publicationAgreement.dart';
import 'package:flutter/material.dart';
import 'package:bookworld/Model/change_password_model.dart';
import 'package:bookworld/Model/login_model.dart';
import 'package:bookworld/Service/change_password_service.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/home_screen.dart';

import '../HomePagelist/dayBookHistory.dart';
import 'BilingPurchase/PurchaseInvoice.dart';
import 'BilingPurchase/PurchaseSampleRevenew.dart';
import 'PurchaseReturn/PurchaseReturnInvoide.dart';
import 'PurchaseReturn/PurchaseReturnNotForSale.dart';
import 'PurchaseReturn/PurchaseReturnSampleRevenue.dart';
import 'Sale/SaleInvoice.dart';
import 'Sale/SampleSaleInvoice.dart';
import 'SellReturn/SaleReturnInvoice.dart';
import 'SellReturn/SamplesaleReturnInvoice.dart';
import 'ViewProductList.dart';
import 'interviewList.dart';

class AdminPage extends StatefulWidget {
  final LoginModel? userData;

  const AdminPage({Key? key, this.userData}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

  // add footer
  void _navigateToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _navigateToDayBook() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _navigateToAttendanceHistory() {
    setState(() {
      _currentIndex = 2;
    });
  }



  // Get user data from widget or use defaults
  String get adminName => widget.userData?.adminName ?? "Super Admin";
  String get adminEmail => widget.userData?.adminEmail ?? "admin@bookworld.com";
  String get mobileNo => widget.userData?.mobileNo ?? "";

  // Change Password Service and Controllers
  final ChangePasswordService _changePasswordService = ChangePasswordService();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();

  // Sample data for dashboard
  final List<Map<String, dynamic>> _dashboardStats = [
    {'title': 'Receiving',  'icon': Icons.download, 'color': Colors.green},
    {'title': 'Latest Order',  'icon': Icons.shopping_cart, 'color': Colors.blue},
    {'title': 'Total Sell',  'icon': Icons.trending_up, 'color': Colors.purple},
    {'title': 'Total Purchase',  'icon': Icons.shopping_bag, 'color': Colors.orange},
    {'title': 'Total Stall',  'icon': Icons.store, 'color': Colors.red},
    {'title': 'School List',  'icon': Icons.school, 'color': Colors.teal},
    {'title': 'Employee List', 'icon': Icons.people, 'color': Colors.indigo},

    {'title': 'Today Office Visit',  'icon': Icons.person, 'color': Colors.cyan},
    {'title': 'Add Day Book',  'icon': Icons.business, 'color': Colors.deepOrange},
    {'title': 'Day Book History',  'icon': Icons.history, 'color': Colors.brown},
    {'title': 'Purchase Invoice', 'icon': Icons.receipt, 'color': Colors.amber},
    {'title': 'Sale Invoice',  'icon': Icons.point_of_sale, 'color': Colors.lightGreen},
    {'title': 'Purchase Return',  'icon': Icons.assignment_return, 'color': Colors.pink},
    {'title': 'Sale Return',  'icon': Icons.keyboard_return, 'color': Colors.deepPurple},
    {'title': 'Company List',  'icon': Icons.business_center, 'color': Colors.lightBlue},
    {'title': 'Product List',  'icon': Icons.inventory_2, 'color': Colors.blueGrey},
    {'title': 'Interview List',  'icon': Icons.work, 'color': Colors.orangeAccent},
    {'title': 'Publication Agreement',  'icon': Icons.description, 'color': Colors.greenAccent},
  ];

  @override
  void dispose() {
    _mobileController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Admin Dashboard', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B46C1), // Purple color matching banner
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handlePopupMenuSelection(value);
            },
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Settings', 'Help', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _getCurrentPage(),
          ),
          // Footer Buttons
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF6B46C1), // Matching purple theme
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 30.sp,
                    color: const Color(0xFF6B46C1), // Matching purple theme
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  adminName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  adminEmail,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          // Dashboard
          _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),

          // Product Management (Expandable)
          _buildExpandableDrawerItem(
            Icons.inventory_2,
            'Product Management',
            [
              _buildDrawerSubItem(
                'View Product',
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewProductList(),
                    ),
                  );
                },
              ),

              _buildDrawerSubItem(
                'View Company',
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewCompanyPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          // Account (Expandable)
          _buildExpandableDrawerItem(
            Icons.account_balance_wallet,
            'Account',
            [
              _buildDrawerSubItem('Purchase Invoice'),
              _buildDrawerSubItem('Purchase Return'),
              _buildDrawerSubItem('Sale Invoice'),
              _buildDrawerSubItem('General Cashbook'),
              _buildDrawerSubItem('Account Cashbook'),
            ],
          ),

          // Billing (Expandable) - Fixed version
          _buildExpandableDrawerItem(
            Icons.receipt,
            'Billing',
            [
              _buildExpandableSubItem('Purchase', [
                _buildDrawerSubItem(
                  'Purchase Not For Sale',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  PurchaseForSale(),
                      ),
                    );
                  },
                ),
                _buildDrawerSubItem(
                  'Purchase Sample Revenew',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Purchasesamplerevenew(),
                      ),
                    );
                  },
                ),
                _buildDrawerSubItem(
                  'Purchase Invoice',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseInvoice(),
                      ),
                    );
                  },
                ),
              ]),
              _buildExpandableSubItem('Purchase Return', [
                _buildDrawerSubItem(
                  'Purchase Return Not For Sale',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PuchaseReturnNotForSale(),
                      ),
                    );
                  },
                ),
                _buildDrawerSubItem(
                  'Purchase Return sample Revenue',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PucchaseReturnSampleRevenue(),
                      ),
                    );
                  },
                ),
                _buildDrawerSubItem(
                  'Puchase Return Invoice',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PuchaseReturnInvoice(),
                      ),
                    );
                  },
                ),
              ]),
              _buildExpandableSubItem('Sale', [
                _buildDrawerSubItem(
                  'Sale Invoice',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => saleInvoice(),
                      ),
                    );
                  },
                ),
                _buildDrawerSubItem(
                  'Sample Sale Invoice',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => samplesaleInvoice(),
                      ),
                    );
                  },
                ),
              ]),
              _buildExpandableSubItem('Sell Return', [
                _buildDrawerSubItem(
                  'sale Return Invoice',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => saleReturnInvoice(),
                      ),
                    );
                  },
                ),
                _buildDrawerSubItem(
                  'Sample Sale Return Invoice',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SampleSaleReturnInvoice(),
                      ),
                    );
                  },
                ),
              ]),
            ],
          ),

          // Account Opening Form (Expandable)
          _buildExpandableDrawerItem(
            Icons.description,
            'Account Opening Form',
            [
              _buildDrawerSubItem('Purchase Account Form'),
              _buildDrawerSubItem('Sell Account Form'),
              _buildDrawerSubItem('Investor Account Form'),
              _buildDrawerSubItem('Vendor Account Form'),
              _buildDrawerSubItem(
                'Publication Agreement',
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PublicationAgreementPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          // HRM (Expandable)
          _buildExpandableDrawerItem(
            Icons.people,
            'HRM',
            [
              _buildDrawerSubItem(
                'View Employee',
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HRMViewEmployee(),
                    ),
                  );
                },
              ),
              _buildDrawerSubItem('Employee Tree'),
              _buildDrawerSubItem(
                'Interview List',
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InterviewList (),
                    ),
                  );
                },
              ),
            ],
          ),

          // Setting (Expandable)
          _buildExpandableDrawerItem(
            Icons.settings,
            'Setting',
            [
              _buildDrawerSubItem('Change Password'),
            ],
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // Helper method for expandable drawer items
  Widget _buildExpandableDrawerItem(IconData icon, String title, List<Widget> children) {
    return ExpansionTile(
      leading: Icon(icon, color: const Color(0xFF6B46C1)), // Matching purple theme
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16.sp),
      ),
      children: children,
    );
  }

  // Helper method for nested expandable sub-menu items
  Widget _buildExpandableSubItem(String title, List<Widget> children) {
    return ExpansionTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14.sp),
      ),
      children: children,
    );
  }

  // Helper method for sub-menu items with optional onTap parameter
  Widget _buildDrawerSubItem(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(left: 32.0.w),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        onTap: onTap ?? () {
          Navigator.pop(context); // Close drawer
          _handleSubMenuItemTap(title);
        },
      ),
    );
  }

  // Original drawer item method
  Widget _buildDrawerItem(IconData icon, String title, int? index) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B46C1)), // Matching purple theme
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16.sp),
      ),
      onTap: () {
        if (index != null) {
          setState(() {
            _currentIndex = index;
          });
        }
        Navigator.pop(context); // Close drawer
      },
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return DayBookHistory();
      case 2:
        return ViewProductList();
      case 3:
        return _buildComingSoon('Latest Order');
      default:
        return _buildDashboard();
    }
  }


  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card - Matching appBar color
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1), // Same purple as appBar
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $adminName!',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Here\'s your dashboard overview for today',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          'Last updated: ${DateTime.now().toString().split(' ')[1].substring(0, 5)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _refreshData,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          ..._buildDashboardOverviewSections(),
        ],
      ),
    );
  }

  List<Widget> _buildDashboardOverviewSections() {
    // First container: 8 items, Second container: 4 items
    final firstChunk = _dashboardStats.length >= 8 
        ? _dashboardStats.sublist(0, 8) 
        : _dashboardStats;
    final secondChunk = _dashboardStats.length > 8 
        ? _dashboardStats.sublist(8, math.min(12, _dashboardStats.length))
        : <Map<String, dynamic>>[];

    final List<Widget> sections = [];

    // First Container with 8 items
    if (firstChunk.isNotEmpty) {
      sections.add(_buildDashboardContainer('Dashboard Overview', firstChunk, true));
    }

    // Second Container with 4 items
    if (secondChunk.isNotEmpty) {
      sections.add(_buildDashboardContainer('Quick Insights', secondChunk, false));
    }

    return sections;
  }

  Widget _buildDashboardContainer(String title, List<Map<String, dynamic>> items, bool showViewAll) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showViewAll)
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B46C1),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h), // Changed const SizedBox to SizedBox
            GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.65, // Increased height to prevent overflow
            ),itemBuilder: (context, gridIndex) =>
                _buildDashboardGridItem(items[gridIndex]),
          ),

        ],
      ),
    );
  }

  Widget _buildDashboardGridItem(Map<String, dynamic> stat) {
    return GestureDetector(
      onTap: () {

        // Yahan specific title check karke navigation karo

        if (stat['title'] == 'Add Day Book') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDayBook()), // ← Apna DayBookPage yahan daalo
          );
        }

        if (stat['title'] == 'Day Book History') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DayBookHistory()), // ← Apna DayBookPage yahan daalo
          );
        }
        // Baaki titles ke liye future mein aur navigation add kar sakte ho
        else if (stat['title'] == 'Purchase Invoice') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseInvoice()));
        }
        // ... aur bhi add kar sakte ho
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${stat['title']} - Coming Soon!')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: stat['color'],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                stat['icon'],
                size: 26.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              stat['title'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: Colors.black87,
              ),
            ),
          ],
        ),

      ),
    );
  }



  Widget _buildComingSoon(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'This feature is coming soon!',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0; // Go back to dashboard
              });
            },
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: Text('Notification ${index + 1}'),
                  subtitle: Text('This is notification details ${index + 1}'),
                  onTap: () {},
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins(fontSize: 14.sp)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Clear secure storage
                try {
                  final storageService = SecureStorageService();
                  await storageService.clearAllCredentials();
                } catch (e) {
                  // Log error but continue with logout
                  print('Error clearing credentials: $e');
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );

                // Navigate to HomeScreen page
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handlePopupMenuSelection(String value) {
    switch (value) {
      case 'Profile':
        _showProfile();
        break;
      case 'Settings':
        setState(() {
          _currentIndex = 6;
        });
        break;
      case 'Help':
        _showHelp();
        break;
      case 'Logout':
        _logout();
        break;
    }
  }

  void _handleSubMenuItemTap(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title selected - Feature coming soon!'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    // You can add navigation logic here for each menu item
    switch (title) {
      case 'View Product':
        setState(() {
          _currentIndex = 1;
        });
        break;
      case 'Change Password':
        _changePassword();
        break;
    // Add more cases for other menu items
    }
  }


  void _showProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Admin Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileInfo('Name', adminName),
              _buildProfileInfo('Email', adminEmail),
              if (mobileNo.isNotEmpty) _buildProfileInfo('Mobile', mobileNo),
              _buildProfileInfo('Role', 'System Administrator'),
              _buildProfileInfo('Last Login', 'Today, ${DateTime.now().toString().split(' ')[1].substring(0, 5)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Text('For support, please contact:\n\nEmail: support@bookpiv.com\nPhone: +1-234-567-8900\n\nOur team is available 24/7 to assist you.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() {
    // Clear previous inputs
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    // Pre-fill mobile number from user data if available
    _mobileController.text = mobileNo.isNotEmpty ? mobileNo : "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool isChangingPassword = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Change Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: _changePasswordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        readOnly: mobileNo.isNotEmpty, // Disable if already filled from user data
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          labelStyle: GoogleFonts.poppins(),
                          hintText: mobileNo.isNotEmpty
                              ? 'Your registered mobile number'
                              : 'Enter 10-digit mobile number',
                          hintStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.phone_android),
                          border: const OutlineInputBorder(),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mobile number';
                          }
                          if (value.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          if (!_changePasswordService.isValidMobileNumber(value)) {
                            return 'Please enter valid mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _oldPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter current password';
                          }
                          if (!_changePasswordService.isValidPassword(value)) {
                            return 'Password must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter new password';
                          }
                          if (!_changePasswordService.isValidPassword(value)) {
                            return 'Password must be at least 3 characters';
                          }
                          if (value == _oldPasswordController.text) {
                            return 'New password must be different from current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isChangingPassword
                      ? null
                      : () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: isChangingPassword
                      ? null
                      : () async {
                    if (_changePasswordFormKey.currentState!.validate()) {
                      setDialogState(() {
                        isChangingPassword = true;
                      });

                      try {
                        final response =
                        await _changePasswordService.changePassword(
                          mobileNo: _mobileController.text.trim(),
                          oldPassword: _oldPasswordController.text.trim(),
                          newPassword: _newPasswordController.text.trim(),
                          confirmPassword:
                          _confirmPasswordController.text.trim(),
                        );

                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                          if (response.isSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    response.message ?? 'Password changed successfully!'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            // Clear controllers after success
                            _mobileController.clear();
                            _oldPasswordController.clear();
                            _newPasswordController.clear();
                            _confirmPasswordController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    response.message ?? 'Failed to change password. Please try again.'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          setDialogState(() {
                            isChangingPassword = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e
                                  .toString()
                                  .replaceAll('Exception: ', '')),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1), // Matching purple theme
                    foregroundColor: Colors.white,
                  ),
                  child: isChangingPassword
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                       : Text('Change Password', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildFooter() {
    return Container(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(0, Icons.grid_view, "Dashboard", _navigateToHome),
          _footerItem(1, Icons.history, "History", _navigateToDayBook),
          _footerItem(2, Icons.search, "Search", _navigateToAttendanceHistory),
          _footerItem(3, Icons.shopping_cart, "Latest Order", () {
            setState(() => _currentIndex = 3);
          }),
        ],
      ),
    );
  }



  Widget _footerItem(
      int index,
      IconData icon,
      String label,
      VoidCallback onTap,
      )
  {
    final bool isSelected = _currentIndex == index;


    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF6B46C1) : Colors.grey,
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Text(label)
                  : SizedBox(),
            )

          ],
        ),
      ),
    );
  }




}
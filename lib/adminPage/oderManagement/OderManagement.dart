import 'package:bookworld/adminPage/oderManagement/publication_list_page.dart';
import 'package:bookworld/adminPage/oderManagement/schoolDiscountAgrementForm.dart';
import 'package:bookworld/adminPage/oderManagement/school_agrement_old_mix_list_page.dart';
import 'package:bookworld/adminPage/oderManagement/tracking_order_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../SellReturn/order_list_screen.dart';
import 'discussion_order_list_screen.dart';
import 'dispatch_order_list_screen.dart';
import 'individual_order_list_screen.dart';
import 'oderProcessBill.dart';
import 'oder_list_dispatch_view.dart';
import 'order_excel_sheet_page.dart';
import 'order_letter_pad_list_page.dart';
import '/adminPage/oderManagement/publication_merge_order_list_get_club_page.dart';

class OrderManagementPage extends StatelessWidget {
  const OrderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1), // Purple background
        iconTheme: const IconThemeData(color: Colors.white), // Back icon white
        title: Text(
          'Order Management',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white, // ✅ Text color white
          ),
        ),
        centerTitle: false, // optional
      ),

      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 🔽 ORDER MANAGEMENT DROPDOWN
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              iconColor: const Color(0xFF6B46C1),
              collapsedIconColor: const Color(0xFF6B46C1),

              title: Text(
                'Order Management Options',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              children: [
                _orderItem(context, 1, 'School Order Letter Pad Record'),

                _orderItem(context, 2, 'School Discount Agreement Form'),
                _orderItem(context, 3, 'Order Process Billing With School Stretch',),
                _orderItem(context, 4, 'All Order Details'),

                //_orderItem(context, 4, 'School Agreement with Old Mix Report Mention'),
                _orderItem(context, 5, 'Order Excel Sheet'),
                _orderItem(context, 6, 'Discussion Order Details'),
                // _orderItem(context, 7, 'Book List (Publication Without Publication)'),
                _orderItem(context, 7, 'Merge Publication Order Form'),
                _orderItem(context, 8, 'Individual Oder Details'),
                _orderItem(context, 9, 'Marge Order Details'),
                _orderItem(
                  context,
                  10,
                  'Order Tracking (GR Number Transport Name)',
                ),
                _orderItem(context, 11, 'Order Pending'),
                _orderItem(context, 12, 'Dispatch Order List'),
                _orderItem(context, 13, 'Publication Oder'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= ORDER ITEM CARD =================

  Widget _orderItem(BuildContext context, int index, String title) {
    // 🔴 Titles that should be red
    final List<String> redItems = [
      'Order Pending',
      'Merge Publication Order Form'
    ];

    final bool isRed = redItems.contains(title);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _navigateToPage(context, title);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isRed ? Colors.red.shade300 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              // 🔴 Number Badge
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isRed ? Colors.red : const Color(0xFF6B46C1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  index.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 🔴 Title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isRed ? Colors.red : Colors.black87,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isRed ? Colors.red : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String title) {
    Widget page;

    switch (title) {//Order Process Billing With School Stretch
      case 'School Order Letter Pad Record':
        page = const OrderLetterPadListPage(); // OrderListScreen()),
        break;

      case 'School Discount Agreement Form':
        page = const SchoolDiscountAgreementForm();
        break;

      case 'Order Process Billing With School Stretch':
        page = const OrderProcessBill();
        break;

      case 'All Order Details':
        page = const OrderListScreen();
        break;

      case 'Discussion Order Details':
        page = const DiscussionOrderListScreen();
        break;

      case 'Order Pending':
        page = const OrderPlaceholderPage(title: 'Order Pending');
        break;

      case 'School Agreement with Old Mix Report Mention':
        page = const SchoolAgrementOldMixListPage();
        break;

      case 'Order Excel Sheet':
        page = const OrderExcelSheetPage();
        break;

      case 'Order Tracking (GR Number Transport Name)':
        page = const TrackingOrderListScreen();
        break;

      case 'Individual Oder Details':
        page = const IndividualOrderListScreen();
        break;

      case 'Marge Order Details':
        page = const PublicationMergeOrderListGetClubPage();
        break;

      case 'Dispatch Order ListDispatch Order List':
        page = const DispatchOrderListScreen();
        break;

      case 'Publication Oder':
        page = const PublicationOrderManagementPage();
        break;

      case 'Dispatch Order List':
        page = const OrderListDispatchView();
        break;

      default:
        page = OrderPlaceholderPage(title: title);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class OrderPlaceholderPage extends StatelessWidget {
  final String title;

  const OrderPlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF6B46C1),
      ),
      body: Center(
        child: Text(
          '$title Page Coming Soon',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

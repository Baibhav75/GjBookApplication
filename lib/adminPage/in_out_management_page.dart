import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Model/in_out_management_model.dart';
import '../Service/in_out_management_service.dart';

class InOutManagementPage extends StatefulWidget {
  const InOutManagementPage({Key? key}) : super(key: key);

  @override
  State<InOutManagementPage> createState() =>
      _InOutManagementPageState();
}

class _InOutManagementPageState extends State<InOutManagementPage> {
  late Future<List<InOutManagementModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = InOutManagementService.fetchInOutList();
  }

  /// 🔄 Refresh data
  void _refreshData() {
    setState(() {
      _future = InOutManagementService.fetchInOutList();
    });
  }

  /// 🔔 Notifications
  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No new notifications")),
    );
  }

  /// ☰ Popup menu actions
  void _handlePopupMenuSelection(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$value clicked")),
    );
  }
  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
                  ),

                  /// ❌ Close Button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("dd-MM-yyyy hh:mm a").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IN/OUT Management',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6B46C1),
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
            onSelected: _handlePopupMenuSelection,
            itemBuilder: (context) {
              return ['Profile', 'Settings', 'Help', 'Logout']
                  .map(
                    (choice) => PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                ),
              )
                  .toList();
            },
          ),
        ],
      ),

      /// ================= BODY =================
      body: FutureBuilder<List<InOutManagementModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data ?? [];

          return SingleChildScrollView(
            child: PaginatedDataTable(
              header: const Text("In-Out Records"),
              rowsPerPage: 10,
              availableRowsPerPage: const [10, 20, 50, 100],
              showCheckboxColumn: false,
              columnSpacing: 18,
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Type")),
                DataColumn(label: Text("Info")),
                DataColumn(label: Text("Item")),
                DataColumn(label: Text("Remarks")),
                DataColumn(label: Text("Qty")),
                DataColumn(label: Text("Rate")),
                DataColumn(label: Text("Amount")),
                DataColumn(label: Text("Date Time")),
                DataColumn(label: Text("Image")),
                DataColumn(label: Text("Action")),
              ],
              source: _InOutDataSource(
                context: context,
                data: data,
                formatDate: _formatDate,
                onImageTap: _showFullScreenImage,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ================= DATASOURCE =================
class _InOutDataSource extends DataTableSource {
  final BuildContext context;
  final List<InOutManagementModel> data;
  final String Function(DateTime?) formatDate;
  final void Function(String) onImageTap;
  _InOutDataSource({
    required this.context,
    required this.data,
    required this.formatDate,
    required this.onImageTap,
  });

  @override
  DataRow getRow(int index) {
    final item = data[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(item.name ?? "-")),
        DataCell(
          Text(
            item.itemType ?? "-",
            style: TextStyle(
              color: item.itemType == "IN"
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(Text(item.information ?? "-")),
        DataCell(Text(item.itemName ?? "-")),
        DataCell(Text(item.remarks ?? "-")),
        DataCell(Text(item.qty ?? "-")),
        DataCell(Text(item.rate ?? "-")),
        DataCell(
          Text(
            item.amount != null
                ? item.amount!.toStringAsFixed(2)
                : "-",
          ),
        ),
        DataCell(Text(formatDate(item.createDate))),
        DataCell(
          item.image != null && item.image!.startsWith("http")
              ? InkWell(
            onTap: () => onImageTap(item.image!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.image!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.image),
              ),
            ),
          )
              : const Icon(Icons.image_not_supported),
        ),


        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                  Text("Viewing ${item.itemName ?? ''}"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

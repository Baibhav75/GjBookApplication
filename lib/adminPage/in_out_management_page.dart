import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Model/in_out_management_model.dart';
import '../Service/in_out_management_service.dart';

class InOutManagementPage extends StatefulWidget {
  const InOutManagementPage({Key? key}) : super(key: key);

  @override
  State<InOutManagementPage> createState() => _InOutManagementPageState();
}

class _InOutManagementPageState extends State<InOutManagementPage> {
  late Future<List<InOutManagementModel>> _future;

  static const String _baseUrl = "https://g17bookworld.com";

  @override
  void initState() {
    super.initState();
    _future = InOutManagementService.fetchInOutList();
  }

  /// ✅ SAFE IMAGE URL BUILDER (IMPORTANT FIX)
  String? _buildImageUrl(String? image) {
    if (image == null || image.trim().isEmpty) return null;

    if (image.startsWith("http")) {
      return Uri.encodeFull(image);
    }

    return Uri.encodeFull("$_baseUrl$image");
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("dd-MM-yyyy hh:mm a").format(date);
  }

  /// 🖼 FULL SCREEN IMAGE VIEW
  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const CircularProgressIndicator(
                      color: Colors.white,
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
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close,
                    color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 DETAILS BOTTOM SHEET
  void _showDetails(InOutManagementModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Name", item.name),
            _detailRow("Type", item.itemType),
            _detailRow("Item", item.itemName),
            _detailRow("Qty", item.qty),
            _detailRow("Rate", item.rate),
            _detailRow(
              "Amount",
              item.amount?.toStringAsFixed(2),
            ),
            _detailRow(
              "Date",
              _formatDate(item.createDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "IN / OUT Management",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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

          if (data.isEmpty) {
            return const Center(child: Text("No records found"));
          }

          return SingleChildScrollView(
            child: PaginatedDataTable(
              header: const Text("In / Out Records"),
              rowsPerPage: 10,
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Type")),
                DataColumn(label: Text("Item")),
                DataColumn(label: Text("Qty")),
                DataColumn(label: Text("Amount")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Image")),
                DataColumn(label: Text("Action")),
              ],
              source: _InOutSource(
                data: data,
                buildImageUrl: _buildImageUrl,
                onImageTap: _showFullScreenImage,
                onView: _showDetails,
                formatDate: _formatDate,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ================= DATASOURCE =================
class _InOutSource extends DataTableSource {
  final List<InOutManagementModel> data;
  final String? Function(String?) buildImageUrl;
  final void Function(String) onImageTap;
  final void Function(InOutManagementModel) onView;
  final String Function(DateTime?) formatDate;

  _InOutSource({
    required this.data,
    required this.buildImageUrl,
    required this.onImageTap,
    required this.onView,
    required this.formatDate,
  });

  @override
  DataRow getRow(int index) {
    final item = data[index];
    final imageUrl = buildImageUrl(item.image);

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
        DataCell(Text(item.itemName ?? "-")),
        DataCell(Text(item.qty ?? "-")),
        DataCell(
          Text(
            item.amount != null
                ? item.amount!.toStringAsFixed(2)
                : "-",
          ),
        ),
        DataCell(Text(formatDate(item.createDate))),
        DataCell(
          imageUrl != null && imageUrl.isNotEmpty
              ? GestureDetector(
                  onTap: () => onImageTap(imageUrl),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                           // If image fails to load, showing icon is fine, but logging might help debug
                           return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image, size: 20, color: Colors.grey[400]),
                           );
                        },
                      ),
                    ),
                  ),
                )
              : const Icon(Icons.image_not_supported, color: Colors.grey),
        ),

        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility,
                color: Colors.blue),
            onPressed: () => onView(item),
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

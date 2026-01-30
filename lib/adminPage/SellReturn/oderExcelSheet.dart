import 'package:flutter/material.dart';
import '../../Model/oder_excelsheet_model.dart';
import '../../Service/oder_excelsheet_service.dart';

class OderExcelSheet extends StatefulWidget {
  final String billNo;
  const OderExcelSheet({super.key, required this.billNo});

  @override
  State<OderExcelSheet> createState() => _OderExcelSheetState();
}

class _OderExcelSheetState extends State<OderExcelSheet> {
  late Future<OrderExcelSheetModel> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData =
        OrderExcelSheetService.fetchOrderExcelSheet(widget.billNo);
  }

  // ===== CLASS HEADERS (EXCEL COLUMNS) =====
  final List<String> classHeaders = [
    "NURSERY",
    "LKG",
    "UKG",
    "I",
    "II",
    "III",
    "IV",
    "V",
    "VI",
    "VII",
    "VIII",
    "IX",
    "X",
    "XI",
    "XII",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          "Book Bill",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<OrderExcelSheetModel>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final model = snapshot.data!;
          final excelRows = _buildExcelRows(model);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(model),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildExcelTable(excelRows),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(OrderExcelSheetModel model) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              model.schoolName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text("Bill No : ${model.billNo}"),
          ],
        ),
      ),
    );
  }

  // ================= EXCEL DATA TRANSFORM =================
  List<ExcelRow> _buildExcelRows(OrderExcelSheetModel model) {
    final Map<String, ExcelRow> map = {};

    for (final classData in model.data) {
      // Normalize the class name from API (e.g., "1" -> "I", "Class 1" -> "I")
      final normalizedClass = _normalizeClassName(classData.className);

      for (final item in classData.items) {
        final key = "${item.subject}_${item.bookName}";

        if (!map.containsKey(key)) {
          map[key] = ExcelRow(
            subject: item.subject,
            bookName: item.bookName,
            publication: item.publication,
            series: item.series,
            classQty: {},
          );
        }

        map[key]!.classQty[normalizedClass] = item.totalQty;
      }
    }

    return map.values.toList();
  }

  String _normalizeClassName(String apiClassName) {
    // Trim and upper case to be safe
    final name = apiClassName.trim().toUpperCase();

    // Mapping for standard numbers 1-12 to Roman
    switch (name) {
      case "1":
      case "01":
      case "CLASS 1":
      case "CLASS I":
        return "I";
      case "2":
      case "02":
      case "CLASS 2":
      case "CLASS II":
        return "II";
      case "3":
      case "03":
      case "CLASS 3":
      case "CLASS III":
        return "III";
      case "4":
      case "04":
      case "CLASS 4":
      case "CLASS IV":
        return "IV";
      case "5":
      case "05":
      case "CLASS 5":
      case "CLASS V":
        return "V";
      case "6":
      case "06":
      case "CLASS 6":
      case "CLASS VI":
        return "VI";
      case "7":
      case "07":
      case "CLASS 7":
      case "CLASS VII":
        return "VII";
      case "8":
      case "08":
      case "CLASS 8":
      case "CLASS VIII":
        return "VIII";
      case "9":
      case "09":
      case "CLASS 9":
      case "CLASS IX":
        return "IX";
      case "10":
      case "CLASS 10":
      case "CLASS X":
        return "X";
      case "11":
      case "CLASS 11":
      case "CLASS XI":
        return "XI";
      case "12":
      case "CLASS 12":
      case "CLASS XII":
        return "XII";
    }

    // Return as-is for NURSERY, LKG, UKG, or if already correct
    return name;
  }

  // ================= EXCEL STYLE TABLE =================
  Widget _buildExcelTable(List<ExcelRow> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Colors.cyan.shade100,
          ),
          dataRowMinHeight: 40,
          dataRowMaxHeight: 48,
          columnSpacing: 18,
          border: TableBorder.all(
            color: Colors.grey.shade300,
          ),
          columns: [
            const DataColumn(
              label: Text(
                "Sr.No",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                "Publication",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                "Series",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                "Subject",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                "Book Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...classHeaders.map(
                  (cls) => DataColumn(
                label: Text(
                  cls,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: rows.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final row = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(Text(row.publication)),
                DataCell(Text(row.series)),
                DataCell(Text(row.subject)),
                DataCell(Text(row.bookName)),
                ...classHeaders.map((cls) {
                  return DataCell(
                    Center(
                      child: Text(
                        row.classQty[cls]?.toString() ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ================= EXCEL ROW MODEL =================
class ExcelRow {
  final String subject;
  final String bookName;
  final String publication;
  final String series;
  final Map<String, int> classQty;

  ExcelRow({
    required this.subject,
    required this.bookName,
    required this.publication,
    required this.series,
    required this.classQty,
  });
}

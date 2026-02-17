import 'package:flutter/material.dart';
import 'package:bookworld/Model/merge_order_details_model.dart';
import 'package:bookworld/Service/merge_order_details_service.dart';

class MergeOrderDetailsPage extends StatefulWidget {
  final String publicationId;

  const MergeOrderDetailsPage({super.key, required this.publicationId});

  @override
  State<MergeOrderDetailsPage> createState() =>
      _MergeOrderDetailsPageState();
}

class _MergeOrderDetailsPageState
    extends State<MergeOrderDetailsPage> {

  late Future<List<MergeOrderDetailsModel>> futureDetails;

  @override
  void initState() {
    super.initState();
    futureDetails =
        MergeOrderDetailsService.fetchDetails(widget.publicationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Merge Order Details"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<MergeOrderDetailsModel>>(
        future: futureDetails,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }

          final details = snapshot.data ?? [];

          if (details.isEmpty) {
            return const Center(child: Text("No data found"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                    Colors.deepPurple.shade50),
                columnSpacing: 18,
                dataRowHeight: 48,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text("Sr No")),
                  DataColumn(label: Text("Publication")),
                  DataColumn(label: Text("Series")),
                  DataColumn(label: Text("Subject")),
                  DataColumn(label: Text("Book Name")),
                  DataColumn(label: Text("NU")),
                  DataColumn(label: Text("LKG")),
                  DataColumn(label: Text("UKG")),
                  DataColumn(label: Text("Class1")),
                  DataColumn(label: Text("Class2")),
                  DataColumn(label: Text("Class3")),
                  DataColumn(label: Text("Class4")),
                  DataColumn(label: Text("Class5")),
                  DataColumn(label: Text("Class6")),
                  DataColumn(label: Text("Class7")),
                  DataColumn(label: Text("Class8")),
                  DataColumn(label: Text("Class9")),
                  DataColumn(label: Text("Class10")),
                  DataColumn(label: Text("Class11")),
                  DataColumn(label: Text("Class12")),
                  DataColumn(label: Text("School Name")),
                ],
                rows: List.generate(details.length, (index) {
                  final item = details[index];

                  return DataRow(
                    cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(_safeString(item.publication))),
                      DataCell(Text(_safeString(item.series))),
                      DataCell(Text(_safeString(item.subject))),
                      DataCell(Text(_safeString(item.bookName))),

                      // 👇 ZERO & NULL CONDITION APPLIED
                      DataCell(_numberCell(item.nU)),
                      DataCell(_numberCell(item.lKG)),
                      DataCell(_numberCell(item.uKG)),
                      DataCell(_numberCell(item.class1)),
                      DataCell(_numberCell(item.class2)),
                      DataCell(_numberCell(item.class3)),
                      DataCell(_numberCell(item.class4)),
                      DataCell(_numberCell(item.class5)),
                      DataCell(_numberCell(item.class6)),
                      DataCell(_numberCell(item.class7)),
                      DataCell(_numberCell(item.class8)),
                      DataCell(_numberCell(item.class9)),
                      DataCell(_numberCell(item.class10)),
                      DataCell(_numberCell(item.class11)),
                      DataCell(_numberCell(item.class12)),

                      DataCell(Text(_safeString(item.schoolName))),
                    ],
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= HELPER METHODS =================

  /// 🔹 Safe string (no null text)
  String _safeString(String? value) {
    if (value == null || value == "null") {
      return "";
    }
    return value;
  }

  /// 🔹 Hide 0 and null values
  Widget _numberCell(dynamic value) {
    if (value == null) return const SizedBox();

    final val = value.toString();

    if (val == "0" || val == "0.0" || val == "null" || val.isEmpty) {
      return const SizedBox();
    }

    return Text(val);
  }
}

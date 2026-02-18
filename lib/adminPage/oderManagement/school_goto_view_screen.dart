import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../Model/school_goto_view_model.dart';
import '../../Service/school_goto_view_service.dart';
import 'SchoolAgreementfullDetails.dart';

class SchoolGotoViewScreen extends StatefulWidget {
  const SchoolGotoViewScreen({super.key});

  @override
  State<SchoolGotoViewScreen> createState() =>
      _SchoolGotoViewScreenState();
}

class _SchoolGotoViewScreenState
    extends State<SchoolGotoViewScreen> {
  List<AgreementItem> agreementList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgreements();
  }

  Future<void> _loadAgreements() async {
    try {
      final data =
      await SchoolGotoViewService().fetchAgreements();
      setState(() {
        agreementList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load data")),
      );
    }
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "School Agreement List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
             child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
              MaterialStateProperty.all(
                  Colors.grey.shade200),
              columnSpacing: 30,
              columns: const [
                DataColumn(label: Text("Sr No.")),
                DataColumn(label: Text("Agreement Date")),
                DataColumn(label: Text("Party Name")),
                DataColumn(label: Text("Address")),
                DataColumn(label: Text("District")),
                DataColumn(label: Text("Principal Name")),
                DataColumn(label: Text("Principal Mo_No")),
                DataColumn(label: Text("CreatedBy")),
                DataColumn(label: Text("Action")),
              ],
              rows: List.generate(
                agreementList.length,
                    (index) {
                  final item = agreementList[index];

                  return DataRow(
                    cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(
                          Text(formatDate(item.createDate))),
                      DataCell(Text(item.partyName)),
                      DataCell(Text(item.address)),
                      DataCell(Text(item.district)),
                      DataCell(Text(item.principalName)),
                      DataCell(Text(item.principalContact)),
                      const DataCell(Text("Admin")),
                      DataCell(
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SchoolAgreementScreen(
                                      partyName: item.partyName,
                                      id: item.id,
                                    ),
                                  ),
                                );
                              },

                              style: ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                Colors.green,
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                    horizontal: 12,
                                    vertical: 6),
                                minimumSize:
                                const Size(0, 30),
                              ),
                              child: const Text(
                                'Agreement',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

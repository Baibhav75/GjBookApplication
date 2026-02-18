import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../Model/SchoolAgreementFullDetailsModel.dart';
import '../../Service/school_agreement_full_details_service.dart';

class SchoolAgreementScreen extends StatefulWidget {
  final int id;
  final String partyName;

  const SchoolAgreementScreen({
    super.key,
    required this.id,
    required this.partyName,
  });

  @override
  State<SchoolAgreementScreen> createState() =>
      _SchoolAgreementScreenState();
}

class _SchoolAgreementScreenState
    extends State<SchoolAgreementScreen> {

  String? partySignaturePath;
  String? managerSignaturePath;

  bool isLoading = true;
  String? errorMessage;
  Data? agreementData;

  final SchoolAgreementFullDetailsService _service = SchoolAgreementFullDetailsService();

  @override
  void initState() {
    super.initState();
    _loadAgreementDetails();
  }

  Future<void> _loadAgreementDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _service.fetchAgreementDetails(widget.id);
      if (data != null) {
        setState(() {
          agreementData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load agreement details.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }

  Future<void> pickImage(bool isParty) async {
    // Use file_picker package
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        if (isParty) {
          partySignaturePath = result.files.single.path;
        } else {
          managerSignaturePath = result.files.single.path;
        }
      });
    }
  }

  String _getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';

    // Check if it's already a full URL
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }

    // Fix common issues
    String fixedPath = relativePath.trim();

    // Ensure it starts with /
    if (!fixedPath.startsWith('/')) {
      fixedPath = '/$fixedPath';
    }
    const String baseUrl = "https://g17bookworld.com";
    return "$baseUrl$fixedPath";
  }

  Widget _buildNetworkImage(String? path, {double height = 100}) {
    final url = _getFullImageUrl(path);

    if (url.isEmpty) {
      return const Center(child: Text("No Image"));
    }

    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, color: Colors.grey, size: 30),
              const SizedBox(height: 4),
              Text(
                "Failed to load",
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(agreementData?.partyName ?? ""),

        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadAgreementDetails,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 900,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  "GJ BOOK WORLD PVT. LTD. - 2026",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text("D-1/20, Sector-22, GIDA, GORAKHPUR"),
                                Text("MO. NO. 9354918638, 9354918640"),
                                SizedBox(height: 8),
                                Text(
                                  "Agreement & Order Form",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// DATE & FILE
                          buildRowField("DATE :", agreementData?.createDate ?? ""),
                          buildRowField("FILE NO :", agreementData?.fileNo ?? ""),

                          const SizedBox(height: 10),

                          /// SUPPLY TYPE
                          buildRowField("Supply Type :", "SUPPLY"),
                          buildRowField("School Type :", agreementData?.schoolType ?? ""),

                          const SizedBox(height: 20),

                          /// 1. PARTY DETAILS
                          buildSectionTitle("1. PARTY DETAILS"),
                          buildRowField("Party Name :", agreementData?.partyName ?? ""),
                          buildRowField("School ID :", agreementData?.schoolId ?? ""),
                          buildRowField("Agent ID :", agreementData?.agentId ?? ""),

                          /// 2. SCHOOL DETAILS
                          buildSectionTitle("2. NAME & ADDRESS OF SCHOOL"),
                          buildDataBox(agreementData?.partyName ?? ""), // Usually name comes first in address section
                          buildDataBox(agreementData?.address ?? ""),
                          buildRowField("District :", agreementData?.district ?? ""),
                          buildRowField("Block :", agreementData?.block ?? ""),
                          buildRowField("Area :", agreementData?.area ?? ""),

                          /// 3. MANAGER DETAILS
                          buildSectionTitle("3. MANAGER'S DETAILS"),
                          buildRowField("Name :", agreementData?.manageName ?? ""),
                          buildRowField("Contact No :", agreementData?.managerContact ?? ""),
                          buildRowField("Date of Birth :", agreementData?.managerDOB ?? ""),
                          buildRowField("Anniversary :", agreementData?.managerAnniversary ?? ""),

                          /// 4. PRINCIPAL DETAILS
                          buildSectionTitle("4. PRINCIPAL'S DETAILS"),
                          buildRowField("Name :", agreementData?.principalName ?? ""),
                          buildRowField("Contact No :", agreementData?.principalContact ?? ""),
                          buildRowField("Date of Birth :", agreementData?.principalDOB ?? ""),
                          buildRowField("Anniversary :", agreementData?.principalAnniversary ?? ""),

                          /// 5. AGENT DETAILS
                          buildSectionTitle("5. AGENT'S DETAILS"),
                          buildRowField("Name :", agreementData?.agentName ?? ""),
                          buildRowField("Contact No :", agreementData?.agentContact ?? ""),
                          buildRowField("Date of Birth :", agreementData?.agentDOB ?? ""),
                          buildRowField("Anniversary :", agreementData?.agentAnniversary ?? ""),

                          /// 6. AREA MANAGER DETAILS
                          buildSectionTitle("6. AREA MANAGER'S DETAILS"),
                          buildRowField("Name :", agreementData?.areaManagerName ?? ""),
                          buildRowField("Contact No :", agreementData?.areaManagerContact ?? ""),
                          buildRowField("Date of Birth :", agreementData?.areaManagerDOB ?? ""),
                          buildRowField("Anniversary :", agreementData?.areaManagerAnniversary ?? ""),

                          /// 7. SCHOOL ID DOCUMENTS
                          buildSectionTitle("7. SCHOOL ID DOCUMENTS"),
                          buildRowField("PAN No :", agreementData?.schoolPanNo ?? ""),
                          buildRowField("Aadhar No :", agreementData?.schoolAdharNo ?? ""),



                buildSectionTitle("8. Order Date :"),
                buildDataBox(agreementData?.orderDate ?? ""),
                          buildRowField("Delivery Date :", agreementData?.deliveryDate ?? ""),

                          /// 9. BANK ACCOUNT DETAILS
                          buildSectionTitle("9. BANK ACCOUNT DETAILS"),
                          buildRowField("Account No :", agreementData?.schoolAccountNo ?? ""),
                          buildDataBox(agreementData?.schoolBankDetail ?? ""),

                          /// 10. SECURITY CHEQUE DETAILS
                          buildSectionTitle("10. SECURITY CHEQUE DETAILS"),
                          buildRowField("Cheque No :", agreementData?.chequeNo ?? ""),
                          buildRowField("Security Check :", agreementData?.securiyCheck ?? ""),

                const SizedBox(height: 15),

                /// PAYMENT TERMS
                buildSectionTitle("11. Payment Term & Condition"),

                const SizedBox(height: 8),

                /// DISCOUNT SLAB
                buildSectionTitle("Discount Slab"),

                const SizedBox(height: 10),

                buildDiscountField(1, agreementData?.discountSlab1 ?? ""),
                buildDiscountField(2, agreementData?.discountSlab2 ?? ""),
                buildDiscountField(3, agreementData?.discountSlab3 ?? ""),
                buildDiscountField(4, agreementData?.discountSlab4 ?? ""),
                buildDiscountField(5, agreementData?.discountSlab5 ?? ""),
                buildDiscountField(6, agreementData?.discountSlab6 ?? ""),
                buildDiscountField(7, agreementData?.discountSlab7 ?? ""),
                buildDiscountField(8, agreementData?.discountSlab8 ?? ""),
                buildDiscountField(9, agreementData?.discountSlab9 ?? ""),
                buildDiscountField(10, agreementData?.discountSlab10 ?? ""),
                buildDiscountField(11, agreementData?.discountSlab11 ?? ""),
                buildDiscountField(12, agreementData?.discountSlab12 ?? ""),

                const SizedBox(height: 20),

                /// REMARKS
                buildSectionTitle("Remarks"),
                buildDataBox(agreementData?.remarks ?? "", isLarge: true),

                const SizedBox(height: 15),

                /// SCHOOL ACCOUNT DETAILS
                buildTwoFieldDisplayRow("School Account No.", agreementData?.schoolAccountNo ?? "", "School Bank Details", agreementData?.schoolBankDetail ?? ""),

                const SizedBox(height: 10),

                /// CHEQUE DETAILS
                buildTwoFieldDisplayRow("Cheque No", agreementData?.chequeNo ?? "", "Security Cheque", agreementData?.securiyCheck ?? ""),

                Table(
                  border: TableBorder.all(color: Colors.black),
                  children: [
                    buildMonthRow(),
                    buildPercentRow(agreementData),
                  ],
                ),

                const SizedBox(height: 20),

                /// TERMS & CONDITIONS
                const Text(
                  "नियम एवं शर्तें:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "• कंपनी किसी भी प्रकार का डिस्काउंट मौखिक रूप से स्वीकार नहीं करेगी।\n"
                      "• भुगतान समय पर करना अनिवार्य है।\n"
                      "• विलंब भुगतान पर ब्याज लागू होगा।\n"
                      "• विवाद की स्थिति में न्यायालय गोरखपुर होगा।",
                  style: TextStyle(fontSize: 13),
                ),

                const SizedBox(height: 30),

                /// 14. SIGNATURES
                buildSectionTitle("14. SIGNATURES"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    /// PARTY SIGNATURE
                    Expanded(
                      child: Column(
                        children: [
                          const Text("PARTY SIGNATURE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 5),
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                            child: partySignaturePath != null
                                ? Image.file(File(partySignaturePath!), fit: BoxFit.contain)
                                : _buildNetworkImage(agreementData?.partySignature, height: 120),
                          ),

                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    /// MANAGER SIGNATURE
                    Expanded(
                      child: Column(
                        children: [
                          const Text("MANAGER SIGNATURE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 5),
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                            child: managerSignaturePath != null
                                ? Image.file(File(managerSignaturePath!), fit: BoxFit.contain)
                                : _buildNetworkImage(agreementData?.managerSignature, height: 120),
                          ),
                          const SizedBox(height: 5),

                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// PRINT BUTTON
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add print logic here
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.print),
                    label: const Text("PRINT AGREEMENT", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- WIDGETS ----------------

  static Widget buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.only(top: 10),
      color: Colors.grey[600],
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget buildRowField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value.isEmpty ? "---" : value)),
        ],
      ),
    );
  }

  static Widget buildDataBox(String value, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        value.isEmpty ? "---" : value,
        style: TextStyle(
          fontSize: 14,
          height: isLarge ? 1.5 : 1.2,
        ),
      ),
    );
  }

  static Widget buildEmptyBox() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
    );
  }

  static TableRow buildMonthRow() {
    List<String> months = [
      "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];
    return TableRow(
      children: months
          .map((e) => Padding(
                padding: const EdgeInsets.all(6),
                child: Text(e,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              ))
          .toList(),
    );
  }

  static TableRow buildPercentRow(Data? data) {
    List<String?> payments = [
      data?.januaryPayment, data?.februaryPayment, data?.marchPayment,
      data?.aprilPayment, data?.mayPayment, data?.junePayment,
      data?.julyPayment, data?.augustPayment, data?.septemberPayment,
      data?.octoberPayment, data?.novemberPayment, data?.decemberPayment,
    ];

    return TableRow(
      children: payments
          .map((e) => Padding(
                padding: const EdgeInsets.all(6),
                child: Text(e != null && e.isNotEmpty ? e : "0%",
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
              ))
          .toList(),
    );
  }

  static Widget buildDiscountField(int index, String value) {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.black),
              ),
            ),
            child: Text(
              "$index.",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                value.isEmpty ? "No discount details" : value,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }


  static Widget buildLargeTextField() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: const TextField(
        maxLines: 3,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter remarks here...",
        ),
      ),
    );
  }

  static Widget buildTwoFieldDisplayRow(
      String label1, String value1, String label2, String value2) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(value1.isEmpty ? "---" : value1),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.black,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(value2.isEmpty ? "---" : value2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTwoFieldTextRow(
      String label1, String label2) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(label1,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 90,
            color: Colors.black,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(label2,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SchoolWiseRegisterScreen extends StatefulWidget {
  const SchoolWiseRegisterScreen({super.key});

  @override
  State<SchoolWiseRegisterScreen> createState() =>
      _SchoolWiseRegisterScreenState();
}

class _SchoolWiseRegisterScreenState
    extends State<SchoolWiseRegisterScreen> {

  String? selectedSchool;

  /// Dummy Table Data
  final List<Map<String, dynamic>> tableData = [
    {
      "details": "Books Purchase",
      "date": "19-02-2026",
      "bill": "101",
      "debit": "500",
      "credit": "0",
      "balance": "500"
    },
    {
      "details": "Payment Received",
      "date": "20-02-2026",
      "bill": "102",
      "debit": "0",
      "credit": "300",
      "balance": "200"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F9),
      appBar: AppBar(
        title: const Text(
          "School Wise Register",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Top Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Select School",
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 10),

                  /// Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSchool,
                        hint: const Text("-- Select School --"),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: "School 1",
                              child: Text("School 1")),
                          DropdownMenuItem(
                              value: "School 2",
                              child: Text("School 2")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSchool = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Pending Balance
                  if (selectedSchool != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Pending Balance : ",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Text(
                          "200.00",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  /// Buttons Row
                  if (selectedSchool != null)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {},
                            child: const Text("Add Cash"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {},
                            child: const Text("Collect"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {},
                            child: const Text("Print"),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Table Show Only After Selection
            if (selectedSchool != null) ...[

              /// Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text("Details",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Date",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Bill No",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Debit",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Credit",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Balance",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              /// Table Data
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tableData.length,
                itemBuilder: (context, index) {
                  final data = tableData[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey))),
                    child: Row(
                      children: const [
                        Expanded(child: Text("Details", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Bill No", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Debit", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Credit", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Balance", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),

                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

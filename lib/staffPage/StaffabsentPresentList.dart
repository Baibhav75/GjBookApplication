import 'package:flutter/material.dart';

class AttendanceListPage extends StatelessWidget {
  AttendanceListPage({super.key});

  final List<AttendanceItem> attendanceList = [
    AttendanceItem(name: "Rahul", isPresent: true),
    AttendanceItem(name: "Amit", isPresent: true),
    AttendanceItem(name: "Suresh", isPresent: false),
    AttendanceItem(name: "Neha", isPresent: true),
    AttendanceItem(name: "Priya", isPresent: false),
  ];

  @override
  Widget build(BuildContext context) {
    final presentList =
    attendanceList.where((e) => e.isPresent).toList();
    final absentList =
    attendanceList.where((e) => !e.isPresent).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ PRESENT LIST
            _sectionTitle(
              "Present (${presentList.length})",
              Colors.green,
            ),
            ...presentList.map((item) => _attendanceTile(
              item.name,
              true,
            )),

            const SizedBox(height: 20),

            /// ❌ ABSENT LIST
            _sectionTitle(
              "Absent (${absentList.length})",
              Colors.red,
            ),
            ...absentList.map((item) => _attendanceTile(
              item.name,
              false,
            )),
          ],
        ),
      ),

      /// SUBMIT BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Attendance Loaded | Present: ${presentList.length}, Absent: ${absentList.length}",
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(14),
          ),
          child: const Text(
            "Submit Attendance",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  /// 🔹 SECTION TITLE
  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// 🔹 ATTENDANCE TILE
  Widget _attendanceTile(String name, bool isPresent) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPresent ? Colors.green : Colors.red,
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isPresent ? "Present" : "Absent",
          style: TextStyle(
            color: isPresent ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}

/// 🔹 MODEL
class AttendanceItem {
  final String name;
  final bool isPresent;

  AttendanceItem({
    required this.name,
    required this.isPresent,
  });
}

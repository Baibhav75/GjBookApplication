import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class staffhistory extends StatefulWidget {
  @override
  _staffhistoryState createState() => _staffhistoryState();
}

class _staffhistoryState extends State<staffhistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // STATIC ATTENDANCE DATA
  final List<Map<String, dynamic>> attendanceList = [
    {
      "date": DateTime(2025, 10, 25),
      "checkIn": "1:19 PM",
      "checkOut": "1:20 PM",
      "duration": "0 h 0 m",
      "employeeName": "Test1",
      "employeeId": "EMP716890",
      "status": "completed",
      "location": "Capital Icon",
      "checkInLocation": "Sheikhpura",
      "checkOutLocation": "Sheikhpura",
      "checkInCoordinates": "25.1425, 85.8555",
      "checkOutCoordinates": "25.1425, 85.8555"
    }
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(child: Text("Records", style: TextStyle(color: Colors.white))),
            Tab(child: Text("Statistics", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordsTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  // -------------------------------------
  // RECORDS TAB
  // -------------------------------------
  Widget _buildRecordsTab() {
return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _filterDropdown(),
          const SizedBox(height: 10),

          const SizedBox(height: 20),

          ...attendanceList.map((data) => _attendanceCard(data))
        ],
      ),
    );
  }

  // FILTER DROPDOWN
  Widget _filterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),

    );
  }


  // ATTENDANCE CARD
  Widget _attendanceCard(Map<String, dynamic> data) {
    String dateFormatted = DateFormat("EEE, MMM dd, yyyy").format(data["date"]);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 12),
                  const SizedBox(width: 6),
                  Text(dateFormatted,
                      style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),

              Text(data["duration"],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple)),
            ],
          ),

          const SizedBox(height: 5),
          Text("${data['checkIn']} - ${data['checkOut']}",
              style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 20),

          // DETAILS
          _row("Employee Name:", data['employeeName']),
          _row("Employee ID:", data['employeeId']),
          _row("Check-in Time:", data['checkIn']),
          _row("Check-out Time:", data['checkOut']),
          _row("Work Duration:", data['duration']),
          _row("Status:", data['status']),
          _row("Location:", data['location']),
          _row("Check-in Location:", data['checkInLocation']),
          _row("Check-out Location:", data['checkOutLocation']),
          _row("Check-in Coordinates:", data['checkInCoordinates']),
          _row("Check-out Coordinates:", data['checkOutCoordinates']),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text("Delete",
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.info),
                  label: const Text("Details"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ROW BUILDER
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Text(label,
                  style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(
              flex: 5,
              child: Text(value,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
        ],
      ),
    );
  }

  // -------------------------------------
  // STATISTICS TAB
  // -------------------------------------
  Widget _buildStatisticsTab() {
    return const Center(
      child: Text("Statistics Coming Soon...",
          style: TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }
}

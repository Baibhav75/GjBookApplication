import 'package:flutter/material.dart';

class InterviewList extends StatefulWidget {
  const InterviewList({super.key});

  @override
  State<InterviewList> createState() => _InterviewListState();
}

class _InterviewListState extends State<InterviewList> {
  // Animation variables
  double _scale = 1.0;
  double _rotate = 0.0;

  // Dummy data
  final List<Map<String, dynamic>> interviewData = [
    {
      "srNo": 1,
      "name": "Sanjay Pandey",
      "email": "sanjayaim.pandey@gmail.com",
      "mobile": "7668021400",
      "alternate": "7311109944",
      "maritalStatus": "MARRIED",
      "joiningDate": "03-Nov-2025",
      "status": "Pending"
    },
    {
      "srNo": 2,
      "name": "Sujit Shekhar",
      "email": "sujitshekhar1987@gmail.com",
      "mobile": "6388001151",
      "alternate": "9005318853",
      "maritalStatus": "MARRIED",
      "joiningDate": "03-Nov-2025",
      "status": "Pending"
    },
    {
      "srNo": 3,
      "name": "Akhilesh Kumar",
      "email": "indabansh46@gmail.com",
      "mobile": "7565844152",
      "alternate": "7152876001",
      "maritalStatus": "MARRIED",
      "joiningDate": "03-Nov-2025",
      "status": "Pending"
    },
    {
      "srNo": 4,
      "name": "Neelu Chaurasiya",
      "email": "neelubst123@gmail.com",
      "mobile": "7800364626",
      "alternate": "9838910407",
      "maritalStatus": "UNMARRIED",
      "joiningDate": "01-Nov-2025",
      "status": "Pending"
    },
  ];

  final List<String> actions = [
    'View Details',
    'Edit Details',
    'Interview Process',
    'Team Discussion',
    'Document Verification',
    'Selected'
  ];

  VoidCallback? get _refreshData => null;

  // Navigation popup functions
  void _navigateToHome() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Home'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _navigateToDayBook() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Day Book'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToAttendanceHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Attendance History'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // FOOTER WIDGET
  Widget _buildFooter() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterTextButton(
            text: 'Home',
            onPressed: _navigateToHome,
            icon: Icons.home,
            textColor: Colors.blue[700],
          ),
          _buildFooterTextButton(
            text: 'Day Book',
            onPressed: _navigateToDayBook,
            icon: Icons.book,
            textColor: Colors.green[700],
          ),
          _buildFooterTextButton(
            text: 'Attendance',
            onPressed: _navigateToAttendanceHistory,
            icon: Icons.history,
            textColor: Colors.orange[700],
          ),
        ],
      ),
    );
  }

  // ANIMATED FOOTER BUTTON
  Widget _buildFooterTextButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    Color? textColor,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.90),
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
          _rotate += 0.2;
        });
        onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              turns: _rotate,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                size: 22,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Interview List'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // ANIMATED NOTIFICATION ICON
          IconButton(
            icon: AnimatedRotation(
              turns: _rotate,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {
              setState(() {
                _rotate += 0.5;
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),

          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Settings', 'Help', 'Logout'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    headingRowColor:
                    WidgetStateProperty.all(Colors.blue.shade100),
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: const [
                      DataColumn(label: Text('Sr No')),
                      DataColumn(label: Text('Employee Name')),
                      DataColumn(label: Text('Email Id')),
                      DataColumn(label: Text('Mobile No')),
                      DataColumn(label: Text('Alternate No')),
                      DataColumn(label: Text('Marital Status')),
                      DataColumn(label: Text('Joining DateTime')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: interviewData.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item["srNo"].toString())),
                        DataCell(Text(item["name"])),
                        DataCell(Text(item["email"])),
                        DataCell(Text(item["mobile"])),
                        DataCell(Text(item["alternate"])),
                        DataCell(_buildMaritalBadge(item["maritalStatus"])),
                        DataCell(Text(item["joiningDate"])),
                        DataCell(_buildStatusBadge(item["status"])),
                        DataCell(_buildActionButton(item)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // FOOTER
          _buildFooter(),
        ],
      ),
    );
  }

  // BADGES
  Widget _buildMaritalBadge(String status) {
    bool isMarried = status == "MARRIED";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMarried ? Colors.green.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isMarried ? Colors.green : Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ACTION BUTTON
  Widget _buildActionButton(Map<String, dynamic> item) {
    return PopupMenuButton<String>(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item["name"]} → $value selected')),
        );
      },
      itemBuilder: (context) =>
          actions.map((action) => PopupMenuItem(value: action, child: Text(action))).toList(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: const Text(
          'Actions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

void _handlePopupMenuSelection(String value) {}

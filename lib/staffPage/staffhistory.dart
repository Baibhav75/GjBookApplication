import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/Model/attendance_history_model.dart';
import '/Service/attendance_history_service.dart';

/// A page that displays attendance history for a specific staff member
/// 
/// This page requires a [mobileNo] parameter to fetch the attendance records
/// for the corresponding staff member.
class HistoryPage extends StatefulWidget {
  /// The mobile number of the staff member whose attendance history to display
  final String mobileNo;

  const HistoryPage({
    super.key,
    required this.mobileNo,
  });

  @override
  State<HistoryPage> createState() => _StaffHistoryPageState();
}

class _StaffHistoryPageState extends State<HistoryPage> {
  late Future<List<Attendance>> _future;

  @override
  void initState() {
    super.initState();
    // Validate the mobile number before making the API call
    if (widget.mobileNo.isEmpty) {
      // We'll handle this error in the UI
      _future = Future.error(Exception('Mobile number is required'));
    } else {
      _future = AttendanceService.getAttendanceHistory(widget.mobileNo);
    }
  }

  /// Reloads the attendance history data
  Future<void> _reload() async {
    // Validate the mobile number before making the API call
    if (widget.mobileNo.isEmpty) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _future = AttendanceService.getAttendanceHistory(widget.mobileNo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 1,
        title: const Text(
          "Staff Attendance",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Attendance>>(
          future: _future,
          builder: (context, snapshot) {
            // ================= LOADING =================
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading attendance history...'),
                  ],
                ),
              );
            }

            // ================= ERROR =================
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading attendance history',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? [];

            // ================= EMPTY =================
            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history_toggle_off,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No attendance records found',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your attendance history will appear here once you check in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            // ================= LIST =================
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return _attendanceCard(data[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // ================= ATTENDANCE CARD =================

  Widget _attendanceCard(Attendance a) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final timeFmt = DateFormat('hh:mm a');
    final bool completed = a.checkOutTime != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: completed ? Colors.green : Colors.orange,
                  child: Text(
                    a.employeeName.isNotEmpty ? a.employeeName[0] : "?",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    a.employeeName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(
                  label: Text(
                    completed ? "Completed" : "Pending",
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor:
                  completed ? Colors.green : Colors.orange,
                )
              ],
            ),

            const SizedBox(height: 8),
            Text(
              dateFmt.format(a.checkInTime),
              style: TextStyle(color: Colors.grey[600]),
            ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _info("Check-In", timeFmt.format(a.checkInTime)),
                _info(
                  "Check-Out",
                  a.checkOutTime != null
                      ? timeFmt.format(a.checkOutTime!)
                      : "--",
                ),
                _info("Duration", a.workDuration ?? "--"),
              ],
            ),

            if (a.checkInLocation != null ||
                a.checkOutLocation != null) ...[
              const Divider(height: 24),
              if (a.checkInLocation != null)
                _location("Check-In", a.checkInLocation!),
              if (a.checkOutLocation != null)
                _location("Check-Out", a.checkOutLocation!),
            ]
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _location(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on,
              size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$title Location: $value",
              style:
              TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

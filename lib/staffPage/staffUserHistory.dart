import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Model/AllStaffHistory_model.dart';
import '../Service/all_staff_history_service.dart';

class AgentUserHistory extends StatefulWidget {
  final String mobile;
  const AgentUserHistory({super.key, required this.mobile});

  @override
  State<AgentUserHistory> createState() => _AllStaffHistoryPageState();
}

class _AllStaffHistoryPageState extends State<AgentUserHistory> {
  late Future<List<AllStaffHistory>> _future;

  @override
  void initState() {
    super.initState();
    _future =
        AllStaffHistoryService.getAllStaffHistory(mobile: widget.mobile);
  }

  String _format(DateTime? d) =>
      d == null ? "-" : DateFormat("dd MMM yyyy, hh:mm a").format(d);

  Color _statusColor(AllStaffHistory e) =>
      e.checkOutTime == null ? Colors.orange : Colors.green;

  String _workDuration(AllStaffHistory e) =>
      e.workDuration ?? "In Progress";

  // ================= IMAGE =================
  Widget _image(String? img) {
    if (img == null || img.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("No Image Available"),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        "https://g17bookworld.com$img",
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Center(child: Text("Image load failed")),
      ),
    );
  }

  // ================= DETAIL =================
  void _openDetail(AllStaffHistory e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 6,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                e.employeeName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("Mobile: ${e.mobile}"),

              const Divider(height: 30),

              _info("Check-In Time", _format(e.checkInTime)),
              _info("Check-Out Time", _format(e.checkOutTime)),
              _info("Work Duration", e.workDuration),
              _info("Check-In Location", e.checkInLocation),
              _info("Check-Out Location", e.checkOutLocation),

              const SizedBox(height: 16),
              const Text("Check-In Image",
                  style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _image(e.checkInImage),

              const SizedBox(height: 16),
              const Text("Check-Out Image",
                  style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _image(e.checkOutImage),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value ?? "-", style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ================= MAIN =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "All Staff Attendance",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: FutureBuilder<List<AllStaffHistory>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }

          final list = snap.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text("No attendance found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final e = list[i];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _openDetail(e),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                          _statusColor(e).withOpacity(.15),
                          child: Icon(Icons.person,
                              color: _statusColor(e)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.employeeName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Check-In: ${_format(e.checkInTime)}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Work: ${_workDuration(e)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: e.workDuration == null
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

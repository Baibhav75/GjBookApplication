import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data Models for Type Safety
class StaffRecord {
  final String id;
  final String name;
  final String role;
  final String time;
  final AttendanceStatus status;

  StaffRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.time,
    this.status = AttendanceStatus.pending,
  });
}

enum AttendanceStatus { pending, accepted, rejected }

// Constants
class AppConstants {
  static const Color primaryColor = Colors.blue;
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;

  static const Color acceptedColor = Colors.green;
  static const Color rejectedColor = Colors.red;
  static const Color pendingColor = Colors.orange;

  static const List<Tab> attendanceTabs = [
    Tab(text: "Today"),
    Tab(text: "Weeks"),
    Tab(text: "Months"),
    Tab(text: "All"),
  ];
}

class staffhistory extends StatefulWidget {
  const staffhistory({super.key});

  @override
  State<staffhistory> createState() => _staffhistoryState();
}

class _staffhistoryState extends State<staffhistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<StaffRecord> _todayRecords = [
    StaffRecord(
      id: "1",
      name: "Shilpi Sharma",
      role: "Sales Executive",
      time: "10:34 AM",
    ),
    StaffRecord(
      id: "2",
      name: "Abdul Kadir",
      role: "Sales Executive",
      time: "10:25 AM",
    ),
    StaffRecord(
      id: "3",
      name: "Rahul Kumar Jha",
      role: "Sales Executive",
      time: "10:25 AM",
    ),
    StaffRecord(
      id: "4",
      name: "Aman Yadav",
      role: "Sales Executive",
      time: "10:25 AM",
      status: AttendanceStatus.accepted,
    ),
    StaffRecord(
      id: "5",
      name: "Seema Singh",
      role: "Sales Executive",
      time: "10:24 AM",
      status: AttendanceStatus.rejected,
    ),
    StaffRecord(
      id: "6",
      name: "Chanchal Verma",
      role: "Sales Executive",
      time: "10:18 AM",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayList(),
          _buildPlaceholderTab("Week-wise attendance data"),
          _buildPlaceholderTab("Month-wise attendance data"),
          _buildPlaceholderTab("All attendance records"),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      elevation: 2,
      title: const Text(
        "Attendance Records",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: AppConstants.attendanceTabs,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterOptions,
          tooltip: "Filter Records",
        ),
      ],
    );
  }

  Widget _buildTodayList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _todayRecords.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _todayRecords.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = _todayRecords[index];
                return StaffRecordCard(
                  record: record,
                  onTap: () => _navigateToDetail(record),
                );
              },
            ),
    );
  }

  Widget _buildPlaceholderTab(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "Coming soon...",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            "No attendance records today",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Check back later for updates",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data refreshed"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Filter Records",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...AttendanceStatus.values.map(
              (status) => ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(status),
                  ),
                ),
                title: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontWeight: status == AttendanceStatus.pending
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  _todayRecords
                      .where((r) => r.status == status)
                      .length
                      .toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _filterByStatus(status);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _filterByStatus(AttendanceStatus status) {
    // Implement filtering logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Filtered by: ${_getStatusText(status)}")),
    );
  }

  void _navigateToDetail(StaffRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffDetailScreen(
          record: record,
          onStatusUpdated: (updatedRecord) {
            _updateRecordStatus(updatedRecord);
          },
        ),
      ),
    );
  }

  void _updateRecordStatus(StaffRecord updatedRecord) {
    setState(() {
      final index = _todayRecords.indexWhere((r) => r.id == updatedRecord.id);
      if (index != -1) {
        _todayRecords[index] = updatedRecord;
      }
    });
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.accepted:
        return AppConstants.acceptedColor;
      case AttendanceStatus.rejected:
        return AppConstants.rejectedColor;
      case AttendanceStatus.pending:
        return AppConstants.pendingColor;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.accepted:
        return "Accepted";
      case AttendanceStatus.rejected:
        return "Rejected";
      case AttendanceStatus.pending:
        return "Pending Review";
    }
  }
}

// Staff Record Card Widget
class StaffRecordCard extends StatelessWidget {
  final StaffRecord record;
  final VoidCallback onTap;

  const StaffRecordCard({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              _buildInfo(),
              const Spacer(),
              _buildStatusIndicator(),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: _getStatusColor(record.status).withOpacity(0.1),
      child: Text(
        record.name[0],
        style: TextStyle(
          color: _getStatusColor(record.status),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            record.role,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                record.time,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(record.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(record.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(record.status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(record.status),
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.accepted:
        return Colors.green;
      case AttendanceStatus.rejected:
        return Colors.red;
      case AttendanceStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.accepted:
        return "Accepted";
      case AttendanceStatus.rejected:
        return "Rejected";
      case AttendanceStatus.pending:
        return "Pending";
    }
  }
}

// Staff Detail Screen with Accept/Reject Functionality
class StaffDetailScreen extends StatefulWidget {
  final StaffRecord record;
  final Function(StaffRecord) onStatusUpdated;

  const StaffDetailScreen({
    super.key,
    required this.record,
    required this.onStatusUpdated,
  });

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  late StaffRecord _currentRecord;
  bool _isSubmitting = false;
  String? _rejectionReason;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.record;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildAttendanceCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            if (_currentRecord.status == AttendanceStatus.rejected &&
                _rejectionReason != null) ...[
              const SizedBox(height: 16),
              _buildRejectionReasonCard(),
            ],
            const SizedBox(height: 32),
            _buildAnalyticsSection(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      elevation: 0,
      title: Text(
        "Staff Details",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareDetails,
          tooltip: "Share Details",
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: _getStatusColor().withOpacity(0.1),
            child: Text(
              _currentRecord.name[0],
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentRecord.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentRecord.role,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor()),
            ),
            child: Text(
              _getStatusText(),
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Attendance Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.access_time,
              label: "Check-in Time",
              value: _currentRecord.time,
              color: Colors.blue,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: "Date",
              value: DateFormat("dd MMMM yyyy").format(DateTime.now()),
              color: Colors.green,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.location_on,
              label: "Location",
              value: "Office - Floor 2",
              color: Colors.purple,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.devices,
              label: "Device",
              value: "Mobile App",
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_currentRecord.status != AttendanceStatus.pending) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              _currentRecord.status == AttendanceStatus.accepted
                  ? "✅ Attendance Accepted"
                  : "❌ Attendance Rejected",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Review Attendance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Approve or reject this attendance record",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    text: "Reject",
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: _showRejectionDialog,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    text: "Accept",
                    icon: Icons.check,
                    color: Colors.green,
                    onPressed: _acceptAttendance,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildRejectionReasonCard() {
    return Card(
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rejection Reason",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _rejectionReason!,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Attendance Analytics",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildAnalyticsCard(
              title: "This Month",
              value: "22/26",
              subtitle: "Working Days",
              color: Colors.blue,
              icon: Icons.calendar_month,
            ),
            _buildAnalyticsCard(
              title: "On Time %",
              value: "92%",
              subtitle: "Punctuality",
              color: Colors.green,
              icon: Icons.timer,
            ),
            _buildAnalyticsCard(
              title: "Last Week",
              value: "5/5",
              subtitle: "Full Attendance",
              color: Colors.purple,
              icon: Icons.bar_chart,
            ),
            _buildAnalyticsCard(
              title: "Avg. Time",
              value: "9:42 AM",
              subtitle: "Check-in",
              color: Colors.orange,
              icon: Icons.access_time,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_currentRecord.status) {
      case AttendanceStatus.accepted:
        return Colors.green;
      case AttendanceStatus.rejected:
        return Colors.red;
      case AttendanceStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusText() {
    switch (_currentRecord.status) {
      case AttendanceStatus.accepted:
        return "Attendance Accepted";
      case AttendanceStatus.rejected:
        return "Attendance Rejected";
      case AttendanceStatus.pending:
        return "Pending Review";
    }
  }

  void _acceptAttendance() async {
    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final updatedRecord = StaffRecord(
      id: _currentRecord.id,
      name: _currentRecord.name,
      role: _currentRecord.role,
      time: _currentRecord.time,
      status: AttendanceStatus.accepted,
    );

    widget.onStatusUpdated(updatedRecord);

    if (mounted) {
      setState(() {
        _currentRecord = updatedRecord;
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance accepted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Attendance"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Please provide a reason for rejection:"),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter reason...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _rejectAttendance,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  void _rejectAttendance() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a rejection reason"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final updatedRecord = StaffRecord(
      id: _currentRecord.id,
      name: _currentRecord.name,
      role: _currentRecord.role,
      time: _currentRecord.time,
      status: AttendanceStatus.rejected,
    );

    widget.onStatusUpdated(updatedRecord);

    if (mounted) {
      setState(() {
        _currentRecord = updatedRecord;
        _rejectionReason = _reasonController.text;
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance rejected!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareDetails() {
    // Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Sharing details...")));
  }
}

import 'package:flutter/material.dart';
import '/Model/HrmViewEmplyeeModel.dart';
import '../service/HrmViewEmployee_service.dart';

class HRMViewEmployee extends StatefulWidget {
  const HRMViewEmployee({Key? key}) : super(key: key);

  @override
  State<HRMViewEmployee> createState() => _HRMViewEmployeeState();
}

class _HRMViewEmployeeState extends State<HRMViewEmployee> {
  final HrmViewEmployeeService _employeeService = HrmViewEmployeeService();
  late Future<HrmViewEmployeeModel?> _employeesFuture;
  List<EmployeeList> _employees = [];

  VoidCallback? get _refreshData => null;

  @override
  void initState() {
    super.initState();
    _employeesFuture = _fetchEmployees();
  }

  Future<HrmViewEmployeeModel?> _fetchEmployees() async {
    try {
      final employees = await _employeeService.fetchEmployees();
      if (employees != null && employees.employeeList != null) {
        setState(() {
          _employees = employees.employeeList!;
        });
        print('Fetched ${_employees.length} employees'); // Debug print
      } else {
        print('No employees found in response');
      }
      return employees;
    } catch (e) {
      print('Error in _fetchEmployees: $e');
      return null;
    }
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.toLowerCase().contains('active')) return Colors.green;
    if (status.toLowerCase().contains('complete')) return Colors.green;
    if (status.toLowerCase().contains('verified')) return Colors.green;
    return Colors.red;
  }

  String getStatusText(EmployeeList employee) {
    // Use policeverification or salaryConfirmation as status indicator
    return employee.policeverification ??
        employee.salaryConfirmation ??
        'Unknown';
  }

  Color getButtonColor(String text) {
    switch (text) {
      case 'View':
        return Colors.blue;
      case 'Edit':
        return Colors.orange;
      case 'Activate':
        return Colors.green;
      case 'Deactivate':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getActionButtonText(EmployeeList employee) {
    final status = getStatusText(employee);
    final statusLower = status.toLowerCase();
    return statusLower.contains('active') ||
        statusLower.contains('complete') ||
        statusLower.contains('verified')
        ? 'Deactivate'
        : 'Activate';
  }

  // 🔽🔽🔽 FOOTER BUTTON METHODS - ADD THESE 🔽🔽🔽

  void _navigateToHome() {
    // TODO: Implement navigation to Home screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Home'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToDayBook() {
    // TODO: Implement navigation to Day Book screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Day Book'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToAttendanceHistory() {
    // TODO: Implement navigation to Attendance History screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Attendance History'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

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

  Widget _buildFooterTextButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: textColor ?? Colors.blue[700],
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔼🔼🔼 FOOTER BUTTON METHODS - END 🔼🔼🔼

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Employee'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: ArgumentError.notNull,
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white, //
            ),
            onPressed: _refreshData,
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              _handlePopupMenuSelection(value);
            },
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Settings', 'Help', 'Logout'}.map((String choice) {
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
            child: FutureBuilder<HrmViewEmployeeModel?>(
              future: _employeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _employeesFuture = _fetchEmployees();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (_employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No employees found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${snapshot.data?.status ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Message: ${snapshot.data?.message ?? 'No message'}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _employeesFuture = _fetchEmployees();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      // ✅ CHANGE: Added Container with constraints
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height - 200,
                      ),
                      child: SingleChildScrollView(
                        // ✅ CHANGE: Made both horizontal and vertical scroll
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          // ✅ ADDED: Vertical scrolling
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.lightBlue[100]!,
                            ),
                            columns: const [
                              DataColumn(label: Text('Sr No')),
                              DataColumn(label: Text('Employee Name')),
                              DataColumn(label: Text('Contact No')),
                              DataColumn(label: Text('Department')),
                              DataColumn(label: Text('Date of Joining')),
                              DataColumn(label: Text('Designation')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: _employees.asMap().entries.map((entry) {
                              final index = entry.key;
                              final employee = entry.value;
                              final statusText = getStatusText(employee);
                              final actionButtonText = getActionButtonText(employee);

                              return DataRow(cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(employee.employeeName ?? 'N/A')),
                                DataCell(Text(employee.contactNumber ?? 'N/A')),
                                DataCell(Text(employee.departmentName ?? 'N/A')),
                                DataCell(Text(employee.dateOfJoining ?? 'N/A')),
                                DataCell(Text(employee.designation ?? 'N/A')),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(statusText),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                )),
                                DataCell(Row(
                                  children: [
                                    _buildActionButton('View', employee),
                                    const SizedBox(width: 4),
                                    _buildActionButton('Edit', employee),
                                    const SizedBox(width: 4),
                                    _buildActionButton(actionButtonText, employee),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔽🔽🔽 ADD FOOTER HERE 🔽🔽🔽
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, EmployeeList employee) {
    return GestureDetector(
      onTap: () {
        _handleAction(text, employee);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: getButtonColor(text),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  void _handleAction(String action, EmployeeList employee) {
    switch (action) {
      case 'View':
        _viewEmployee(employee);
        break;
      case 'Edit':
        _editEmployee(employee);
        break;
      case 'Activate':
      case 'Deactivate':
        _toggleEmployeeStatus(employee, action);
        break;
    }
  }

  void _viewEmployee(EmployeeList employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${employee.employeeName ?? 'Employee'} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', employee.employeeName),
              _buildDetailRow('Contact', employee.contactNumber),
              _buildDetailRow('Email', employee.emailId),
              _buildDetailRow('Department', employee.departmentName),
              _buildDetailRow('Designation', employee.designation),
              _buildDetailRow('Date of Joining', employee.dateOfJoining),
              _buildDetailRow('Employee Type', employee.employeeType),
              _buildDetailRow('Salary', employee.salaryFormatted),
              _buildDetailRow('Gender', employee.gender),
              _buildDetailRow('Martial Status', employee.martialStatus),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  void _editEmployee(EmployeeList employee) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${employee.employeeName}'),
      ),
    );
  }

  void _toggleEmployeeStatus(EmployeeList employee, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action ${employee.employeeName}'),
      ),
    );
  }

  void _handlePopupMenuSelection(String value) {}
}
import 'package:flutter/material.dart';
import '/Model/HrmViewEmplyeeModel.dart';
import '../service/HrmViewEmployee_service.dart';

/// 🔹 FILTER TYPE
enum EmployeeFilter { all, active, deactive }

class HRMViewEmployee extends StatefulWidget {
  const HRMViewEmployee({Key? key}) : super(key: key);

  @override
  State<HRMViewEmployee> createState() => _HRMViewEmployeeState();
}

class _HRMViewEmployeeState extends State<HRMViewEmployee> {
  final HrmViewEmployeeService _employeeService = HrmViewEmployeeService();

  late Future<HrmViewEmployeeModel?> _employeesFuture;
  List<EmployeeList> _employees = [];

  EmployeeFilter _currentFilter = EmployeeFilter.all;

  @override
  void initState() {
    super.initState();
    _employeesFuture = _fetchEmployees();
  }

  /// 🔹 FETCH EMPLOYEES
  Future<HrmViewEmployeeModel?> _fetchEmployees() async {
    try {
      final response = await _employeeService.fetchEmployees();
      if (response != null && response.employeeList != null) {
        setState(() {
          // ❌ Hide null Status
          _employees = response.employeeList!
              .where((e) => e.statuss != null)
              .toList();
        });
      }
      return response;
    } catch (e) {
      debugPrint('Error fetching employees: $e');
      return null;
    }
  }

  /// 🔹 FILTERED LIST
  List<EmployeeList> get _filteredEmployees {
    switch (_currentFilter) {
      case EmployeeFilter.active:
        return _employees.where((e) => e.statuss == true).toList();
      case EmployeeFilter.deactive:
        return _employees.where((e) => e.statuss == false).toList();
      case EmployeeFilter.all:
      default:
        return _employees;
    }
  }

  /// 🔹 FILTER UI
  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _currentFilter == EmployeeFilter.all,
            onSelected: (_) {
              setState(() {
                _currentFilter = EmployeeFilter.all;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Active'),
            selectedColor: Colors.green[200],
            selected: _currentFilter == EmployeeFilter.active,
            onSelected: (_) {
              setState(() {
                _currentFilter = EmployeeFilter.active;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Deactive'),
            selectedColor: Colors.red[200],
            selected: _currentFilter == EmployeeFilter.deactive,
            onSelected: (_) {
              setState(() {
                _currentFilter = EmployeeFilter.deactive;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Employee'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _employeesFuture = _fetchEmployees();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: FutureBuilder<HrmViewEmployeeModel?>(
              future: _employeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_filteredEmployees.isEmpty) {
                  return const Center(child: Text('No employees found'));
                }

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.lightBlue[100],
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
                        rows: _filteredEmployees.asMap().entries.map((entry) {
                          final index = entry.key;
                          final employee = entry.value;
                          final bool status = employee.statuss!;

                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(employee.employeeName ?? 'N/A')),
                            DataCell(Text(employee.contactNumber ?? 'N/A')),
                            DataCell(Text(employee.departmentName ?? 'N/A')),
                            DataCell(Text(employee.dateOfJoining ?? 'N/A')),
                            DataCell(Text(employee.designation ?? 'N/A')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status ? 'Active' : 'Deactive',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  _actionButton('View', Colors.blue, employee),
                                  const SizedBox(width: 8),
                                  _actionButton('Edit', Colors.orange, employee),
                                  // Removed Activate/Deactivate button
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 ACTION BUTTON
  Widget _actionButton(
      String text, Color color, EmployeeList employee) {
    return GestureDetector(
      onTap: () => _handleAction(text, employee),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// 🔹 ACTION HANDLER
  void _handleAction(String action, EmployeeList employee) {
    if (action == 'View') {
      _showEmployeeDetails(employee);
    } else if (action == 'Edit') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Edit ${employee.employeeName}')),
      );
      // TODO: Implement edit functionality
    }
  }

  /// 🔹 SHOW EMPLOYEE DETAILS DIALOG
  void _showEmployeeDetails(EmployeeList employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Employee Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              _buildDetailRow('Name:', employee.employeeName),
              _buildDetailRow('Contact:', employee.contactNumber),

              _buildDetailRow('Department:', employee.departmentName),
              _buildDetailRow('Designation:', employee.designation),
              _buildDetailRow('Date of Joining:', employee.dateOfJoining),
              _buildDetailRow('Date of Birth:', employee.dateOfBirth),
              _buildDetailRow('Gender:', employee.gender),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: employee.statuss! ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  employee.statuss! ? 'Active' : 'Deactive',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// 🔹 BUILD DETAIL ROW
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
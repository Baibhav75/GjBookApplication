import 'package:flutter/material.dart';
import '../Model/assigned_school_model.dart';
import '../Service/assigned_school_service.dart';
import 'CollectAmountPage.dart';

class AssignedSchoolScreen extends StatefulWidget {
  final String employeeId;

  const AssignedSchoolScreen({super.key, required this.employeeId});

  @override
  State<AssignedSchoolScreen> createState() => _AssignedSchoolScreenState();
}

class _AssignedSchoolScreenState extends State<AssignedSchoolScreen> {
  final AssignedSchoolService _service = AssignedSchoolService();
  RecovertAssignedSchoolModel? _model;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data =
      await _service.fetchAssignedSchools(widget.employeeId);

      if (!mounted) return;

      if (data == null || data.status?.toLowerCase() != "success") {
        setState(() {
          _isLoading = false;
          _errorMessage = data?.message ?? "Failed to load data";
        });
      } else {
        setState(() {
          _model = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Something went wrong!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F9),
      appBar: AppBar(
        title: const Text(
          "Assigned Schools",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSchools,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 200),
          Center(
            child: Column(
              children: [
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _fetchSchools,
                  child: const Text("Retry"),
                )
              ],
            ),
          )
        ],
      );
    }

    final schools = _model?.data?.schools ?? [];

    if (schools.isEmpty) {
      return const Center(child: Text("No schools assigned"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: schools.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final school = schools[index];
        return SchoolCard(
          schoolId: school.schoolId ?? "",
          schoolName: school.schoolName ?? "N/A",
          address: school.schoolAddress ?? "N/A",
          contactName: school.principalName ?? "N/A",
          phone: school.principalMoNo ?? "N/A",
          dueAmount: school.dueAmount ?? 0,
        );
      },
    );
  }
}

class SchoolCard extends StatelessWidget {
  final String schoolId;
  final String schoolName;
  final String address;
  final String contactName;
  final String phone;
  final int dueAmount;

  const SchoolCard({
    super.key,
    required this.schoolId,
    required this.schoolName,
    required this.address,
    required this.contactName,
    required this.phone,
    required this.dueAmount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollectAmountPage(
              schoolId: schoolId,
              schoolName: schoolName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// School Name + Due Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    schoolName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0D2B6B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Due ₹ $dueAmount",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 25),

            /// Address
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(address)),
              ],
            ),

            const SizedBox(height: 12),

            /// Contact
            Row(
              children: [
                const Icon(Icons.phone, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text("$contactName ($phone)")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
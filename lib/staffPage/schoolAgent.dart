import 'package:flutter/material.dart';
import '../model/school_agent_model.dart';
import '../service/school_agent_service.dart';

class SchoolAgentPage extends StatefulWidget {
  const SchoolAgentPage({super.key});

  @override
  State<SchoolAgentPage> createState() => _SchoolAgentPageState();
}

class _SchoolAgentPageState extends State<SchoolAgentPage> {
  final _agentIdCtl = TextEditingController();
  final _schoolNameCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  final _districtCtl = TextEditingController();
  final _tahsilCtl = TextEditingController();
  final _blockCtl = TextEditingController();
  final _villageCtl = TextEditingController();
  final _mobileCtl = TextEditingController();
  final _principalNameCtl = TextEditingController();
  final _principalMobileCtl = TextEditingController();
  final _totalStudentsCtl = TextEditingController();

  final SchoolAgentService _service = SchoolAgentService();

  List<SchoolAgent> _schools = [];
  SchoolAgent? _selectedSchool;
  bool _loading = false;

  Future<void> _loadSchools(String agentId) async {
    if (agentId.length < 5) return;

    setState(() => _loading = true);
    try {
      _schools = await _service.fetchSchoolsByAgent(agentId);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _loading = false);
  }

  void _fillSchoolData(SchoolAgent s) {
    _schoolNameCtl.text = s.schoolName;
    _addressCtl.text = s.schoolAddress;
    _districtCtl.text = s.district;
    _tahsilCtl.text = s.tahsil;
    _blockCtl.text = s.block;
    _villageCtl.text = s.village;
    _mobileCtl.text = s.mobile;
    _principalNameCtl.text = s.principalName;
    _principalMobileCtl.text = s.principalMobile;
    _totalStudentsCtl.text = s.totalStudents.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("School Agent")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _agentIdCtl,
              decoration: const InputDecoration(
                labelText: "AgentStaff ID",
                border: OutlineInputBorder(),
              ),
              onChanged: _loadSchools,
            ),

            const SizedBox(height: 12),

            if (_loading) const CircularProgressIndicator(),

            if (_schools.isNotEmpty)
              DropdownButtonFormField<SchoolAgent>(
                decoration: const InputDecoration(
                  labelText: "Select School",
                  border: OutlineInputBorder(),
                ),
                items: _schools
                    .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.schoolName),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSchool = val);
                    _fillSchoolData(val);
                  }
                },
              ),

            const SizedBox(height: 20),

            _buildText("School Name", _schoolNameCtl),
            _buildText("Address", _addressCtl),
            _buildText("District", _districtCtl),
            _buildText("Tahsil", _tahsilCtl),
            _buildText("Block", _blockCtl),
            _buildText("Village", _villageCtl),
            _buildText("Mobile", _mobileCtl),
            _buildText("Principal Name", _principalNameCtl),
            _buildText("Principal Mobile", _principalMobileCtl),
            _buildText("Total Students", _totalStudentsCtl),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

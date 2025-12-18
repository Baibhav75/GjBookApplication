import 'package:flutter/material.dart';
import '../Model/schoolByAgent_model.dart';
import '../Service/school_by_agent_service.dart';
import 'school_detail_page.dart';

class AddSchoolSurveyPage extends StatefulWidget {
  const AddSchoolSurveyPage({Key? key}) : super(key: key);

  @override
  State<AddSchoolSurveyPage> createState() => _AddSchoolSurveyPageState();
}

class _AddSchoolSurveyPageState extends State<AddSchoolSurveyPage> {
  final TextEditingController _searchController = TextEditingController();
  final SchoolByAgentService _service = SchoolByAgentService();

  List<Data> _allSchools = [];
  List<Data> _filteredSchools = [];

  bool _isLoading = true;
  String agentId = "GJ12345678"; // 🔴 Dynamic later

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _searchController.addListener(_filterSchools);
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);

    try {
      final schools = await _service.fetchSchoolsByAgent(agentId);
      _allSchools = schools;
      _filteredSchools = schools;
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _filterSchools() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredSchools = _allSchools.where((school) {
        return (school.schoolName ?? "").toLowerCase().contains(query) ||
            (school.principalName ?? "").toLowerCase().contains(query) ||
            (school.prabandhakName ?? "").toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C4DFF),
        title: const Text("Survey List",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSchools,
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildHeaderRow(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildSurveyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search school, principal or prabandhak...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF7C4DFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text("No", style: _headerStyle)),
          Expanded(child: Text("School Name", style: _headerStyle)),
          SizedBox(width: 120, child: Text("Actions", style: _headerStyle)),
        ],
      ),
    );
  }

  Widget _buildSurveyList() {
    if (_filteredSchools.isEmpty) {
      return const Center(child: Text("No schools found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredSchools.length,
      itemBuilder: (context, index) {
        final school = _filteredSchools[index];
        final bool isGrey = index.isOdd;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isGrey ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text("${index + 1}",
                    style: const TextStyle(
                        color: Color(0xFF7C4DFF),
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Text(
                  school.schoolName ?? "-",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(
                  Icons.remove_red_eye,
                  size: 18,
                  color: Colors.white, // ✅ icon white
                ),
                label: const Text(
                  "View",
                  style: TextStyle(color: Colors.white), // 👈 text white
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SchoolDetailPage(school: school),
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}

const TextStyle _headerStyle =
TextStyle(color: Colors.white, fontWeight: FontWeight.w600);

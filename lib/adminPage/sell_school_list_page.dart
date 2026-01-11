import 'package:flutter/material.dart';
import '../Model/sell_school_list_model.dart';
import '../Service/sell_school_list_service.dart';

/// =======================================================
/// 🏫 SELL SCHOOL LIST PAGE
/// =======================================================
class SellSchoolListPage extends StatefulWidget {
  const SellSchoolListPage({Key? key}) : super(key: key);

  @override
  State<SellSchoolListPage> createState() => _SellSchoolListPageState();
}

class _SellSchoolListPageState extends State<SellSchoolListPage> {
  late Future<SellSchoolListResponse> _future;
  String search = '';

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  /// 🔄 LOAD / REFRESH DATA
  void _loadSchools() {
    setState(() {
      _future = SellSchoolListService.fetchSchools();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C4DFF),
        title: const Text(
          "Survey School List",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSchools, // ✅ FIXED
          ),
        ],
      ),
      body: Column(
        children: [
          _searchBar(),
          _tableHeader(),
          Expanded(
            child: FutureBuilder<SellSchoolListResponse>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(
                    child: Text("Failed to load school list"),
                  );
                }

                final schools = snapshot.data!.schools.where((s) {
                  return s.schoolName
                      .toLowerCase()
                      .contains(search.toLowerCase()) ||
                      s.principalName
                          .toLowerCase()
                          .contains(search.toLowerCase()) ||
                      s.ownerName
                          .toLowerCase()
                          .contains(search.toLowerCase());
                }).toList();

                if (schools.isEmpty) {
                  return const Center(child: Text("No schools found"));
                }

                return ListView.builder(
                  itemCount: schools.length,
                  itemBuilder: (context, index) {
                    return _schoolRow(index + 1, schools[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔍 SEARCH BAR
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (v) => setState(() => search = v),
        decoration: InputDecoration(
          hintText: "Search school, principal or owner...",
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

  // 📊 TABLE HEADER
  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.deepPurple,
      child: const Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              "No",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              "School Name",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "Actions",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 🏫 SCHOOL ROW
  Widget _schoolRow(int no, SellSchool school) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              no.toString(),
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              school.schoolName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.remove_red_eye, size: 18),
            label: const Text(
              "View",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white, // ✅ icon + text white
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SchoolDetailPage(school: school),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// 📋 SCHOOL DETAIL PAGE (IN SAME FILE)
/// =======================================================
class SchoolDetailPage extends StatelessWidget {
  final SellSchool school;

  const SchoolDetailPage({Key? key, required this.school}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = school.toMap(); // 🔥 AUTO ALL FIELDS

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white), // ✅ back arrow white
        title: const Text(
          "School Full Detail",
          style: TextStyle(
            color: Colors.white, // ✅ title white
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final key = data.keys.elementAt(index);
          final value = data[key];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                key,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              subtitle: Text(
                value == null || value.toString().isEmpty
                    ? "N/A"
                    : value.toString(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}

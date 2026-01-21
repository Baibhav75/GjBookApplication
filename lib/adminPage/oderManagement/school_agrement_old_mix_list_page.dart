import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Service/school_agrement_old_mix_service.dart';
import '/Model/school_agrement_old_mix_model.dart';

class SchoolAgrementOldMixListPage extends StatefulWidget {
  const SchoolAgrementOldMixListPage({super.key});

  @override
  State<SchoolAgrementOldMixListPage> createState() =>
      _SchoolAgrementOldMixListPageState();
}

class _SchoolAgrementOldMixListPageState
    extends State<SchoolAgrementOldMixListPage> {
  late Future<List<SchoolAgrementOldMix>> _future;

  @override
  void initState() {
    super.initState();
    _future = SchoolAgrementOldMixService().fetchList(); // ✅ FIXED
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'School Agreement Old Mix Report',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<SchoolAgrementOldMix>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(child: Text('No records found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _buildCard(list[index], index + 1);
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(SchoolAgrementOldMix item, int index) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF6B46C1),
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.schoolName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _row('Created On', _formatDate(item.createDate)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(
                  label: 'Agreement',
                  icon: Icons.picture_as_pdf,
                  url: item.agrementImage,
                ),
                const SizedBox(width: 8),
                _actionButton(
                  label: 'Old Mix',
                  icon: Icons.picture_as_pdf,
                  url: item.oldMixImage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required String url,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      onPressed: () => _openFile(url),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

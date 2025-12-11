// pages/survey_detail.dart
import 'package:flutter/material.dart';
import '/Model/survey_model.dart';

class SurveyDetail extends StatelessWidget {
  final SchoolData school;

  const SurveyDetail({Key? key, required this.school}) : super(key: key);

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value ?? '-', style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white), // ← white icons
        title: Text(
          school.schoolName ?? 'School Detail',
          style: const TextStyle(color: Colors.white),       // ← white text
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (school.schoolPhoto != null)
                  SizedBox(
                    height: 160,
                    child: school.schoolPhoto!.startsWith('/')
                        ? Image.network('https://gj.realhomes.co.in${school.schoolPhoto}', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())
                        : Image.network(school.schoolPhoto!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                  ),
                const SizedBox(height: 12),
                _row('School Name', school.schoolName),
                _row('Address', school.schoolAddress),
                _row('District', school.district),
                _row('Tahsil', school.tahsil),
                _row('Area Type', school.areaType),
                _row('Prabandhak', school.prabandhakName),
                _row('Prabandhak Mobile', school.prabandhakMobile),
                _row('Principal', school.principalName),
                _row('Principal Mobile', school.principalMobile),
                _row('Established Year', school.schoolEstablishYear?.toString()),
                _row('Board', school.boardAffiliation),
                _row('Total Students', school.allTotal?.toString()),
                _row('AgentStaff', school.agentName),
                _row('Account Detail', school.accountDetail),
                _row('Created Date', school.createdDate),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

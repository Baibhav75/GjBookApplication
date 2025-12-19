import 'package:bookworld/staffPage/schoolAgent.dart';
import 'package:flutter/material.dart';
import '../Model/schoolByAgent_model.dart';
import 'add_school_survey_page.dart';

class SchoolDetailPage extends StatelessWidget {
  final Data school;

  const SchoolDetailPage({Key? key, required this.school}) : super(key: key);

  // reusable row
  Widget _infoRow(String title, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7C4DFF),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C4DFF),

        iconTheme: const IconThemeData(
          color: Colors.white, // ✅ back(pop) icon white
        ),

        title: Text(
          school.schoolName ?? "School Detail",
          style: const TextStyle(color: Colors.white),
        ),
      ),

      // ✅ ADD THIS BLOCK (EDIT BUTTON)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              "Edit School",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => schoolAgent(
                    agentId: school.agentId, // Pass the agent ID to the schoolAgent page
                  ),
                ),
              );
            },

          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- BASIC INFO ----------------
            _sectionTitle("Basic Information"),
            _infoRow("School Name", school.schoolName),
            _infoRow("Address", school.schoolAddress),
            _infoRow("District", school.district),
            _infoRow("Tahsil", school.tahsil),
            _infoRow("Block", school.block),
            _infoRow("Village", school.village),
            _infoRow("Established Year", school.schoolEstablishYear),
            _infoRow("School Type", school.schoolType),
            _infoRow("School Medium", school.schoolMedium),
            _infoRow("Board", school.boardAffiliation),
            _infoRow("Grade", school.schoolGrade),

            // ---------------- CONTACT INFO ----------------
            _sectionTitle("Contact Details"),
            _infoRow("School Mobile", school.mobile),
            _infoRow("Principal Name", school.principalName),
            _infoRow("Principal Mobile", school.principalMobile),
            _infoRow("Principal Email", school.principalEmailId),
            _infoRow("Principal Address", school.principalHouseAddress),

            _infoRow("Prabandhak Name", school.prabandhakName),
            _infoRow("Prabandhak Mobile", school.prabandhakMobile),
            _infoRow("Prabandhak Address", school.prabandhakAddress),

            // ---------------- OWNER / ADMIN ----------------
            _sectionTitle("Owner & Admin"),
            _infoRow("School Owner", school.schoolOwnerName),
            _infoRow("Owner Address", school.schoolOwnerHouseAddress),
            _infoRow("Owner Email", school.schoolOwnerEmailId),

            _infoRow("Accountant Name", school.accountantName),
            _infoRow("Accountant Number", school.accountantNumber),
            _infoRow("Admin Name", school.schoolAdminName),
            _infoRow("Admin Number", school.schoolAdminNumber),

            // ---------------- STUDENT STRENGTH ----------------
            _sectionTitle("Student Strength"),
            _infoRow("Nursery", school.nursary),
            _infoRow("LKG", school.lKG),
            _infoRow("UKG", school.uKG),
            _infoRow("Class 1", school.class1),
            _infoRow("Class 2", school.class2),
            _infoRow("Class 3", school.class3),
            _infoRow("Class 4", school.class4),
            _infoRow("Class 5", school.class5),
            _infoRow("Class 6", school.class6),
            _infoRow("Class 7", school.class7),
            _infoRow("Class 8", school.class8),
            _infoRow("Class 9", school.class9),
            _infoRow("Class 10", school.class10),
            _infoRow("Class 11", school.class11),
            _infoRow("Class 12", school.class12),
            _infoRow("Total Students", school.allTotal),

            // ---------------- BOOK & PUBLISHER ----------------
            _sectionTitle("Book & Publisher"),
            _infoRow("Will Change Book", school.willChangeBookList),
            _infoRow("Book Sale Method", school.bookSaleMethod),
            _infoRow("Publisher Name", school.publisherName),
            _infoRow("Previous Publisher", school.previousPublisher),
            _infoRow("Book Seller", school.bookSellerName),
            _infoRow("Seller Mobile", school.bookSellerMobile),

            // ---------------- INFRASTRUCTURE ----------------
            _sectionTitle("Infrastructure"),
            _infoRow("Rental / Own", school.rentalOrOwnSchool),
            _infoRow("Area of School", school.areaOfSchool),
            _infoRow("Playground Area", school.playgoundArea),
            _infoRow("Total Labs", school.totalLab),
            _infoRow("Library", school.library),
            _infoRow("Computer Lab", school.computerLab),
            _infoRow("Science Lab", school.compositeScienceLab),
            _infoRow("Math Lab", school.mathLab),
            _infoRow("Drinking Water", school.drinkingWaterFacilityFloorwise),
            _infoRow("Ramp / Lift", school.rampOrLift),

            // ---------------- AGENT INFO ----------------
            _sectionTitle("Agent Information"),
            _infoRow("Agent ID", school.agentId),
            _infoRow("Agent Name", school.agentName),
            _infoRow("Account Detail", school.accountDetail),
            _infoRow("Deal Years", school.howManyYearsForDealers),
          ],
        ),
      ),
    );
  }
}

// lib/pages/add_school_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddSchoolPage extends StatefulWidget {
  const AddSchoolPage({Key? key}) : super(key: key);

  @override
  State<AddSchoolPage> createState() => _AddSchoolPageState();
}

class _AddSchoolPageState extends State<AddSchoolPage> {
  final _formKey = GlobalKey<FormState>();

  // ---------------------------
  // Core controllers (Basic Info)
  // ---------------------------
  final TextEditingController _selectedSchoolCtl = TextEditingController();
  final TextEditingController _schoolNameCtl = TextEditingController();
  final TextEditingController _addressCtl = TextEditingController();
  final TextEditingController _districtCtl = TextEditingController();
  final TextEditingController _tahsilCtl = TextEditingController();
  final TextEditingController _blockCtl = TextEditingController();
  final TextEditingController _villageCtl = TextEditingController();
  final TextEditingController _mobileCtl = TextEditingController();
  // ADD THESE 2 LINES
  final TextEditingController _agentIdCtl = TextEditingController();
  final TextEditingController _agentNameCtl = TextEditingController();

  // Numeric / facility controllers
  final TextEditingController _areaCtl = TextEditingController();
  final TextEditingController _totalLabCtl = TextEditingController();
  final TextEditingController _conferenceCtl = TextEditingController();
  final TextEditingController _buildingFloorCtl = TextEditingController();
  final TextEditingController _playgroundCtl = TextEditingController();

  // ---------------------------
  // Prabandhak / Principal controllers
  // ---------------------------
  final TextEditingController _prabandhakNameCtl = TextEditingController();
  final TextEditingController _prabandhakMobileCtl = TextEditingController();
  final TextEditingController _prabandhakWakeupCtl = TextEditingController();
  final TextEditingController _prabandhakSleepCtl = TextEditingController();
  final TextEditingController _prabandhakAddressCtl = TextEditingController();

  final TextEditingController _principalNameCtl = TextEditingController();
  final TextEditingController _principalMobileCtl = TextEditingController();
  final TextEditingController _principalWakeupCtl = TextEditingController();
  final TextEditingController _principalSleepCtl = TextEditingController();
  final TextEditingController _principalCallTimeCtl = TextEditingController();
  final TextEditingController _principalAddressCtl = TextEditingController();

  // ---------------------------
  // Other school details controllers
  // ---------------------------
  final TextEditingController _classRoomsCtl = TextEditingController();
  final TextEditingController _chemistryLabCtl = TextEditingController();
  final TextEditingController _biologyLabCtl = TextEditingController();
  final TextEditingController _compositeLabCtl = TextEditingController();
  final TextEditingController _mathLabCtl = TextEditingController();
  final TextEditingController _computerLabCtl = TextEditingController();
  final TextEditingController _libraryCtl = TextEditingController();
  final TextEditingController _toiletFloorwiseCtl = TextEditingController();
  final TextEditingController _drinkingWaterCtl = TextEditingController();
  final TextEditingController _rampLiftCtl = TextEditingController();
  final TextEditingController _indoorGameCtl = TextEditingController();
  final TextEditingController _musicRoomCtl = TextEditingController();
  final TextEditingController _infirmaryCtl = TextEditingController();
  final TextEditingController _principalRoomCtl = TextEditingController();
  final TextEditingController _staffRoomCtl = TextEditingController();
  final TextEditingController _officeRoomCtl = TextEditingController();
  final TextEditingController _wellnessRoomCtl = TextEditingController();

  // ---------------------------
  // Additional school details
  // ---------------------------
  final TextEditingController _establishYearCtl = TextEditingController();
  String? _selectedSchoolType;
  String? _selectedMedium;
  String? _selectedBoard;
  bool _branchAvailable = false;
  String? _selectedAreaType;
  final TextEditingController _nearbySchoolCtl = TextEditingController();

  // ---------------------------
// Class-wise student count controllers
// ---------------------------
  final TextEditingController _nurseryCtl = TextEditingController();
  final TextEditingController _lkgCtl = TextEditingController();
  final TextEditingController _ukgCtl = TextEditingController();
  final List<TextEditingController> _classCtrls = List.generate(12, (_) => TextEditingController());

// <-- ADD THIS LINE
  final TextEditingController _totalStudentsCtl = TextEditingController();


// Fee structure controllers
  final TextEditingController _feeNurUkgCtl = TextEditingController();          // Nursery–UKG Fee
  final TextEditingController _feeNurUkgYearlyCtl = TextEditingController();    // Nursery–UKG Yearly Fee

  final TextEditingController _feeClass1to5Ctl = TextEditingController();       // Class 1–5 Fee
  final TextEditingController _feeClass1to5YearlyCtl = TextEditingController(); // Class 1–5 Yearly Fee

  final TextEditingController _feeClass6to8Ctl = TextEditingController();       // Class 6–8 Fee

  final TextEditingController _feeClass9to10Ctl = TextEditingController();      // Class 9–10 Fee

  final TextEditingController _feeClass11to12Ctl = TextEditingController();     // Class 11–12 Fee
  final TextEditingController _feeClass11to12YearlyCtl = TextEditingController(); // Class 11–12 Yearly Fee


  // Rental/Own toggle
  int _rentalOwnIndex = 0; // 0 = Rent, 1 = Own

  // Image picker
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // For demo preview: local sample image path (keeps as provided earlier)
  final String sampleImagePath = '/mnt/data/3e8272e0-95b6-4afc-b51a-66530f1c1ac5.png';

  // Known schools for autocomplete sample (replace with API list)
  final List<String> _knownSchools = [
    '-- Select School --',
    'IPC Inter College',
    'MP Public School',
    'Kamla Prasad Inter College',
    'Ideal Convent Academy',
    'SVN Inter college',
    'Ram Harsh inter college',
  ];

  // Boards list
  final List<String> _boardList = ['UP Board', 'CBSE', 'ICSE', 'CISCE'];

  // Teacher and Subject Table Controllers
  final List<String> _classList = [
    "Nursery", "LKG", "UKG",
    "Class1", "Class2", "Class3", "Class4", "Class5",
    "Class6", "Class7", "Class8", "Class9", "Class10",
    "Class11", "Class12"
  ];

  final List<TextEditingController> _teacherNameCtrls =
  List.generate(15, (_) => TextEditingController());

  final List<TextEditingController> _subjectCtrls =
  List.generate(15, (_) => TextEditingController());

  final List<TextEditingController> _teacherMobileCtrls =
  List.generate(15, (_) => TextEditingController());

  final List<TextEditingController> _publicationCtrls =
  List.generate(15, (_) => TextEditingController());

  bool _willChangeBookList = false;

  final TextEditingController _bookingSaleMethodCtl = TextEditingController();
  final TextEditingController _bookSellerNameCtl = TextEditingController();
  final TextEditingController _bookSellerMobileCtl = TextEditingController();
  final TextEditingController _dealerYearsCtl = TextEditingController();
  final TextEditingController _publisherCtl = TextEditingController();
  final TextEditingController _previousPublisherCtl = TextEditingController();
  final TextEditingController _accountDetailCtl = TextEditingController();
  final TextEditingController _lowStrengthReasonCtl = TextEditingController();

  String? _selectedGrade = "A";   // default value
/// Add
  final TextEditingController _schoolLocationCtl = TextEditingController();
  final TextEditingController _guardNameCtl = TextEditingController();
  final TextEditingController _guardNumberCtl = TextEditingController();
  final TextEditingController _accountantNameCtl = TextEditingController();
  final TextEditingController _accountantNumberCtl = TextEditingController();
  final TextEditingController _adminNameCtl = TextEditingController();
  final TextEditingController _adminMobileCtl = TextEditingController();
  final TextEditingController _principalHouseAddressCtl = TextEditingController();
  final TextEditingController _emailIdCtl = TextEditingController();
  final TextEditingController _ownerNameCtl = TextEditingController();
  final TextEditingController _ownerHouseAddressCtl = TextEditingController();
  final TextEditingController _ownerCurrentAddressCtl = TextEditingController();
  final TextEditingController _ownerEmailIdCtl = TextEditingController();

  bool _willPrincipalChange = false;



  @override
  void initState() {
    super.initState();
    _selectedSchoolCtl.text = _knownSchools.first;
  }

  @override
  void dispose() {
    // Dispose all controllers to avoid leaks
    _selectedSchoolCtl.dispose();
    _schoolNameCtl.dispose();
    _addressCtl.dispose();
    _districtCtl.dispose();
    _tahsilCtl.dispose();
    _blockCtl.dispose();
    _villageCtl.dispose();
    _mobileCtl.dispose();
    // ADD HERE
    _agentIdCtl.dispose();
    _agentNameCtl.dispose();


    _areaCtl.dispose();
    _totalLabCtl.dispose();
    _conferenceCtl.dispose();
    _buildingFloorCtl.dispose();
    _playgroundCtl.dispose();

    _prabandhakNameCtl.dispose();
    _prabandhakMobileCtl.dispose();
    _prabandhakWakeupCtl.dispose();
    _prabandhakSleepCtl.dispose();
    _prabandhakAddressCtl.dispose();

    _principalNameCtl.dispose();
    _principalMobileCtl.dispose();
    _principalWakeupCtl.dispose();
    _principalSleepCtl.dispose();
    _principalCallTimeCtl.dispose();
    _principalAddressCtl.dispose();

    _classRoomsCtl.dispose();
    _chemistryLabCtl.dispose();
    _biologyLabCtl.dispose();
    _compositeLabCtl.dispose();
    _mathLabCtl.dispose();
    _computerLabCtl.dispose();
    _libraryCtl.dispose();
    _toiletFloorwiseCtl.dispose();
    _drinkingWaterCtl.dispose();
    _rampLiftCtl.dispose();
    _indoorGameCtl.dispose();
    _musicRoomCtl.dispose();
    _infirmaryCtl.dispose();
    _principalRoomCtl.dispose();
    _staffRoomCtl.dispose();
    _officeRoomCtl.dispose();
    _wellnessRoomCtl.dispose();

    _establishYearCtl.dispose();
    _nearbySchoolCtl.dispose();

    _nurseryCtl.dispose();
    _lkgCtl.dispose();
    _ukgCtl.dispose();
    // ADD THIS
    _totalStudentsCtl.dispose();
    for (final c in _classCtrls) {
      c.dispose();
    }

    _feeNurUkgCtl.dispose();
    _feeNurUkgYearlyCtl.dispose();
    _feeClass1to5Ctl.dispose();
    _feeClass1to5YearlyCtl.dispose();
    _feeClass6to8Ctl.dispose();
    _feeClass9to10Ctl.dispose();
    _feeClass11to12Ctl.dispose();
    _feeClass11to12YearlyCtl.dispose();


    for (final c in _teacherNameCtrls) c.dispose();
    for (final c in _subjectCtrls) c.dispose();
    for (final c in _teacherMobileCtrls) c.dispose();
    for (final c in _publicationCtrls) c.dispose();

    _bookingSaleMethodCtl.dispose();
    _bookSellerNameCtl.dispose();
    _bookSellerMobileCtl.dispose();
    _dealerYearsCtl.dispose();
    _publisherCtl.dispose();
    _previousPublisherCtl.dispose();
    _accountDetailCtl.dispose();
    _lowStrengthReasonCtl.dispose();

    _schoolLocationCtl.dispose();
    _guardNameCtl.dispose();
    _guardNumberCtl.dispose();
    _accountantNameCtl.dispose();
    _accountantNumberCtl.dispose();
    _adminNameCtl.dispose();
    _adminMobileCtl.dispose();
    _principalHouseAddressCtl.dispose();
    _emailIdCtl.dispose();
    _ownerNameCtl.dispose();
    _ownerHouseAddressCtl.dispose();
    _ownerCurrentAddressCtl.dispose();
    _ownerEmailIdCtl.dispose();









    super.dispose();

  }

  // ---------------------------
  // Image picker helper
  // ---------------------------
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  // ---------------------------
  // Reusable widgets
  // ---------------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF00AEEF),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildNumericInput({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return _buildTextInput(
      label: label,
      controller: controller,
      hint: hint,
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        return num.tryParse(v) == null ? 'Enter a valid number' : null;
      },
    );
  }

  Widget _buildStudentInput(String label, TextEditingController controller) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final n = int.tryParse(v);
          if (n == null) return 'Enter a valid integer';
          if (n < 0) return 'Cannot be negative';
          return null;
        },
        onChanged: (v) {
          if (v.startsWith('-')) {
            final clean = v.replaceAll('-', '');
            controller.text = clean;
            controller.selection = TextSelection.collapsed(offset: clean.length);
          }
        },
      ),
    );
  }

  InputDecoration _cellInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }

  // ---------------------------
  // Save / Submit handler
  // ---------------------------
  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix validation errors')));
      return;
    }

    // Collect class-wise list
    final classCounts = <int>[];
    for (final ctl in _classCtrls) {
      final v = int.tryParse(ctl.text.trim()) ?? 0;
      classCounts.add(v);
    }

    final payload = <String, dynamic>{
      'agentId': _agentIdCtl.text.trim(),
      'agentName': _agentNameCtl.text.trim(),

      'selectedSchool': _selectedSchoolCtl.text.trim(),
      'schoolName': _schoolNameCtl.text.trim(),
      'address': _addressCtl.text.trim(),
      'district': _districtCtl.text.trim(),
      'tahsil': _tahsilCtl.text.trim(),
      'block': _blockCtl.text.trim(),
      'village': _villageCtl.text.trim(),
      'mobile': _mobileCtl.text.trim(),
      'rentalOrOwn': _rentalOwnIndex == 0 ? 'Rent' : 'Own',
      'areaOfSchool': _areaCtl.text.trim(),
      'totalLab': _totalLabCtl.text.trim(),
      'conferenceHall': _conferenceCtl.text.trim(),
      'buildingFloor': _buildingFloorCtl.text.trim(),
      'playgroundArea': _playgroundCtl.text.trim(),
      'prabandhak': {
        'name': _prabandhakNameCtl.text.trim(),
        'mobile': _prabandhakMobileCtl.text.trim(),
        'wakeupTime': _prabandhakWakeupCtl.text.trim(),
        'sleepingTime': _prabandhakSleepCtl.text.trim(),
        'address': _prabandhakAddressCtl.text.trim(),
      },
      'principal': {
        'name': _principalNameCtl.text.trim(),
        'mobile': _principalMobileCtl.text.trim(),
        'wakeupTime': _principalWakeupCtl.text.trim(),
        'sleepingTime': _principalSleepCtl.text.trim(),
        'callTime': _principalCallTimeCtl.text.trim(),
        'address': _principalAddressCtl.text.trim(),
      },
      'facilities': {
        'classRooms': _classRoomsCtl.text.trim(),
        'chemistryLab': _chemistryLabCtl.text.trim(),
        'biologyLab': _biologyLabCtl.text.trim(),
        'compositeScienceLab': _compositeLabCtl.text.trim(),
        'mathLab': _mathLabCtl.text.trim(),
        'computerLab': _computerLabCtl.text.trim(),
        'library': _libraryCtl.text.trim(),
        'toiletFloorwise': _toiletFloorwiseCtl.text.trim(),
        'drinkingWaterFloorwise': _drinkingWaterCtl.text.trim(),
        'rampOrLift': _rampLiftCtl.text.trim(),
        'indoorGameRoom': _indoorGameCtl.text.trim(),
        'musicActivityRoom': _musicRoomCtl.text.trim(),
        'infirmaryRoom': _infirmaryCtl.text.trim(),
        'principalRoom': _principalRoomCtl.text.trim(),
        'staffRoom': _staffRoomCtl.text.trim(),
        'officeRoom': _officeRoomCtl.text.trim(),
        'wellnessRoom': _wellnessRoomCtl.text.trim(),
      },
      'classWiseCounts': {
        'nursery': int.tryParse(_nurseryCtl.text.trim()) ?? 0,
        'lkg': int.tryParse(_lkgCtl.text.trim()) ?? 0,
        'ukg': int.tryParse(_ukgCtl.text.trim()) ?? 0,
        'classes': classCounts, // Class 1..12
        // ⭐ NEW LINE ADDED
        'totalStudents': int.tryParse(_totalStudentsCtl.text.trim()) ?? 0,

      },
      'schoolDetails': {
        'establishYear': _establishYearCtl.text.trim(),
        'schoolType': _selectedSchoolType,
        'medium': _selectedMedium,
        'board': _selectedBoard,
        'branchAvailable': _branchAvailable,
        'areaType': _selectedAreaType,
        'nearbySchool': _nearbySchoolCtl.text.trim(),
      },
      'photoProvided': _pickedImage != null,

      'feeStructure': {
        'nurseryToUkgFee': _feeNurUkgCtl.text.trim(),
        'nurseryToUkgYearly': _feeNurUkgYearlyCtl.text.trim(),
        'class1To5Fee': _feeClass1to5Ctl.text.trim(),
        'class1To5Yearly': _feeClass1to5YearlyCtl.text.trim(),
        'class6To8Fee': _feeClass6to8Ctl.text.trim(),
        'class9To10Fee': _feeClass9to10Ctl.text.trim(),
        'class11To12Fee': _feeClass11to12Ctl.text.trim(),
        'class11To12Yearly': _feeClass11to12YearlyCtl.text.trim(),
      },
      'teacherTable': List.generate(_classList.length, (i) => {
        'class': _classList[i],
        'teacher': _teacherNameCtrls[i].text.trim(),
        'subject': _subjectCtrls[i].text.trim(),
        'mobile': _teacherMobileCtrls[i].text.trim(),
        'publication': _publicationCtrls[i].text.trim(),
      }),


    };

    // For demonstration we print payload and show success
    // Replace this with your API call (multipart if sending image)
    // ignore: avoid_print
    print('Ready to submit payload: ${payload.toString()}');

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('School saved (demo).')));
  }

  // ---------------------------
  // Layout
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    const double maxContentWidth = 1000;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add School Information',
          style: TextStyle(color: Colors.white),   // 👈 Title text color white
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add School Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Divider(),

                      // BASIC SCHOOL INFORMATION
                      _buildSectionTitle('Basic School Information'),
                      const SizedBox(height: 6),
                      // --- Agent Information ---
                      _buildTextInput(
                        label: 'Agent ID',
                        controller: _agentIdCtl,
                        hint: 'Enter Agent ID',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Agent ID is required';
                          }
                          return null;
                        },
                      ),


                      _buildTextInput(
                        label: 'Agent Name',
                        controller: _agentNameCtl,
                        hint: 'Enter Agent Name',
                      ),


                      // Select School (autocomplete)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Autocomplete<String>(
                          initialValue: TextEditingValue(text: _selectedSchoolCtl.text),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) return _knownSchools;
                            return _knownSchools.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (selection) {
                            setState(() {
                              _selectedSchoolCtl.text = selection;
                              if (selection != '-- Select School --') _schoolNameCtl.text = selection;
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                            controller.text = _selectedSchoolCtl.text;
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                labelText: 'Select School',
                                hintText: '-- Select School --',
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          },
                        ),
                      ),


                      _buildTextInput(
                        label: 'School Name',
                        controller: _schoolNameCtl,
                        hint: 'School Name',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter school name' : null,
                      ),

                      _buildTextInput(
                        label: 'School Address',
                        controller: _addressCtl,
                        hint: 'School Address',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter school address' : null,
                      ),

                      Row(
                        children: [
                          Expanded(child: _buildTextInput(label: 'District', controller: _districtCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextInput(label: 'Tahsil', controller: _tahsilCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextInput(label: 'Block', controller: _blockCtl)),
                        ],
                      ),

                      Row(
                        children: [
                          Expanded(child: _buildTextInput(label: 'Village', controller: _villageCtl)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextInput(
                              label: 'Mobile',
                              controller: _mobileCtl,
                              hint: 'Mobile number',
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                if (!RegExp(r'^\d{7,15}$').hasMatch(v)) return 'Enter valid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Text('Rental / Own', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ToggleButtons(
                        isSelected: [_rentalOwnIndex == 0, _rentalOwnIndex == 1],
                        onPressed: (index) => setState(() => _rentalOwnIndex = index),
                        selectedColor: Colors.white,
                        color: Colors.black87,
                        fillColor: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Rent')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Own')),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Total Area Of School (sq ft)', controller: _areaCtl, hint: 'e.g. 500')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'Total Lab', controller: _totalLabCtl, hint: 'e.g. 3')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Conference Hall', controller: _conferenceCtl, hint: 'e.g. 1')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'School Building Floor', controller: _buildingFloorCtl, hint: 'e.g. 2')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Playground Area (sq)', controller: _playgroundCtl, hint: 'e.g. 100')),
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox()),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildSectionTitle('School Photo'),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 160,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _pickedImage != null
                                  ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                  : (File(sampleImagePath).existsSync()
                                  ? Image.file(File(sampleImagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())
                                  : const Center(child: Icon(Icons.image, size: 44, color: Colors.grey))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Upload Photo'),
                                ),
                                const SizedBox(height: 6),
                                const Text('Recommended: JPG/PNG, max 5MB.'),
                                const SizedBox(height: 8),
                                if (_pickedImage != null) Text('Selected: ${_pickedImage!.path.split('/').last}', overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          )
                        ],
                      ),

                      // PRABANDHAK / PRINCIPAL
                      _buildSectionTitle('Prabandhak / Principal Details'),
                      _buildTextInput(label: 'Prabandhak Name', controller: _prabandhakNameCtl, hint: 'Prabandhak Name'),
                      _buildTextInput(label: 'Mobile', controller: _prabandhakMobileCtl, hint: 'Prabandhak No', keyboardType: TextInputType.phone),
                      Row(
                        children: [
                          Expanded(child: _buildTextInput(label: 'Prabandhak Wakeup Time', controller: _prabandhakWakeupCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextInput(label: 'Prabandhak Sleeping Time', controller: _prabandhakSleepCtl)),
                        ],
                      ),
                      _buildTextInput(label: 'Prabandhak Address', controller: _prabandhakAddressCtl, hint: 'Prabandhak Address'),

                      const SizedBox(height: 12),
                      _buildSectionTitle('Principal Details'),
                      _buildTextInput(label: 'Principal Name', controller: _principalNameCtl, hint: 'Principal Name'),
                      _buildTextInput(label: 'Mobile', controller: _principalMobileCtl, hint: 'Principal No', keyboardType: TextInputType.phone),
                      Row(
                        children: [
                          Expanded(child: _buildTextInput(label: 'Principal Wakeup Time', controller: _principalWakeupCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextInput(label: 'Principal Sleeping Time', controller: _principalSleepCtl)),
                        ],
                      ),
                      _buildTextInput(label: 'Principal Call Time', controller: _principalCallTimeCtl, hint: 'Call Allowed Time'),
                      _buildTextInput(label: 'Principal Address', controller: _principalAddressCtl, hint: 'Principal Address'),

                      // OTHER SCHOOL DETAILS
                      _buildSectionTitle('Other School Details'),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Class Rooms', controller: _classRoomsCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'Chemistry Lab', controller: _chemistryLabCtl)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Biology Lab', controller: _biologyLabCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'Composite Science Lab', controller: _compositeLabCtl)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Math Lab', controller: _mathLabCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'Computer Lab', controller: _computerLabCtl)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Library', controller: _libraryCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'Toilet Floor-wise', controller: _toiletFloorwiseCtl)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildTextInput(label: 'Drinking Water Facility (Floorwise)', controller: _drinkingWaterCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextInput(label: 'Ramp Or Lift', controller: _rampLiftCtl)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Indoor Game Room', controller: _indoorGameCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'Music Activity Room', controller: _musicRoomCtl)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Infirmary Room', controller: _infirmaryCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'Principal Room', controller: _principalRoomCtl)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Staff Room', controller: _staffRoomCtl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildNumericInput(label: 'Office Room', controller: _officeRoomCtl)),
                        ],
                      ),
                      _buildNumericInput(label: 'Wellness Room', controller: _wellnessRoomCtl),


                      // ADDITIONAL / SCHOOL DETAILS
                      _buildSectionTitle('Additional School Details'),
                      Row(
                        children: [
                          Expanded(child: _buildNumericInput(label: 'Establish Year', controller: _establishYearCtl, hint: 'e.g. 1987')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'School Type',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Private', child: Text('Private')),
                                DropdownMenuItem(value: 'Government', child: Text('Government')),
                                DropdownMenuItem(value: 'Semi-Private', child: Text('Semi-Private')),
                              ],
                              value: _selectedSchoolType,
                              onChanged: (v) => setState(() => _selectedSchoolType = v),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'School Medium',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                                DropdownMenuItem(value: 'English', child: Text('English')),
                                DropdownMenuItem(value: 'Both', child: Text('Both')),
                              ],
                              value: _selectedMedium,
                              onChanged: (v) => setState(() => _selectedMedium = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Autocomplete<String>(
                              optionsBuilder: (textEditingValue) {
                                if (textEditingValue.text.isEmpty) return _boardList;
                                return _boardList.where((b) => b.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (val) => setState(() => _selectedBoard = val),
                              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                controller.text = _selectedBoard ?? controller.text;
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onEditingComplete: onEditingComplete,
                                  decoration: InputDecoration(
                                    labelText: 'Select Board',
                                    hintText: 'UP Board / CBSE / ICSE / CISCE',
                                    suffixIcon: const Icon(Icons.arrow_drop_down),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: const Text('Branch Available', style: TextStyle(fontWeight: FontWeight.w600))),
                          ToggleButtons(
                            isSelected: [_branchAvailable, !_branchAvailable],
                            onPressed: (index) => setState(() => _branchAvailable = index == 0),
                            selectedColor: Colors.white,
                            fillColor: Colors.blue,
                            borderRadius: BorderRadius.circular(6),
                            children: const [
                              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Yes')),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('No')),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Area Type',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'City', child: Text('City')),
                                DropdownMenuItem(value: 'Town', child: Text('Town')),
                                DropdownMenuItem(value: 'Village', child: Text('Village')),
                                DropdownMenuItem(value: 'Metro City', child: Text('Metro City')),
                              ],
                              value: _selectedAreaType,
                              onChanged: (v) => setState(() => _selectedAreaType = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextInput(label: 'Nearby School', controller: _nearbySchoolCtl, hint: 'Nearby School Name')),
                        ],
                      ),

                      // CLASS-WISE STUDENT COUNT

                      _buildSectionTitle('Class-wise Student Count'),
                      _buildStudentInput('Nursery', _nurseryCtl),
                      _buildStudentInput('LKG', _lkgCtl),
                      _buildStudentInput('UKG', _ukgCtl),

                      for (int i = 0; i < _classCtrls.length; i++)
                        _buildStudentInput('Class ${i + 1}', _classCtrls[i]),


                           // 👇👇 ADD THIS NEW LINE (Total Students)
                      _buildStudentInput('Total Students', _totalStudentsCtl),

                      // ---------------------------
// Fee Structure Section
// ---------------------------
                      _buildSectionTitle('Fee Structure'),
                      const SizedBox(height: 6),

                      _buildTextInput(
                        label: 'Nursery to UKG Fee (Monthly)',
                        controller: _feeNurUkgCtl,
                        hint: 'Enter monthly fee',
                        keyboardType: TextInputType.number,
                      ),

                      _buildTextInput(
                        label: 'Nursery to UKG Yearly Fee',
                        controller: _feeNurUkgYearlyCtl,
                        hint: 'Enter yearly fee',
                        keyboardType: TextInputType.number,
                      ),

                      _buildTextInput(
                        label: 'Class 1 to 5 Fee (Monthly)',
                        controller: _feeClass1to5Ctl,
                        hint: 'Enter monthly fee',
                        keyboardType: TextInputType.number,
                      ),

                      _buildTextInput(
                        label: 'Class 1 to 5 Yearly Fee',
                        controller: _feeClass1to5YearlyCtl,
                        hint: 'Enter yearly fee',
                        keyboardType: TextInputType.number,
                      ),

                      _buildTextInput(
                        label: 'Class 6 to 8 Fee (Monthly)',
                        controller: _feeClass6to8Ctl,
                        hint: 'Enter monthly fee',
                        keyboardType: TextInputType.number,
                      ),

                      _buildTextInput(
                        label: 'Class 9 to 10 Fee (Monthly)',
                        controller: _feeClass9to10Ctl,
                        hint: 'Enter monthly fee',
                        keyboardType: TextInputType.number,
                      ),

                      _buildTextInput(
                        label: 'Class 11 to 12 Fee (Monthly)',
                        controller: _feeClass11to12Ctl,
                        hint: 'Enter monthly fee',
                        keyboardType: TextInputType.number,
                      ),

                      _buildTextInput(
                        label: 'Class 11 to 12 Yearly Fee',
                        controller: _feeClass11to12YearlyCtl,
                        hint: 'Enter yearly fee',
                        keyboardType: TextInputType.number,
                      ),


                      // ---------------------------
                        // Teacher & Subject Table
                        // ---------------------------

                      _buildSectionTitle("Teacher / Subject / Publication Details"),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,   // 👈 Horizontal scrolling enabled
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                // Header Row
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  color: const Color(0xFFE8F8FF),
                                  child: Row(
                                    children: const [
                                      SizedBox(width: 120, child: Center(child: Text("Class", style: TextStyle(fontWeight: FontWeight.bold)))),
                                      SizedBox(width: 180, child: Center(child: Text("Teacher Name", style: TextStyle(fontWeight: FontWeight.bold)))),
                                      SizedBox(width: 180, child: Center(child: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold)))),
                                      SizedBox(width: 150, child: Center(child: Text("Mobile No", style: TextStyle(fontWeight: FontWeight.bold)))),
                                      SizedBox(width: 200, child: Center(child: Text("Publication Name", style: TextStyle(fontWeight: FontWeight.bold)))),
                                    ],
                                  ),
                                ),

                                // Dynamic Rows
                                for (int i = 0; i < _classList.length; i++)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              _classList[i],
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          width: 180,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: TextField(
                                              controller: _teacherNameCtrls[i],
                                              decoration: _cellInputDecoration("Teacher Name"),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          width: 180,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: TextField(
                                              controller: _subjectCtrls[i],
                                              decoration: _cellInputDecoration("Subject"),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          width: 150,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: TextField(
                                              controller: _teacherMobileCtrls[i],
                                              keyboardType: TextInputType.phone,
                                              decoration: _cellInputDecoration("Mobile"),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          width: 200,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: TextField(
                                              controller: _publicationCtrls[i],
                                              decoration: _cellInputDecoration("Publication Name"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // -----------------------------
// Book & Publisher Information
// -----------------------------
                      _buildSectionTitle("Book % Publisher Info"),
                      const SizedBox(height: 10),

// Will Change Book List? Yes / No
                      const Text("Will Change Book List?", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      ToggleButtons(
                        isSelected: [_willChangeBookList == true, _willChangeBookList == false],
                        onPressed: (index) {
                          setState(() => _willChangeBookList = index == 0);
                        },
                        selectedColor: Colors.white,
                        fillColor: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Yes")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("No")),
                        ],
                      ),
                      const SizedBox(height: 16),

// Booking Sale Method
                      _buildTextInput(
                        label: "Booking Sale Method",
                        controller: _bookingSaleMethodCtl,
                        hint: "Enter booking method",
                      ),

// Book Seller Name
                      _buildTextInput(
                        label: "Book Seller Name",
                        controller: _bookSellerNameCtl,
                        hint: "Enter name",
                      ),

// Mobile
                      _buildTextInput(
                        label: "Mobile Number",
                        controller: _bookSellerMobileCtl,
                        hint: "Enter mobile",
                        keyboardType: TextInputType.phone,
                      ),

// Dealer Year
                      _buildNumericInput(
                        label: "How Many Years for Dealer",
                        controller: _dealerYearsCtl,
                        hint: "Enter number of years",
                      ),

// Publisher
                      _buildTextInput(
                        label: "Publisher",
                        controller: _publisherCtl,
                        hint: "Enter publisher name",
                      ),

// Previous Publisher
                      _buildTextInput(
                        label: "Previous Publisher",
                        controller: _previousPublisherCtl,
                        hint: "Enter previous publisher",
                      ),

// Account Detail
                      _buildTextInput(
                        label: "Account Detail",
                        controller: _accountDetailCtl,
                        hint: "Enter account details",
                      ),

// Strength Of Low Student & Why
                      _buildTextInput(
                        label: "Strength of Low Student & Why",
                        controller: _lowStrengthReasonCtl,
                        hint: "Explain reason",
                      ),
                      // -----------------------------
// Grade Section
// -----------------------------
                      _buildSectionTitle("Grade"),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Grade",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        ),
                        value: _selectedGrade,
                        items: const [
                          DropdownMenuItem(value: "A", child: Text("A")),
                          DropdownMenuItem(value: "B", child: Text("B")),
                          DropdownMenuItem(value: "C", child: Text("C")),
                          DropdownMenuItem(value: "D", child: Text("D")),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _selectedGrade = v;
                          });
                        },
                      ),

                      // -----------------------------
// Upload & Other Info
// -----------------------------
                      _buildSectionTitle("Upload & Other Info"),
                      const SizedBox(height: 10),

// School Location
                      _buildTextInput(
                        label: "School Location",
                        controller: _schoolLocationCtl,
                        hint: "Enter school location",
                      ),

// Guard Name / Number
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextInput(
                              label: "Guard Name",
                              controller: _guardNameCtl,
                              hint: "Enter guard name",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextInput(
                              label: "Guard Number",
                              controller: _guardNumberCtl,
                              hint: "Enter guard mobile no",
                              keyboardType: TextInputType.phone,
                            ),
                          )
                        ],
                      ),

// Accountant Name / Number
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextInput(
                              label: "Accountant Name",
                              controller: _accountantNameCtl,
                              hint: "Enter accountant name",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextInput(
                              label: "Accountant Number",
                              controller: _accountantNumberCtl,
                              hint: "Enter mobile",
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),

// School Admin Name / Mobile
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextInput(
                              label: "School Admin Name",
                              controller: _adminNameCtl,
                              hint: "Enter admin name",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextInput(
                              label: "Mobile Number",
                              controller: _adminMobileCtl,
                              hint: "Enter admin mobile",
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),

// Principal House Address
                      _buildTextInput(
                        label: "Principal House Address",
                        controller: _principalHouseAddressCtl,
                        hint: "Enter principal house address",
                      ),

// Email ID
                      _buildTextInput(
                        label: "Email ID",
                        controller: _emailIdCtl,
                        hint: "Enter email ID",
                        keyboardType: TextInputType.emailAddress,
                      ),

// School Owner Name
                      _buildTextInput(
                        label: "School Owner Name",
                        controller: _ownerNameCtl,
                        hint: "Enter owner name",
                      ),

// Owner House Address
                      _buildTextInput(
                        label: "School Owner House Address",
                        controller: _ownerHouseAddressCtl,
                        hint: "Enter owner house address",
                      ),

// Owner Current Address
                      _buildTextInput(
                        label: "School Owner Current Address",
                        controller: _ownerCurrentAddressCtl,
                        hint: "Enter owner current address",
                      ),

// Owner Email ID
                      _buildTextInput(
                        label: "School Owner Email ID",
                        controller: _ownerEmailIdCtl,
                        hint: "Enter owner email",
                        keyboardType: TextInputType.emailAddress,
                      ),

// Will Principal Change?
                      const Text(
                        "Will Principal Change?",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),

                      ToggleButtons(
                        isSelected: [
                          _willPrincipalChange == true,
                          _willPrincipalChange == false,
                        ],
                        onPressed: (index) {
                          setState(() => _willPrincipalChange = index == 0);
                        },
                        selectedColor: Colors.white,
                        fillColor: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Yes")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("No")),
                        ],
                      ),






                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
                          child: const Text('Save', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

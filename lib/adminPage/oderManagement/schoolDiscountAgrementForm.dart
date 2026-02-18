
import 'dart:convert';
import 'dart:io';
import 'package:bookworld/adminPage/oderManagement/school_goto_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../Model/school_discount_agreement_model.dart';
import '../../Service/school_discount_agreement_service.dart';
import '../../Model/agreement_school_list_model.dart';
import '../../Service/agreement_school_list_service.dart';
import '../../Model/agreement_school_address_model.dart';
import '../../Service/agreement_school_address_service.dart';
import '../../Model/school_agreement_agent_model.dart';
import '../../Service/school_agreement_agent_service.dart';


class SchoolDiscountAgreementForm extends StatefulWidget {
  const SchoolDiscountAgreementForm({super.key});

  @override
  State<SchoolDiscountAgreementForm> createState() => _SchoolDiscountAgreementFormState();
}

class _SchoolDiscountAgreementFormState extends State<SchoolDiscountAgreementForm> {

  File? _partySignatureFile;
  String? _partySignatureBase64;
  File? _managerSignatureFile;
  String? _managerSignatureBase64;



  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;   // ✅ YAHAN ADD KARNA HAI

  // Dropdown Values
  String? selectedPublication;
  String? selectedType;
  String? selectedSchoolType;

  // Agent Dropdown
  List<AgentItem> agentList = [];
  AgentItem? selectedAgent;



  List<SchoolItem> schoolList = [];
  SchoolItem? selectedSchool;


  final List<String> typeOptions = ['COUNTER', 'SUPPLY ', 'BYSHOP'];
  final List<String> schoolTypeOptions = ['OLD', 'NEW'];

  // Controllers
  final TextEditingController _fileNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController1 = TextEditingController();
  final TextEditingController _cityController2 = TextEditingController();
  final TextEditingController _cityController3 = TextEditingController();

  // Manager Details
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _managerContactController = TextEditingController();
  DateTime? _managerDOB;
  DateTime? _managerAnniversary;

  // Principal Details
  final TextEditingController _principalNameController = TextEditingController();
  final TextEditingController _principalContactController = TextEditingController();
  DateTime? _principalDOB;
  DateTime? _principalAnniversary;

  // Agent Details
  final TextEditingController _agentNameController = TextEditingController();
  DateTime? _agentDOB;
  DateTime? _agentAnniversary;

  // Dates
  DateTime? _orderDate;
  DateTime? _deliveryDate;

  // Documents
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();

  // Payment Terms (Months)
  final Map<String, bool> _paymentMonths = {
    'January': false, 'February': false, 'March': false, 'April': false,
    'May': false, 'June': false, 'July': false, 'August': false,
    'September': false, 'October': false, 'November': false, 'December': false,
  };
  final Map<String, TextEditingController> _paymentAmountControllers = {};

  // Discount Slabs
  final List<TextEditingController> _discountSlabControllers = List.generate(12, (_) => TextEditingController());

  // Miscellaneous
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _bankDetailsController = TextEditingController();
  final TextEditingController _chequeNoController = TextEditingController();
  final TextEditingController _securityCheckController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _paymentMonths.keys.forEach((month) {
      _paymentAmountControllers[month] = TextEditingController();
    });

    _loadSchools();
    _loadAgents();   // ✅ ADD THIS
  }

  Future<void> _loadAgents() async {
    try {
      final agents =
      await SchoolAgreementAgentService().fetchAgents();
      setState(() {
        agentList = agents;
      });
    } catch (e) {
      print(e);
    }
  }



  Future<void> _loadSchools() async {
    try {
      final schools =
      await AgreementSchoolListService().fetchSchools();
      setState(() {
        schoolList = schools;
      });
    } catch (e) {
      print(e);
    }
  }


  Future<void> _selectDate(BuildContext context, Function(DateTime) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        onSelected(picked);
      });
    }
  }
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    String? formatDate(DateTime? date) {
      if (date == null) return null;
      return DateFormat('yyyy-MM-dd').format(date);
    }

    Map<String, String?> payments = {};
    _paymentMonths.forEach((month, selected) {
      payments[month] =
      selected ? _paymentAmountControllers[month]?.text : null;
    });

    final model = SchoolDiscountAgreementModel(
      partyName: selectedSchool?.accName,

      address: _addressController.text,
      district: _cityController1.text,
      block: _cityController2.text,
      area: _cityController3.text,
      manageName: _managerNameController.text,
      managerContact: _managerContactController.text,
      managerDOB: formatDate(_managerDOB),
      managerAnniversary: formatDate(_managerAnniversary),
      principalName: _principalNameController.text,
      principalContact: _principalContactController.text,
      principalDOB: formatDate(_principalDOB),
      principalAnniversary: formatDate(_principalAnniversary),
      agentName: selectedAgent?.employeeName,

      agentDOB: formatDate(_agentDOB),
      agentAnniversary: formatDate(_agentAnniversary),
      orderDate: formatDate(_orderDate),
      deliveryDate: formatDate(_deliveryDate),
      schoolPanNo: _panController.text,
      schoolAdharNo: _aadhaarController.text,
      schoolAccountNo: _accountNoController.text,
      schoolBankDetail: _bankDetailsController.text,
      chequeNo: _chequeNoController.text,
      securiyCheck: _securityCheckController.text,
      type: selectedType,
      schoolType: selectedSchoolType,
      fileNo: _fileNoController.text,
      remarks: _remarksController.text,
      monthlyPayments: payments,
      partySignatureBase64: _partySignatureBase64,
      managerSignatureBase64: _managerSignatureBase64,


      discountSlabs:
      _discountSlabControllers.map((e) => e.text).toList(),
    );

    setState(() => _isLoading = true);

    print("Party Signature: ${_partySignatureBase64 != null}");
    print("Manager Signature: ${_managerSignatureBase64 != null}");
    print("Party Length: ${_partySignatureBase64?.length}");
    print("Manager Length: ${_managerSignatureBase64?.length}");


    try {
      final response =
      await SchoolDiscountAgreementService().submitAgreement(model);

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickSignature(bool isParty) async {
    final picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();

      final base64String = base64Encode(bytes);

      final fullBase64 = base64String;

      setState(() {
        if (isParty) {
          _partySignatureFile = file;
          _partySignatureBase64 = fullBase64;
        } else {
          _managerSignatureFile = file;
          _managerSignatureBase64 = fullBase64;
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'School Agreement Form',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Agreement & Order Form',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      _buildLabelAndField('File No', _fileNoController),

                      /// ✅ UPDATED SCHOOL DROPDOWN (Dynamic API)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('School', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<SchoolItem>(
                              value: selectedSchool,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(12),
                                border: OutlineInputBorder(),
                              ),
                              isExpanded: true,
                              items: schoolList.map((school) {
                                return DropdownMenuItem<SchoolItem>(
                                  value: school,
                                  child: Text(
                                    school.accName,
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (SchoolItem? value) async {
                                setState(() {
                                  selectedSchool = value;
                                });

                                if (value != null) {
                                  try {

                                    final response =
                                    await AgreementSchoolAddressService()
                                        .fetchSchoolAddress(value.schoolId);

                                    if (response.status && response.data != null) {

                                      final addressData = response.data!;

                                      setState(() {
                                        _addressController.text = addressData.address;
                                        _cityController1.text = addressData.district;
                                        _cityController2.text = addressData.block;
                                        _cityController3.text = addressData.area;
                                      });
                                    }

                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Address fetch failed")),
                                    );
                                  }
                                }
                              },
                              hint: const Text('- Select School -'),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                      _buildDropdownField(
                          'Type', typeOptions, selectedType,
                              (val) => setState(() => selectedType = val)),

                      _buildDropdownField(
                          'School Type', schoolTypeOptions, selectedSchoolType,
                              (val) => setState(() => selectedSchoolType = val)),

                      _buildLabelAndField('Address', _addressController),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('', _cityController1, hint: 'District')),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('', _cityController2, hint: 'Block')),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('', _cityController3, hint: 'Area')),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildSectionHeader('Manager Details'),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('Manager Name', _managerNameController)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('Manager Contact', _managerContactController)),
                        ],
                      ),

                      Row(
                        children: [
                          Expanded(child: _buildDateField('Date of Birth', _managerDOB, (d) => _managerDOB = d)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDateField('Date of Anniversary', _managerAnniversary, (d) => _managerAnniversary = d)),
                        ],
                      ),

                      _buildSectionHeader('Principal Details'),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('Principal Name', _principalNameController)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('Principal Contact', _principalContactController)),
                        ],
                      ),

                      Row(
                        children: [
                          Expanded(child: _buildDateField('Date of Birth', _principalDOB, (d) => _principalDOB = d)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDateField('Date of Anniversary', _principalAnniversary, (d) => _principalAnniversary = d)),
                        ],
                      ),

                      _buildSectionHeader('Agent Details'),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Agent', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<AgentItem>(
                              value: selectedAgent,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(12),
                                border: OutlineInputBorder(),
                              ),
                              isExpanded: true,
                              items: agentList.map((agent) {
                                return DropdownMenuItem<AgentItem>(
                                  value: agent,
                                  child: Text(
                                    agent.employeeName,
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (AgentItem? value) {
                                setState(() {
                                  selectedAgent = value;

                                  // Optional: auto fill manager contact
                                  _agentNameController.text = value?.employeeName ?? '';
                                });
                              },
                              hint: const Text('- Select Agent -'),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),


                      Row(
                        children: [
                          Expanded(child: _buildDateField('Date of Birth', _agentDOB, (d) => _agentDOB = d)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDateField('Date of Anniversary', _agentAnniversary, (d) => _agentAnniversary = d)),
                        ],
                      ),

                      _buildSectionHeader('Order/Delivery Date'),

                      Row(
                        children: [
                          Expanded(child: _buildDateField('Order Date', _orderDate, (d) => _orderDate = d)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDateField('Delivery Date', _deliveryDate, (d) => _deliveryDate = d)),
                        ],
                      ),

                      _buildSectionHeader('Documents'),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('', _panController, hint: 'School PAN No')),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('', _aadhaarController, hint: 'School Aadhaar No')),
                        ],
                      ),

                      _buildSectionHeader('Payment Term & Condition'),
                      _buildPaymentMonthsGrid(),

                      _buildSectionHeader('Discount Slab'),
                      _buildDiscountSlabGrid(),

                      const SizedBox(height: 20),

                      _buildLabelAndField('Remarks', _remarksController),
                      _buildLabelAndField('School Account No', _accountNoController),
                      _buildLabelAndField('School Bank Detail', _bankDetailsController),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(child: _buildTextField('Cheque No', _chequeNoController)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('Security Check', _securityCheckController)),
                        ],
                      ),

                      _buildSectionHeader('Digital Signature'),

                      Row(
                        children: [
                          /// Party Signature
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickSignature(true),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Party Signature',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _partySignatureFile == null
                                        ? const Center(child: Text("Tap to upload"))
                                        : Image.file(
                                      _partySignatureFile!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// Manager Signature
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickSignature(false),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Manager Signature',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _managerSignatureFile == null
                                        ? const Center(child: Text("Tap to upload"))
                                        : Image.file(
                                      _managerSignatureFile!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),


                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SchoolGotoViewScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            child: const Text(
                              'Go To View',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLabelAndField(String label, TextEditingController controller) {
    return _buildTextField(label, controller);
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
        ],
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }


  Widget _buildDropdownField(String label, List<String> options, String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(12),
              border: OutlineInputBorder(),
            ),
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
            hint: const Text('- Select -'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectDate(context, onSelected),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date == null ? 'dd-mm-yyyy' : DateFormat('dd-MM-yyyy').format(date!)),
                const Icon(Icons.calendar_month, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPaymentMonthsGrid() {
    final List<String> months = _paymentMonths.keys.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        return Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _paymentMonths[month],
                  activeColor: Colors.red,
                  onChanged: (val) => setState(() => _paymentMonths[month] = val!),
                ),
                Text(month),
              ],
            ),
            if (_paymentMonths[month]!)
              TextFormField(
                controller: _paymentAmountControllers[month],
                decoration: InputDecoration(
                  hintText: '$month Amount',
                  isDense: true,
                  contentPadding: const EdgeInsets.all(8),
                  border: const OutlineInputBorder(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDiscountSlabGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return TextFormField(
          controller: _discountSlabControllers[index],
          decoration: InputDecoration(
            hintText: 'Discount Slab ${index + 1}',
            isDense: true,
            contentPadding: const EdgeInsets.all(8),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Widget _buildSignaturePicker(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Text('Choose file', style: TextStyle(fontSize: 10)),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('No file chosen', style: TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
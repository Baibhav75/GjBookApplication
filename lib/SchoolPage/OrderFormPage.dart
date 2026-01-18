import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  _OrderFormPageState createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _managerContactController = TextEditingController();
  final TextEditingController _managerDobController = TextEditingController();
  final TextEditingController _managerAnniversaryController = TextEditingController();
  final TextEditingController _principalNameController = TextEditingController();
  final TextEditingController _principalContactController = TextEditingController();
  final TextEditingController _principalDobController = TextEditingController();
  final TextEditingController _principalAnniversaryController = TextEditingController();
  final TextEditingController _agentNameController = TextEditingController();
  final TextEditingController _agentManagerController = TextEditingController();
  final TextEditingController _orderDateController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _panCardController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _bankDetailsController = TextEditingController();
  final TextEditingController _chequeNoController = TextEditingController();
  final List<TextEditingController> _discountControllers = List.generate(8, (index) => TextEditingController());
  final TextEditingController _agreementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set current date as default
    final now = DateTime.now();
    _orderDateController.text = "${now.day}/${now.month}/${now.year}";
  }

  @override
  void dispose() {
    // Dispose all controllers
    _partyNameController.dispose();
    _schoolNameController.dispose();
    _districtController.dispose();
    _blockController.dispose();
    _areaController.dispose();
    _managerNameController.dispose();
    _managerContactController.dispose();
    _managerDobController.dispose();
    _managerAnniversaryController.dispose();
    _principalNameController.dispose();
    _principalContactController.dispose();
    _principalDobController.dispose();
    _principalAnniversaryController.dispose();
    _agentNameController.dispose();
    _agentManagerController.dispose();
    _orderDateController.dispose();
    _deliveryDateController.dispose();
    _panCardController.dispose();
    _aadharController.dispose();
    _accountNoController.dispose();
    _bankDetailsController.dispose();
    _chequeNoController.dispose();
    for (var controller in _discountControllers) {
      controller.dispose();
    }
    _agreementController.dispose();
    super.dispose();
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'ORDER FORM 2026',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // 1. Name of Party
              pw.Text('1. Name of Party : ${_partyNameController.text}'),
              pw.SizedBox(height: 10),

              // 2. School Details
              pw.Text('2. Name & Address of School : ${_schoolNameController.text}'),
              pw.Row(
                children: [
                  pw.Text('District : ${_districtController.text}'),
                  pw.SizedBox(width: 20),
                  pw.Text('Block : ${_blockController.text}'),
                  pw.SizedBox(width: 20),
                  pw.Text('Area : ${_areaController.text}'),
                ],
              ),
              pw.SizedBox(height: 10),

              // 3. Manager's Details
              pw.Text('3. Manager\'s Name : ${_managerNameController.text}'),
              pw.Row(
                children: [
                  pw.Text('Contact No.: ${_managerContactController.text}'),
                  pw.SizedBox(width: 20),
                  pw.Text('Date of Birth : ${_managerDobController.text}'),
                  pw.SizedBox(width: 20),
                  pw.Text('Date of Anniversary: ${_managerAnniversaryController.text}'),
                ],
              ),
              pw.SizedBox(height: 10),

              // 4. Principal's Details
              pw.Text('4. Principal\'s Name : ${_principalNameController.text}'),
              pw.Row(
                children: [
                  pw.Text('Contact No.: ${_principalContactController.text}'),
                  pw.SizedBox(width: 20),
                  pw.Text('Date of Birth : ${_principalDobController.text}'),
                  pw.SizedBox(width: 20),
                  pw.Text('Date of Anniversary: ${_principalAnniversaryController.text}'),
                ],
              ),
              pw.SizedBox(height: 10),

              // 5. Agent Details
              pw.Text('5. Agent Name: ${_agentNameController.text}'),
              pw.Text('Agent Manager : ${_agentManagerController.text}'),
              pw.SizedBox(height: 10),

              // 6. Dates
              pw.Text('6. Order Date : ${_orderDateController.text}'),
              pw.Text('Delivery Date : ${_deliveryDateController.text}'),
              pw.SizedBox(height: 10),

              // 7. PAN and Aadhar
              pw.Text('7. PAN CARD NO. : ${_panCardController.text}'),
              pw.Text('ADHAR NO. : ${_aadharController.text}'),
              pw.SizedBox(height: 10),

              // 8. Account Details
              pw.Text('8. Account No.1 : ${_accountNoController.text}'),
              pw.Text('Bank Details : ${_bankDetailsController.text}'),
              pw.SizedBox(height: 10),

              // 9. Cheque Details
              pw.Text('9. Cheque No. : ${_chequeNoController.text}'),
              pw.Text('Security cheque is compulsory'),
              pw.SizedBox(height: 10),

              // 10. Payment Term & Condition
              pw.Text('10. Payment Term & Condition'),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUGUST', 'SEP', 'OCT', 'NOV', 'DEC'],
                ],
              ),
              pw.SizedBox(height: 10),

              // 11. Discount Slab
              pw.Text('11. Discount Slab in series'),
              pw.Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    pw.Expanded(
                      child: pw.Text('${i + 1}. ${_discountControllers[i].text}'),
                    ),
                ],
              ),
              pw.Row(
                children: [
                  for (int i = 4; i < 8; i++)
                    pw.Expanded(
                      child: pw.Text('${i + 1}. ${_discountControllers[i].text}'),
                    ),
                ],
              ),
              pw.SizedBox(height: 10),

              // 12. Other Agreement
              pw.Text('12. Other Agreement with written'),
              pw.Text(_agreementController.text),
              pw.SizedBox(height: 20),

              // Rules in Hindi
              pw.Text('नियम एवं सदै'),
              pw.Text('1. श्रेणी (अतररक्षक/मैनेशर/एवेंट के द्वारा) किसी प्रकार का डिस्क्रिप्ट या नीकिड पहाड़ी स्कीमार नहीं करेगी | श्रेणी कम्पने नियम या खोटी का निश्चित रूप में स्कीमार करेगी |'),
              pw.SizedBox(height: 5),
              pw.Text('2. अक्टूबर से के पास अक्टूबर पास करने पर श्रेणी से योजि अक्टूबर से पास पहाड़ा और सदस्यत बन गये थे।'),
              pw.SizedBox(height: 5),
              pw.Text('3. अक्टूबर एवं अक्टूबर के पास अक्टूबर एवं द्वारा है दो 10 % प्रतिशत माना के हिसाब से पैसा पास करना होगा।'),
              pw.SizedBox(height: 5),
              pw.Text('4. 15 डिस्क्रिप्ट का एकांटेड निकल रा होगा की यहा है 2.5 % प्रतिशत माना के हिसाब से पैसा होगा।'),
              pw.SizedBox(height: 5),
              pw.Text('5. एवं अक्टूबर के श्रेणी के द्वारा किया गया। एवं अक्टूबर के पास नहीं किया गया।'),
              pw.SizedBox(height: 5),
              pw.Text('6. निजी प्रकार के अनुभव या होने पर योजिप्रूट मानकर ही माना होगा।'),
              pw.SizedBox(height: 5),
              pw.Text('7. निजीत एवं पैसा या कम्पनेट निकेला निए यदि यहा कम पूर्ण स्थानत करने के निए यात्म होगा।'),
              pw.SizedBox(height: 5),
              pw.Text('8. निजीत द्वारा मानकर अनुभवी के अंतर्गत सदस्य नियम की मानकारी है।'),
              pw.SizedBox(height: 20),

              // Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Party\'s Signature.'),
                  pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to device
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/order_form_2026.pdf");
    await file.writeAsBytes(await pdf.save());

    // Show preview
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // 🔵 AppBar background
        title: const Text(
          'Order Form 2026',
          style: TextStyle(
            color: Colors.black, //
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, //
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf,
              color: Colors.black,
            ),
            onPressed: _generatePDF,
            tooltip: 'Generate PDF',
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildTextField('1. Name of Party', _partyNameController),
              const SizedBox(height: 10),

              _buildTextField('2. Name & Address of School', _schoolNameController),
              Row(
                children: [
                  Expanded(child: _buildTextField('District', _districtController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField('Block', _blockController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField('Area', _areaController)),
                ],
              ),
              const SizedBox(height: 10),

              _buildTextField('3. Manager\'s Name', _managerNameController),
              Row(
                children: [
                  Expanded(child: _buildTextField('Contact No.', _managerContactController, keyboardType: TextInputType.phone)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField('Date of Birth', _managerDobController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField('Date of Anniversary', _managerAnniversaryController)),
                ],
              ),
              const SizedBox(height: 10),

              _buildTextField('4. Principal\'s Name', _principalNameController),
              Row(
                children: [
                  Expanded(child: _buildTextField('Contact No.', _principalContactController, keyboardType: TextInputType.phone)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField('Date of Birth', _principalDobController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField('Date of Anniversary', _principalAnniversaryController)),
                ],
              ),
              const SizedBox(height: 10),

              _buildTextField('5. Agent Name', _agentNameController),
              _buildTextField('Agent Manager', _agentManagerController),
              const SizedBox(height: 10),

              _buildTextField('6. Order Date', _orderDateController),
              _buildTextField('Delivery Date', _deliveryDateController),
              const SizedBox(height: 10),

              _buildTextField('7. PAN CARD NO.', _panCardController),
              _buildTextField('ADHAR NO.', _aadharController),
              const SizedBox(height: 10),

              _buildTextField('8. Account No.1', _accountNoController),
              _buildTextField('Bank Details', _bankDetailsController),
              const SizedBox(height: 10),

              _buildTextField('9. Cheque No.', _chequeNoController),
              const Text('Security cheque is compulsory', style: TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 10),

              const Text('10. Payment Term & Condition', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey[200],
                child: const Text('JAN FEB MAR APR MAY JUN JUL AUGUST SEP OCT NOV DEC'),
              ),
              const SizedBox(height: 10),

              const Text('11. Discount Slab in series', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < 8; i++)
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _discountControllers[i],
                        decoration: InputDecoration(
                          labelText: '${i + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              const Text('12. Other Agreement with written', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _agreementController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter agreement details...',
                ),
              ),
              const SizedBox(height: 20),

              // Rules section
              const Text('नियम एवं सदै', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('1. श्रेणी (अतररक्षक/मैनेशर/एवेंट के द्वारा) किसी प्रकार का डिस्क्रिप्ट या नीकिड पहाड़ी स्कीमार नहीं करेगी | श्रेणी कम्पने नियम या खोटी का निश्चित रूप में स्कीमार करेगी |'),
              const SizedBox(height: 5),
              const Text('2. अक्टूबर से के पास अक्टूबर पास करने पर श्रेणी से योजि अक्टूबर से पास पहाड़ा और सदस्यत बन गये थे।'),
              const SizedBox(height: 5),
              const Text('3. अक्टूबर एवं अक्टूबर के पास अक्टूबर एवं द्वारा है दो 10 % प्रतिशत माना के हिसाब से पैसा पास करना होगा।'),
              const SizedBox(height: 5),
              const Text('4. 15 डिस्क्रिप्ट का एकांटेड निकल रा होगा की यहा है 2.5 % प्रतिशत माना के हिसाब से पैसा होगा।'),
              const SizedBox(height: 5),
              const Text('5. एवं अक्टूबर के श्रेणी के द्वारा किया गया। एवं अक्टूबर के पास नहीं किया गया।'),
              const SizedBox(height: 5),
              const Text('6. निजी प्रकार के अनुभव या होने पर योजिप्रूट मानकर ही माना होगा।'),
              const SizedBox(height: 5),
              const Text('7. निजीत एवं पैसा या कम्पनेट निकेला निए यदि यहा कम पूर्ण स्थानत करने के निए यात्म होगा।'),
              const SizedBox(height: 5),
              const Text('8. निजीत द्वारा मानकर अनुभवी के अंतर्गत सदस्य नियम की मानकारी है।'),
              const SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: _generatePDF,
                child: const Text('Generate PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
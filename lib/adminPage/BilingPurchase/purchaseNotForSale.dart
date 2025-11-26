import 'package:flutter/material.dart';

class PurchaseForSale extends StatefulWidget {
  const PurchaseForSale({super.key});

  @override
  State<PurchaseForSale> createState() => _PurchaseForSaleState();
}

class _PurchaseForSaleState extends State<PurchaseForSale> {
  final TextEditingController billNoController = TextEditingController();
  final TextEditingController recDateController = TextEditingController();
  final TextEditingController supBillController = TextEditingController();
  final TextEditingController grNoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedPublication;
  String? selectedTransport;

  final List<String> publications = [
    'Publication A',
    'Publication B',
    'Publication C',
    'Publication D with very long name that might cause overflow',
    'Publication E',
  ];

  final List<String> transports = [
    'Transport 1',
    'Transport 2',
    'Transport 3',
    'Transport 4 with very long transport name',
    'Transport 5',
  ];

  // Reusable constants
  static const _labelTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: Colors.grey),
  );
  static const _inputPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 12);
  static const _sectionSpacing = SizedBox(height: 16);
  static const _rowSpacing = SizedBox(width: 12);

  @override
  void initState() {
    super.initState();
    _setCurrentDate();
  }

  @override
  void dispose() {
    billNoController.dispose();
    recDateController.dispose();
    supBillController.dispose();
    grNoController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _setCurrentDate() {
    final now = DateTime.now();
    final formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    recDateController.text = formattedDate;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.cyan,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.cyan,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {
        recDateController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Purchase Not For Sale Entry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              _handlePopupMenuSelection(value);
            },
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Settings', 'Help', 'Logout'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField('Bill No.', billNoController,
                              hint: 'Enter bill number'),
                          _sectionSpacing,
                          _buildDateField(),
                          _sectionSpacing,

                          // Row layout responsive
                          if (isSmallScreen) ...[
                            _buildTextField('Sup. Bill No', supBillController),
                            _sectionSpacing,
                            _buildTextField('Gr No.', grNoController),
                            _sectionSpacing,
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                      'Sup. Bill No', supBillController),
                                ),
                                _rowSpacing,
                                Expanded(
                                  child: _buildTextField(
                                      'Gr No.', grNoController),
                                ),
                              ],
                            ),
                            _sectionSpacing,
                          ],

                          // Dropdowns
                          if (isSmallScreen) ...[
                            _buildDropdown(
                              label: 'Publication',
                              value: selectedPublication,
                              items: publications,
                              onChanged: (value) {
                                setState(() => selectedPublication = value);
                              },
                            ),
                            _sectionSpacing,
                            _buildDropdown(
                              label: 'Transport',
                              value: selectedTransport,
                              items: transports,
                              onChanged: (value) {
                                setState(() => selectedTransport = value);
                              },
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                    label: 'Publication',
                                    value: selectedPublication,
                                    items: publications,
                                    onChanged: (value) {
                                      setState(() =>
                                      selectedPublication = value);
                                    },
                                  ),
                                ),
                                _rowSpacing,
                                Expanded(
                                  child: _buildDropdown(
                                    label: 'Transport',
                                    value: selectedTransport,
                                    items: transports,
                                    onChanged: (value) {
                                      setState(() =>
                                      selectedTransport = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],

                          _sectionSpacing,
                          _buildTextField('Address', addressController,
                              maxLines: 3),
                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 20),
                          _buildActionButtons(isSmallScreen),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildFooter(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        String? hint,
        bool readOnly = false,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelTextStyle),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            border: _inputBorder,
            enabledBorder: _inputBorder,
            focusedBorder: _inputBorder.copyWith(
              borderSide: const BorderSide(color: Colors.cyan),
            ),
            contentPadding: _inputPadding,
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[50] : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rec. Date', style: _labelTextStyle),
        const SizedBox(height: 6),
        TextField(
          controller: recDateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            border: _inputBorder,
            enabledBorder: _inputBorder,
            focusedBorder: _inputBorder.copyWith(
              borderSide: const BorderSide(color: Colors.cyan),
            ),
            contentPadding: _inputPadding,
            suffixIcon: IconButton(
              icon:
              const Icon(Icons.calendar_today, size: 20, color: Colors.cyan),
              onPressed: _selectDate,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onTap: _selectDate,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelTextStyle),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item,
                overflow: TextOverflow.ellipsis, maxLines: 1),
          ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '-- Select $label --',
            border: _inputBorder,
            enabledBorder: _inputBorder,
            focusedBorder: _inputBorder.copyWith(
              borderSide: const BorderSide(color: Colors.cyan),
            ),
            contentPadding: _inputPadding,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    return isSmallScreen
        ? Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _saveEntry,
            child: const Text(
              'Save Entry',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _goToView,
            child: const Text(
              'Go to View',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
      ],
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _saveEntry,
            child: const Text(
              'Save Entry',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _goToView,
            child: const Text(
              'Go to View',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // Footer buttons
  Widget _buildFooter() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterTextButton(
            text: 'Home',
            onPressed: _navigateToHome,
            icon: Icons.home,
            textColor: Colors.blue[700],
          ),
          _buildFooterTextButton(
            text: 'Day Book',
            onPressed: _navigateToDayBook,
            icon: Icons.book,
            textColor: Colors.green[700],
          ),
          _buildFooterTextButton(
            text: 'Attendance',
            onPressed: _navigateToAttendanceHistory,
            icon: Icons.history,
            textColor: Colors.orange[700],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterTextButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor ?? Colors.blue[700]),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Extra Helper Functions ---
  void _saveEntry() {
    if (_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form saved successfully!')),
      );
    }
  }

  void _goToView() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to View Page...')),
    );
  }

  bool _validateForm() {
    if (billNoController.text.isEmpty) {
      _showSnackBar('Please enter Bill No.');
      return false;
    }
    if (selectedPublication == null) {
      _showSnackBar('Please select Publication');
      return false;
    }
    if (selectedTransport == null) {
      _showSnackBar('Please select Transport');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _refreshData() {
    setState(() {
      billNoController.clear();
      supBillController.clear();
      grNoController.clear();
      addressController.clear();
      selectedPublication = null;
      selectedTransport = null;
      _setCurrentDate();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form refreshed'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handlePopupMenuSelection(String value) {
    switch (value) {
      case 'Profile':
        _showSnackBar('Opening Profile...');
        break;
      case 'Settings':
        _showSnackBar('Opening Settings...');
        break;
      case 'Help':
        _showSnackBar('Opening Help...');
        break;
      case 'Logout':
        _showSnackBar('Logging out...');
        break;
    }
  }

  void _navigateToHome() {
    _showSnackBar('Navigating to Home');
  }

  void _navigateToDayBook() {
    _showSnackBar('Navigating to Day Book');
  }

  void _navigateToAttendanceHistory() {
    _showSnackBar('Navigating to Attendance History');
  }
}

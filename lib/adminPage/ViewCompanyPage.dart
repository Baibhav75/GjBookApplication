import 'package:flutter/material.dart';
import '/Model/ViewCompany_model.dart';
import '/Service/ViewCompany_service.dart';
class ViewCompanyPage extends StatefulWidget {
  const ViewCompanyPage({super.key});

  @override
  State<ViewCompanyPage> createState() => _ViewCompanyPageState();
}

class _ViewCompanyPageState extends State<ViewCompanyPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<ViewCompanyModel?> _companiesFuture;
  List<PublicationList> _allCompanies = [];
  List<PublicationList> _filteredCompanies = [];

  VoidCallback? get _refreshData => null;

  @override
  void initState() {
    super.initState();
    _companiesFuture = _loadCompanies();
  }

  Future<ViewCompanyModel?> _loadCompanies() async {
    try {
      final companies = await ViewCompanyService.getCompanies();
      if (companies != null && companies.publicationList != null) {
        _allCompanies = companies.publicationList!;
        _filteredCompanies = _allCompanies;

        // Debug: Print loaded companies
        print('Loaded ${_allCompanies.length} companies');
        if (_allCompanies.isNotEmpty) {
          print('First company discount rate: ${_allCompanies.first.discountRate} (type: ${_allCompanies.first.discountRate.runtimeType})');
        }
      }
      return companies;
    } catch (e) {
      print('Error loading companies: $e');
      rethrow;
    }
  }

  void _filterCompanies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCompanies = _allCompanies;
      });
      return;
    }

    setState(() {
      _filteredCompanies = _allCompanies.where((company) {
        return _companyMatchesQuery(company, query.toLowerCase());
      }).toList();
    });
  }

  bool _companyMatchesQuery(PublicationList company, String query) {
    return (company.publication?.toLowerCase().contains(query) == true) ||
        (company.groups?.toLowerCase().contains(query) == true) ||
        (company.address?.toLowerCase().contains(query) == true) ||
        (company.email?.toLowerCase().contains(query) == true) ||
        (company.mobileNo?.toLowerCase().contains(query) == true) ||
        (company.gstNo?.toLowerCase().contains(query) == true) ||
        (company.websitelink?.toLowerCase().contains(query) == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Company'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: ArgumentError.notNull,
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white, //
            ),
            onPressed: _refreshData,
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              _handlePopupMenuSelection(value);
            },
            itemBuilder: (BuildContext context) {
              return {'Profile', 'Settings', 'Help', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),

        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<ViewCompanyModel?>(
                future: _companiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingIndicator();
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error!);
                  } else if (snapshot.hasData) {
                    return _buildCompaniesTable();
                  } else {
                    return _buildNoDataWidget();
                  }
                },
              ),
            ),
            // Footer Buttons
            _buildFooter(),
          ],
        ),
      ),
    );
  }



  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _filterCompanies,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        hintText: "Search by company name, email, mobile...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }


  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading companies...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    String errorMessage = 'An error occurred';
    String detailedError = error.toString();

    if (error is ApiException) {
      errorMessage = error.message;
    } else if (error.toString().contains('double') && error.toString().contains('int')) {
      errorMessage = 'Data type mismatch in API response';
      detailedError = 'The server returned unexpected data types. This has been fixed. Please refresh.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              detailedError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _companiesFuture = _loadCompanies();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // Show more detailed error info
                    _showErrorDetails(error);
                  },
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDetails(Object error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Text(
            error.toString(),
            style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business_center, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No companies found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'No companies available'
                : 'No companies match your search',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCompaniesTable() {
    if (_filteredCompanies.isEmpty) {
      return _buildNoDataWidget();
    }

    return Column(
      children: [
        _buildResultsCount(),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.lightBlue.shade50),
              columnSpacing: 20,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 80,
              columns: const [
                DataColumn(label: Text('Sr No', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Group', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('GST No', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Discount', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _filteredCompanies.asMap().entries.map((entry) {
                final index = entry.key;
                final company = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(
                      Tooltip(
                        message: company.publication ?? 'N/A',
                        child: Text(
                          company.publication ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(Text(company.groups ?? 'N/A')),
                    DataCell(Text(company.email ?? 'N/A')),
                    DataCell(Text(company.mobileNo ?? 'N/A')),
                    DataCell(Text(company.gstNo ?? 'N/A')),
                    DataCell(Text(company.discountRateDisplay)),
                    DataCell(_buildActionMenu(company)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${_filteredCompanies.length} of ${_allCompanies.length} companies',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        if (_searchController.text.isNotEmpty)
          TextButton(
            onPressed: () {
              _searchController.clear();
              _filterCompanies('');
            },
            child: const Text('Clear Search'),
          ),
      ],
    );
  }

  Widget _buildActionMenu(PublicationList company) {
    return PopupMenuButton<String>(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) => _handleAction(value, company),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Actions', style: TextStyle(color: Colors.white, fontSize: 12)),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, PublicationList company) {
    switch (action) {
      case 'view':
        _showCompanyDetails(company);
        break;
      case 'edit':
        _editCompany(company);
        break;
    }
  }

  void _showCompanyDetails(PublicationList company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Company Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Company Name', company.publication),
              _buildDetailItem('Code', company.code),
              _buildDetailItem('Group', company.groups),
              _buildDetailItem('Email', company.email),
              _buildDetailItem('Mobile No', company.mobileNo),
              _buildDetailItem('GST No', company.gstNo),
              _buildDetailItem('Address', company.address),
              _buildDetailItem('Discount Rate', company.discountRateDisplay),
              _buildDetailItem('Website', company.websitelink),
              _buildDetailItem('Agreement Form', company.agreementForm),
              _buildDetailItem('Create Date', company.createDate),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _editCompany(PublicationList company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${company.publication}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToHome() {
    // TODO: Implement navigation to Home screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Home'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToDayBook() {
    // TODO: Implement navigation to Day Book screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Day Book'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToAttendanceHistory() {
    // TODO: Implement navigation to Attendance History screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Attendance History'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: textColor ?? Colors.blue[700],
            ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

void _handlePopupMenuSelection(String value) {
}
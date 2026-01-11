import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Model/publication_agreement_model.dart';

import '../Service/publication_agreement_service.dart';


class PublicationListPage extends StatefulWidget {
  const PublicationListPage({Key? key}) : super(key: key);

  @override
  State<PublicationListPage> createState() => _PublicationListPageState();
}

class _PublicationListPageState extends State<PublicationListPage> {
  late Future<PublicationListModel> _futurePublications;
  List<Publication> _filteredPublications = [];
  TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'SUPPORT-A', 'SUPPORT-B', 'SUPPORT-C', 'SUPPORT-D'];

  @override
  void initState() {
    super.initState();
    _futurePublications = PublicationService.getPublications();
  }

  void _refreshData() {
    setState(() {
      _futurePublications = PublicationService.getPublications();
      _searchController.clear();
      _selectedFilter = 'All';
    });
  }

  void _filterPublications(String query) {
    if (_futurePublications == null) return;

    _futurePublications.then((data) {
      setState(() {
        if (query.isEmpty && _selectedFilter == 'All') {
          _filteredPublications = data.publicationList;
        } else {
          _filteredPublications = data.publicationList.where((publication) {
            final matchesSearch = publication.publicationName
                .toLowerCase()
                .contains(query.toLowerCase());

            final matchesFilter = _selectedFilter == 'All' ||
                publication.type == _selectedFilter;

            return matchesSearch && matchesFilter;
          }).toList();
        }
      });
    });
  }

  void _showPublicationDetails(Publication publication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          publication.publicationName,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID:', '${publication.id}'),
              _buildDetailRow('Address:', publication.address),
              _buildDetailRow('Mobile:', publication.mobileNo ?? 'N/A'),
              _buildDetailRow('Email:', publication.email ?? 'N/A'),
              _buildDetailRow('Type:', publication.type ?? 'N/A'),
              _buildDetailRow('Group:', publication.groups ?? 'N/A'),
              _buildDetailRow('Target:', publication.target?.toString() ?? 'N/A'),
              _buildDetailRow('Created:',
                  DateFormat('dd-MM-yyyy').format(publication.createDate)),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              Text('Contact Persons',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),

              _buildContactRow('Area Manager:',
                  publication.areaManagerName,
                  publication.areaManagerMoNo),
              _buildContactRow('Sales Head:',
                  publication.salesHeadName,
                  publication.salesHeadMoNo),
              _buildContactRow('Local Sales Head:',
                  publication.localSalesHeadName,
                  publication.localSalesHeadMoNo),
              _buildContactRow('Zone Head:',
                  publication.zonelHeadName,
                  publication.zonelHeadMoNo),

              if (publication.ownerName != null && publication.ownerName!.isNotEmpty)
                _buildContactRow('Owner:',
                    publication.ownerName!,
                    publication.ownerMoNo ?? ''),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              Text('Documents',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),

              if (publication.agrementFile != null && publication.agrementFile!.isNotEmpty)
                _buildDocumentRow('Agreement File', publication.agrementFile!),

              if (publication.checks != null && publication.checks!.isNotEmpty)
                _buildDocumentRow('Check Document', publication.checks!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String title, String name, String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Row(
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (phone.isNotEmpty && phone != 'NA' && phone != '00')
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '($phone)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.green[700],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String label, String filePath) {
    final fullUrl = PublicationService.getFullImageUrl(filePath);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4,
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fullUrl,
                height: 200,
                // width removed to prevent unbounded width error
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 50,
                    // width removed
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Image not available',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    // width removed
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterOptions.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'All';
                  _filterPublications(_searchController.text);
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
              labelStyle: GoogleFonts.poppins(
                color: _selectedFilter == filter ? Colors.blue[800] : Colors.grey[700],
                fontWeight: _selectedFilter == filter ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPublicationCard(Publication publication) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    publication.publicationName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (publication.type != null && publication.type!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(publication.type!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      publication.type!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    publication.address,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (publication.mobileNo != null && publication.mobileNo!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    publication.mobileNo!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(publication.createDate),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    if (publication.agrementFile != null && publication.agrementFile!.isNotEmpty)
                      const Icon(Icons.attach_file, size: 16, color: Colors.blue),
                    if (publication.checks != null && publication.checks!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: const Icon(Icons.receipt, size: 16, color: Colors.green),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showPublicationDetails(publication),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'SUPPORT-A':
        return Colors.green[800]!;
      case 'SUPPORT-B':
        return Colors.blue[800]!;
      case 'SUPPORT-C':
        return Colors.orange[800]!;
      case 'SUPPORT-D':
        return Colors.red[800]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildDataTable(List<Publication> publications) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
        columnSpacing: 20,
        horizontalMargin: 16,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Publication')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Address')),
          DataColumn(label: Text('Mobile')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Created Date')),
          DataColumn(label: Text('Actions')),
        ],
        rows: publications.map((publication) {
          return DataRow(
            cells: [
              DataCell(Text('${publication.id}')),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    publication.publicationName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(publication.type ?? ''),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    publication.type ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    publication.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(publication.mobileNo ?? '-')),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(
                    publication.email ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Text(DateFormat('dd-MM-yyyy').format(publication.createDate)),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  onPressed: () => _showPublicationDetails(publication),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Publication List',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<PublicationListModel>(
        future: _futurePublications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            final data = snapshot.data!;

            // Initialize filtered list
            if (_filteredPublications.isEmpty) {
              _filteredPublications = data.publicationList;
            }

            return Column(
              children: [
                // Search and Filter Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search publications...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterPublications('');
                            },
                          )
                              : null,
                        ),
                        onChanged: _filterPublications,
                      ),

                      const SizedBox(height: 16),

                      // Filter Chips
                      _buildFilterChips(),

                      const SizedBox(height: 16),

                      // Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ${data.publicationList.length} publications',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Showing: ${_filteredPublications.length}',
                            style: GoogleFonts.poppins(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Data Display
                Expanded(
                  child: _filteredPublications.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No publications found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: _filteredPublications.length,
                    itemBuilder: (context, index) {
                      return _buildPublicationCard(_filteredPublications[index]);
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }
}
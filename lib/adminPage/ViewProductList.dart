import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bookworld/Model/ViewProductList_model.dart';
import 'package:bookworld/Service/ViewProductList_service.dart';

class ViewProductList extends StatefulWidget {
  const ViewProductList({super.key});

  @override
  State<ViewProductList> createState() => _ViewProductListState();
}

class _ViewProductListState extends State<ViewProductList> {
  final TextEditingController _searchController = TextEditingController();
  final ViewProductListService _productService = ViewProductListService();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  VoidCallback? get _refreshData => null;

  @override
  void initState() {
    super.initState();
    _fetchProductList();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductList() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _productService.getProductList();

      if (!mounted || _isDisposed) return;

      if (response.isSuccess && response.productList != null) {
        setState(() {
          _allProducts = response.productList!;
          _filteredProducts = _allProducts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load products';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          return (product.itemTitle?.toLowerCase().contains(query) ?? false) ||
              (product.itemCode?.toLowerCase().contains(query) ?? false) ||
              (product.publication?.toLowerCase().contains(query) ?? false) ||
              (product.series?.toLowerCase().contains(query) ?? false) ||
              (product.subject?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Product Management'),
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
      body: Column(
        children: [
          // Search Box
          _buildSearchBox(),

          // Results Count
          if (!_isLoading && _errorMessage == null) _buildResultsCount(),

          const SizedBox(height: 10),



        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            hintText: "Search by Title, Code, Publication, Series, or Subject",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Showing ${_filteredProducts.length} of ${_allProducts.length} products',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading products...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_filteredProducts.isEmpty) {
      return _buildEmptyWidget();
    }

    return _buildProductTable();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchProductList,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'No products available'
                : 'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Scrollbar(
        controller: _verticalScrollController,
        thumbVisibility: true,
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          notificationPredicate: (notif) => notif.depth == 1,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.blue[50]!,
                ),
                columnSpacing: 20,
                horizontalMargin: 16,
                dataRowMinHeight: 50,
                dataRowMaxHeight: 70,
                columns: const [
                  DataColumn(
                    label: Text("Sr No", style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text("Publication", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Series", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Item Code", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Item Title", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Rate", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Discount", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: List.generate(
                  _filteredProducts.length,
                      (index) => _buildDataRow(index, _filteredProducts[index]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(int index, ProductModel product) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (index.isEven) {
            return Colors.grey[50];
          }
          return null;
        },
      ),
      cells: [
        DataCell(Center(child: Text('${index + 1}'))),
        DataCell(
          SizedBox(
            width: 120,
            child: Tooltip(
              message: product.publication ?? 'N/A',
              child: Text(
                product.publication ?? 'N/A',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Tooltip(
              message: product.series ?? 'N/A',
              child: Text(
                product.series ?? 'N/A',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: product.itemCode ?? 'N/A',
            child: Text(product.itemCode ?? 'N/A'),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Tooltip(
              message: product.itemTitle ?? 'N/A',
              child: Text(
                product.itemTitle ?? 'N/A',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: product.subject ?? 'N/A',
            child: Text(product.subject ?? 'N/A'),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              product.getFormattedRate() ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              product.discount != null
                  ? '₹${product.discount!.toStringAsFixed(2)}'
                  : 'N/A',
              style: TextStyle(
                color: product.discount != null ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Text(
              _formatDate(product.createDate),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
        DataCell(
          _buildActionButtons(product),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ProductModel product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(60, 32),
          ),
          onPressed: () => _handleEdit(product),
          child: const Text("Edit", style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(60, 32),
          ),
          onPressed: () => _handleDelete(product),
          child: const Text("Delete", style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  void _handleEdit(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit product: ${product.itemTitle ?? 'N/A'}'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.itemTitle ?? 'N/A'}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Delete product: ${product.itemTitle ?? 'N/A'}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

void _handlePopupMenuSelection(String value) {
}
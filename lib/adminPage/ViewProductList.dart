import 'dart:async';
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

  // Performance optimizations
  Timer? _searchDebounce;
  final Map<String, String> _dateCache = {}; // Cache formatted dates
  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchProductList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
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
        // Clear cache when new data arrives
        _dateCache.clear();

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

  // Debounced search to reduce rebuilds
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _filterProducts();
    });
  }

  // Optimized filtering with better performance
  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _allProducts;
      });
      return;
    }

    final filtered = _allProducts.where((product) {
      final title = product.itemTitle?.toLowerCase() ?? '';
      final code = product.itemCode?.toLowerCase() ?? '';
      final publication = product.publication?.toLowerCase() ?? '';
      final series = product.series?.toLowerCase() ?? '';
      final subject = product.subject?.toLowerCase() ?? '';

      return title.contains(query) ||
          code.contains(query) ||
          publication.contains(query) ||
          series.contains(query) ||
          subject.contains(query);
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

  // Cached date formatting for better performance
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    if (_dateCache.containsKey(dateString)) {
      return _dateCache[dateString]!;
    }

    try {
      final date = DateTime.parse(dateString);
      final formatted = _dateFormatter.format(date);
      _dateCache[dateString] = formatted;
      return formatted;
    } catch (e) {
      return dateString;
    }
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _fetchProductList,
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

          // Product List/Table
          Expanded(
            child: _buildContent(),
          ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 1200;

        return Container(
          margin: const EdgeInsets.all(8),
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
            controller: isSmallScreen ? null : _horizontalScrollController,
            thumbVisibility: true,
            child: isSmallScreen
                ? _buildMobileTable()
                : _buildDesktopTable(constraints.maxWidth),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(double maxWidth) {
    final double tableWidth = maxWidth * 0.95;

    return SingleChildScrollView(
      controller: _horizontalScrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: tableWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(),
            Expanded(
              child: Scrollbar(
                controller: _verticalScrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _verticalScrollController,
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildTableRow(index, _filteredProducts[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTable() {
    return ListView.builder(
      controller: _verticalScrollController,
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildMobileProductCard(_filteredProducts[index], index);
      },
    );
  }

  Widget _buildMobileProductCard(ProductModel product, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.itemTitle ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.itemCode ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMobileDetailRow('Publication', product.publication ?? 'N/A'),
            _buildMobileDetailRow('Series', product.series ?? 'N/A'),
            _buildMobileDetailRow('Subject', product.subject ?? 'N/A'),
            Row(
              children: [
                Expanded(
                  child: _buildMobileDetailRow(
                    'Rate',
                    product.getFormattedRate() ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMobileDetailRow(
                    'Discount',
                    product.discount != null
                        ? '₹${product.discount!.toStringAsFixed(2)}'
                        : 'N/A',
                  ),
                ),
              ],
            ),
            _buildMobileDetailRow('Date', _formatDate(product.createDate)),
            const SizedBox(height: 12),
            _buildMobileActionButtons(product),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionButtons(ProductModel product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMobileActionButton(
          icon: Icons.visibility,
          label: 'View',
          color: Colors.blue[700]!,
          onPressed: () => _handleViewDetails(product),
        ),
        _buildMobileActionButton(
          icon: Icons.edit,
          label: 'Edit',
          color: Colors.amber[700]!,
          onPressed: () => _handleEdit(product),
        ),
        _buildMobileActionButton(
          icon: Icons.delete,
          label: 'Delete',
          color: Colors.redAccent[700]!,
          onPressed: () => _handleDelete(product),
        ),
      ],
    );
  }

  Widget _buildMobileActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildHeaderCell("Sr No", 60),
          _buildHeaderCell("Publication", 120),
          _buildHeaderCell("Series", 100),
          _buildHeaderCell("Item Code", 100),
          _buildHeaderCell("Item Title", 150),
          _buildHeaderCell("Subject", 100),
          _buildHeaderCell("Rate", 100),
          _buildHeaderCell("Discount", 100),
          _buildHeaderCell("Date", 120),
          _buildHeaderCell("Action", 180),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableRow(int index, ProductModel product) {
    return Container(
      color: index.isEven ? Colors.grey[50] : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableCell('${index + 1}', 60, TextAlign.center),
          _buildTableCell(product.publication ?? 'N/A', 120, TextAlign.left),
          _buildTableCell(product.series ?? 'N/A', 100, TextAlign.left),
          _buildTableCell(product.itemCode ?? 'N/A', 100, TextAlign.left),
          _buildTableCell(product.itemTitle ?? 'N/A', 150, TextAlign.left),
          _buildTableCell(product.subject ?? 'N/A', 100, TextAlign.left),
          _buildTableCell(
            product.getFormattedRate() ?? 'N/A',
            100,
            TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          _buildTableCell(
            product.discount != null
                ? '₹${product.discount!.toStringAsFixed(2)}'
                : 'N/A',
            100,
            TextAlign.center,
            style: TextStyle(
              color: product.discount != null ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          _buildTableCell(
            _formatDate(product.createDate),
            120,
            TextAlign.left,
            style: const TextStyle(fontSize: 11),
          ),
          SizedBox(
            width: 180,
            child: _buildActionButtons(product),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, double width, TextAlign align, {TextStyle? style}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        style: style,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget _buildActionButtons(ProductModel product) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(55, 32),
          ),
          onPressed: () => _handleViewDetails(product),
          child: const Text("View", style: TextStyle(fontSize: 11)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(55, 32),
          ),
          onPressed: () => _handleEdit(product),
          child: const Text("Edit", style: TextStyle(fontSize: 11)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(55, 32),
          ),
          onPressed: () => _handleDelete(product),
          child: const Text("Delete", style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }

  void _handleViewDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Product Details',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: _buildDetailCard(product),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailCard(ProductModel product) {
    final rates = product.getAllRates();
    final availableRates = rates.entries
        .where((entry) => entry.value != null)
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.hasImage) ...[
              _buildProductImage(product),
              const SizedBox(height: 16),
            ],

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.itemTitle ?? 'N/A',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Item Code: ${product.itemCode ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 8),
            _buildDetailRow('Series', product.series ?? 'N/A'),
            _buildDetailRow('Subject', product.subject ?? 'N/A'),
            _buildDetailRow('Publication', product.publication ?? 'N/A'),
            _buildDetailRow('Class', product.classField ?? 'N/A'),
            _buildDetailRow('Discount',
                product.discount != null
                    ? '₹${product.discount!.toStringAsFixed(2)}'
                    : 'N/A'
            ),
            _buildDetailRow('Created Date', _formatDate(product.createDate)),

            const SizedBox(height: 16),

            _buildSectionTitle('Pricing Details'),
            const SizedBox(height: 8),
            if (availableRates.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No rates available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              )
            else
              ...availableRates.map((rate) => _buildDetailRow(
                rate.key,
                '₹${rate.value!.toStringAsFixed(2)}',
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: () => _showImageFullScreen(product.imageUrl!),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showImageFullScreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 64,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
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

  void _handlePopupMenuSelection(String value) {
    switch (value) {
      case 'Profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile selected')),
        );
        break;
      case 'Settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings selected')),
        );
        break;
      case 'Help':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Help selected')),
        );
        break;
      case 'Logout':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout selected')),
        );
        break;
    }
  }
}
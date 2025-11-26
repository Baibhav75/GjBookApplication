// pages/day_book_history.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/Model/transaction_models.dart';
import '/Service/transaction_service.dart';

class DayBookHistory extends StatefulWidget {
  const DayBookHistory({super.key});

  @override
  State<DayBookHistory> createState() => _DayBookHistoryState();
}

class _DayBookHistoryState extends State<DayBookHistory> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final TransactionService _transactionService = TransactionService();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String> _errorMessage = ValueNotifier<String>('');

  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  String _selectedFilter = 'Today';
  DateTimeRange _currentDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTransactions);
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _isLoading.dispose();
    _errorMessage.dispose();
    super.dispose();
  }

  void _initializeData() {
    _currentDateRange = _getDateRangeForFilter(_selectedFilter);
    _loadTransactions();
  }

  Future<void> _loadTransactions({bool forceRefresh = false}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await _transactionService.getTransactions(
        fromDate: _currentDateRange.start,
        toDate: _currentDateRange.end,
        forceRefresh: forceRefresh,
      );

      final allTransactions = response.getAllTransactions();
      
      // Apply client-side date filtering to ensure accuracy
      final filteredByDate = _filterTransactionsByDateRange(
        allTransactions,
        _currentDateRange,
      );

      if (mounted) {
        setState(() {
          _allTransactions = filteredByDate;
          _filteredTransactions = filteredByDate;
        });
      }
    } catch (e) {
      _errorMessage.value = e.toString();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// Gets the date range for the specified filter
  /// 
  /// - Today: Only today's date
  /// - Weekly: Today + past 7 days (8 days total)
  /// - Monthly: Current month only (from start of month to today)
  DateTimeRange _getDateRangeForFilter(String filter) {
    final now = DateTime.now();
    final todayStart = _getStartOfDay(now);
    final todayEnd = _getEndOfDay(now);

    switch (filter) {
      case 'Today':
        return DateTimeRange(start: todayStart, end: todayEnd);

      case 'Weekly':
        // Today + past 7 days (8 days total: today + 7 previous days)
        final sevenDaysAgo = todayStart.subtract(const Duration(days: 7));
        return DateTimeRange(start: sevenDaysAgo, end: todayEnd);

      case 'Monthly':
        // Current month only (from start of month to today)
        final startOfMonth = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: startOfMonth, end: todayEnd);

      default:
        return DateTimeRange(start: todayStart, end: todayEnd);
    }
  }

  /// Returns the start of the day (00:00:00) for the given date
  DateTime _getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the end of the day (23:59:59) for the given date
  DateTime _getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Filters transactions by date range to ensure they match the selected filter
  /// This provides client-side filtering to ensure accuracy regardless of API response
  List<Transaction> _filterTransactionsByDateRange(
    List<Transaction> transactions,
    DateTimeRange dateRange,
  ) {
    final rangeStart = dateRange.start;
    final rangeEnd = dateRange.end;
    
    return transactions.where((transaction) {
      try {
        final transactionDate = DateTime.parse(transaction.createdDateTime);
        
        // Check if transaction date falls within the range (inclusive on both ends)
        // rangeStart <= transactionDate <= rangeEnd
        return !transactionDate.isBefore(rangeStart) && !transactionDate.isAfter(rangeEnd);
      } catch (e) {
        // If date parsing fails, exclude the transaction
        return false;
      }
    }).toList();
  }


  /// Filters transactions based on search query
  /// Searches across: mobile number, particular name, remarks, voucher numbers, and transaction flag
  void _filterTransactions() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredTransactions = List.from(_allTransactions);
      } else {
        _filteredTransactions = _allTransactions.where(_matchesSearchQuery(query)).toList();
      }
    });
  }

  /// Returns a predicate function that checks if a transaction matches the search query
  bool Function(Transaction) _matchesSearchQuery(String query) {
    return (Transaction transaction) {
      return _containsIgnoreCase(transaction.mobileNo, query) ||
          _containsIgnoreCase(transaction.particularName, query) ||
          _containsIgnoreCase(transaction.remarks, query) ||
          _containsIgnoreCase(transaction.receiptBowcherNo, query) ||
          _containsIgnoreCase(transaction.expenseBowcherNo, query) ||
          _containsIgnoreCase(transaction.flag, query);
    };
  }

  /// Helper method to safely check if a string contains a query (case-insensitive)
  bool _containsIgnoreCase(String? text, String query) {
    if (text == null || text.isEmpty) return false;
    return text.toLowerCase().contains(query);
  }

  /// Handles filter change and automatically refreshes the transaction list
  void _handleFilterChange(String filter) {
    if (_selectedFilter == filter) return; // Avoid unnecessary reloads

    setState(() {
      _selectedFilter = filter;
      _currentDateRange = _getDateRangeForFilter(filter);
    });
    
    // Clear search when filter changes
    _searchController.clear();
    
    // Reload transactions with new date range
    _loadTransactions(forceRefresh: true);
  }

  /// Calculates total debit and credit amounts from a list of transactions
  ({double debit, double credit}) _calculateTotals(List<Transaction> transactions) {
    double totalDebit = 0.0;
    double totalCredit = 0.0;

    for (final transaction in transactions) {
      if (transaction.debit != null) {
        totalDebit += transaction.amount;
      } else if (transaction.credit != null) {
        totalCredit += transaction.amount;
      }
    }

    return (debit: totalDebit, credit: totalCredit);
  }

  String _formatCurrency(double amount) {
    return '₹${NumberFormat('#,##0.00').format(amount)}';
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd-MMM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  void _handleViewDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(transaction: transaction),
    );
  }

  void _handleViewImage(Transaction transaction) {
    if (transaction.hasImage) {
      showDialog(
        context: context,
        builder: (context) => ImageViewDialog(imageUrl: transaction.imageUrl),
      );
    }
  }

  void _handleRefresh() {
    _loadTransactions(forceRefresh: true);
  }

  Widget _buildImageCell(Transaction transaction) {
    if (!transaction.hasImage) {
      return const Text('No Image', style: TextStyle(color: Colors.grey));
    }

    return GestureDetector(
      onTap: () => _handleViewImage(transaction),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image, size: 16, color: Colors.blue),
            SizedBox(width: 4),
            Text('View', style: TextStyle(fontSize: 12, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Day Book History'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, child) {
              return isLoading
                  ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
                  : IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _handleRefresh,
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Search Box
          _buildSearchBox(),

          // Error Message
          ValueListenableBuilder<String>(
            valueListenable: _errorMessage,
            builder: (context, errorMessage, child) {
              return errorMessage.isNotEmpty ? _buildErrorMessage(errorMessage) : const SizedBox();
            },
          ),

          // Results Count and Summary
          _buildSummarySection(),

          const SizedBox(height: 8),

          // Content Area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterButton('Today', Icons.today),
              const SizedBox(width: 12),
              _buildFilterButton('Weekly', Icons.calendar_view_week),
              const SizedBox(width: 12),
              _buildFilterButton('Monthly', Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter, IconData icon) {
    final isSelected = _selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleFilterChange(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue[900]! : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
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
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _filterTransactions();
              },
            )
                : null,
            hintText: "Search by Mobile, Particular, Remarks, or Voucher No",
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (value) => _filterTransactions(),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red[700], size: 20),
              onPressed: () => _errorMessage.value = '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading || _allTransactions.isEmpty) return const SizedBox();

        final totals = _calculateTotals(_allTransactions);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Showing ${_filteredTransactions.length} of ${_allTransactions.length} transactions',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Debit: ${_formatCurrency(totals.debit)}',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Credit: ${_formatCurrency(totals.credit)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading transactions...'),
              ],
            ),
          );
        }

        return ValueListenableBuilder<String>(
          valueListenable: _errorMessage,
          builder: (context, errorMessage, child) {
            if (errorMessage.isNotEmpty && _allTransactions.isEmpty) {
              return _buildErrorState();
            }

            if (_filteredTransactions.isEmpty) {
              return _buildEmptyState();
            }

            return _buildTransactionTable();
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'No transactions available'
                : 'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionTable() {
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
                columnSpacing: 12,
                horizontalMargin: 12,
                dataRowMinHeight: 50,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(
                    label: Text("Sr No", style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Mobile", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Particular", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Debit", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Credit", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Receipt", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Expense", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Image", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: List.generate(
                  _filteredTransactions.length,
                      (index) => _buildDataRow(index, _filteredTransactions[index]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(int index, Transaction transaction) {
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
            width: 100,
            child: Text(
              _formatDateTime(transaction.createdDateTime),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 90,
            child: Text(
              transaction.mobileNo ?? 'N/A',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Tooltip(
              message: transaction.particularName,
              child: Text(
                transaction.particularName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: transaction.flag == 'Debit' ? Colors.red[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              transaction.flag,
              style: TextStyle(
                color: transaction.flag == 'Debit' ? Colors.red[700] : Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          transaction.debit != null
              ? Text(
            _formatCurrency(transaction.debit!),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 12,
            ),
          )
              : const Text('-', style: TextStyle(fontSize: 12)),
        ),
        DataCell(
          transaction.credit != null
              ? Text(
            _formatCurrency(transaction.credit!),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 12,
            ),
          )
              : const Text('-', style: TextStyle(fontSize: 12)),
        ),
        DataCell(
          SizedBox(
            width: 70,
            child: Text(
              transaction.receiptBowcherNo ?? 'N/A',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 70,
            child: Text(
              transaction.expenseBowcherNo ?? 'N/A',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(_buildImageCell(transaction)),
        DataCell(_buildActionButton(transaction)),
      ],
    );
  }

  Widget _buildActionButton(Transaction transaction) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view_details':
            _handleViewDetails(transaction);
            break;
          case 'view_image':
            _handleViewImage(transaction);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'view_details',
          child: Row(
            children: [
              Icon(Icons.remove_red_eye, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        if (transaction.hasImage)
          const PopupMenuItem<String>(
            value: 'view_image',
            child: Row(
              children: [
                Icon(Icons.image, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text('View Image'),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Action',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

// Image View Dialog
class ImageViewDialog extends StatelessWidget {
  final String imageUrl;

  const ImageViewDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 8),
                      Text('Failed to load image'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Transaction Detail Dialog
class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Transaction Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Date', _formatDateTime(transaction.createdDateTime)),
            _buildDetailRow('Mobile', transaction.mobileNo ?? 'N/A'),
            _buildDetailRow('Particular', transaction.particularName),
            _buildDetailRow('Transaction Type', transaction.flag),
            _buildDetailRow('Amount', _formatCurrency(transaction.amount)),
            if (transaction.debit != null)
              _buildDetailRow('Debit', _formatCurrency(transaction.debit!)),
            if (transaction.credit != null)
              _buildDetailRow('Credit', _formatCurrency(transaction.credit!)),
            if (transaction.totalBalance != null)
              _buildDetailRow('Balance', _formatCurrency(transaction.totalBalance!)),
            _buildDetailRow('Remarks', transaction.remarks ?? 'N/A'),
            _buildDetailRow('Receipt Voucher', transaction.receiptBowcherNo ?? 'N/A'),
            _buildDetailRow('Expense Voucher', transaction.expenseBowcherNo ?? 'N/A'),
            _buildDetailRow('Remark', transaction.remark ?? 'N/A'),
            if (transaction.hasImage) ...[
              const SizedBox(height: 16),
              const Text('Image:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => ImageViewDialog(imageUrl: transaction.imageUrl),
                  );
                },
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: transaction.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
            ],
          ],
        ),
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '₹${NumberFormat('#,##0.00').format(amount)}';
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd-MMM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
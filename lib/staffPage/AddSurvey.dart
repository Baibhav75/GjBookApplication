// pages/add_survey.dart
import 'package:flutter/material.dart';
import '/Model/survey_model.dart';
import '/Service/survey_service.dart';
import '../utils/debouncer.dart';
import '/staffPage/surver_detail.dart';

class AddSurvey extends StatefulWidget {
  const AddSurvey({Key? key}) : super(key: key);

  @override
  _AddSurveyState createState() => _AddSurveyState();
}

class _AddSurveyState extends State<AddSurvey> {
  final Debouncer _debouncer = Debouncer(milliseconds: 350);
  final ScrollController _scrollController = ScrollController();

  List<SchoolData> _all = [];
  List<SchoolData> _filtered = [];
  bool _loading = true;
  bool _error = false;
  String _errorMsg = '';
  String _query = '';

  // client-side pagination
  static const int pageSize = 15;
  int _page = 0;
  List<SchoolData> _visible = []; // portion shown on UI
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetch();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetch({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMsg = '';
      _page = 0;
      _hasMore = true;
      _visible.clear();
    });

    try {
      final data = await SurveyService.fetchSurveyList(forceRefresh: forceRefresh);
      setState(() {
        _all = data;
        _applyFilterAndReset();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _errorMsg = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilterAndReset() {
    _filtered = _filterList(_all, _query);
    _page = 0;
    _visible = [];
    _hasMore = true;
    _loadMore(); // load first page
  }

  List<SchoolData> _filterList(List<SchoolData> list, String q) {
    if (q.trim().isEmpty) return List.from(list);
    final lower = q.toLowerCase();
    return list.where((s) {
      return (s.schoolName ?? '').toLowerCase().contains(lower) ||
          (s.schoolAddress ?? '').toLowerCase().contains(lower) ||
          (s.prabandhakName ?? '').toLowerCase().contains(lower) ||
          (s.prabandhakMobile ?? '').toLowerCase().contains(lower) ||
          (s.principalName ?? '').toLowerCase().contains(lower);
    }).toList();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    final threshold = 100;
    if (_scrollController.position.extentAfter < threshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!_hasMore) return;
    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 200), () {
      final start = _page * pageSize;
      final end = start + pageSize;
      if (start >= _filtered.length) {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
        return;
      }

      final slice = _filtered.sublist(
        start,
        end > _filtered.length ? _filtered.length : end,
      );
      setState(() {
        _visible.addAll(slice);
        _page += 1;
        _isLoadingMore = false;
        _hasMore = _visible.length < _filtered.length;
      });
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await SurveyService.clearCache();
    await _fetch(forceRefresh: true);
  }

  void _onSearchChanged(String value) {
    _debouncer.run(() {
      setState(() {
        _query = value;
      });
      _applyFilterAndReset();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.deepPurpleAccent),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search school, principal or prabandhak...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => _onSearchChanged(''),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          _TableHeader("No", flex: 1),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              "School Name",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(width: 16),
          _TableHeader("Actions", flex: 2),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final school = _visible[index];
    final isEven = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(school),
          splashColor: Colors.deepPurpleAccent.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                _TableCell(
                  "${index + 1}",
                  flex: 1,
                  center: true,
                  color: Colors.deepPurpleAccent,
                  bold: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Text(
                    school.schoolName ?? "-",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _openDetail(school),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text("View"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: Colors.deepPurpleAccent),
                          onPressed: () => _showQuickInfo(school),
                        ),
                      ],
                    ),
                  ),
                )


              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickInfo(SchoolData school) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("School Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Principal:", school.principalName ?? "-"),
            _infoRow("Prabandhak:", school.prabandhakName ?? "-"),
            _infoRow("Mobile:", school.prabandhakMobile ?? "-"),
            _infoRow("Address:", school.schoolAddress ?? "-"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openDetail(school);
            },
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _openDetail(SchoolData school) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurveyDetail(school: school),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            _query.isEmpty ? 'No surveys available' : 'No matching schools found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          if (_query.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetch,
            child: const Text("Refresh Data"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 4,
        title: const Text(
          'Survey List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.deepPurpleAccent,
            ),
            SizedBox(height: 16),
            Text(
              'Loading surveys...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : _error
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetch,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 8),
          if (_visible.isNotEmpty) _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.deepPurpleAccent,
              child: _visible.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: _scrollController,
                itemCount: _visible.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _visible.length) {
                    return _isLoadingMore
                        ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    )
                        : const SizedBox.shrink();
                  }
                  return _buildRow(context, index);
                },
              ),
            ),
          ),
          if (!_hasMore && _visible.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: const Center(
                child: Text(
                  'No more schools to load',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _TableHeader(this.text, {required this.flex, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool center;
  final bool bold;
  final Color? color;
  const _TableCell(
      this.text, {
        required this.flex,
        this.center = false,
        this.bold = false,
        this.color,
        Key? key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          text,
          textAlign: center ? TextAlign.center : TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: color ?? Colors.black87,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
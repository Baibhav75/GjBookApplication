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
  static const int pageSize = 12;
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
    final threshold = 200; // px
    if (_scrollController.position.extentAfter < threshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!_hasMore) return;
    setState(() => _isLoadingMore = true);

    // simulate small delay for UI smoothness
    Future.delayed(const Duration(milliseconds: 250), () {
      final start = _page * pageSize;
      final end = start + pageSize;
      if (start >= _filtered.length) {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
        return;
      }

      final slice = _filtered.sublist(start, end > _filtered.length ? _filtered.length : end);
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search school, principal or prabandhak...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      color: const Color(0xFFDFF6FF),
      child: Row(
        children: const [
          _TableHeader("Sr", flex: 1),
          _TableHeader("School Name", flex: 3),
          _TableHeader("Address", flex: 3),
          _TableHeader("Prabandhak", flex: 3),
          _TableHeader("Prabandhak No", flex: 2),
          _TableHeader("Principal", flex: 3),
          _TableHeader("Principal No", flex: 2),
          _TableHeader("Action", flex: 2),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final school = _visible[index];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : Colors.grey.shade50,
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          _TableCell("${index + 1}", flex: 1, center: true),
          _TableCell(school.schoolName ?? "-", flex: 3),
          _TableCell(school.schoolAddress ?? "-", flex: 3),
          _TableCell(school.prabandhakName ?? "-", flex: 3),
          _TableCell(school.prabandhakMobile ?? "-", flex: 2),
          _TableCell(school.principalName ?? "-", flex: 3),
          _TableCell(school.principalMobile ?? "-", flex: 2),
          Expanded(
            flex: 2,
            child: Center(
              child: ElevatedButton(
                onPressed: () => _openDetail(school),
                style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
                child: const Text("View", style: TextStyle(fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(SchoolData school) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SurveyDetail(school: school)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: const Text(
          'Survey List',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())

            : _error
            ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Error loading data',
                    style: Theme.of(context).textTheme.titleLarge ??
                        const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(_errorMsg),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        )

            : Column(
          children: [
            _buildSearchBar(),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1150,
                    child: Column(
                      children: [
                        _buildHeaderRow(),

                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: _visible.length,
                          itemBuilder: (context, index) =>
                              _buildRow(context, index),
                        ),

                        if (_isLoadingMore)
                          const Padding(
                            padding:
                            EdgeInsets.symmetric(vertical: 12),
                            child:
                            Center(child: CircularProgressIndicator()),
                          ),

                        if (!_hasMore && _visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: const Center(
                              child: Text('No schools found'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool center;
  const _TableCell(this.text, {required this.flex, this.center = false, Key? key}) : super(key: key);

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
          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
        ),
      ),
    );
  }
}

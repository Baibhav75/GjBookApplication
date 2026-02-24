import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/counter_recovery_list_model.dart';
import '../service/counter_list_service.dart';
import 'counter_view_details.dart';

class CounterListPage extends StatefulWidget {
  const CounterListPage({Key? key}) : super(key: key);

  @override
  State<CounterListPage> createState() => _CounterListPageState();
}

class _CounterListPageState extends State<CounterListPage> {
  final CounterListService _service = CounterListService();
  late Future<List<CounterRecoveryListModel>> _counterFuture;

  @override
  void initState() {
    super.initState();
    _counterFuture = _service.fetchCounters();
  }

  void _showCounterDetails(CounterRecoveryListModel counter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Counter Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${counter.id}"),
            Text("Counter Name: ${counter.counterName}"),
            Text("Counter ID: ${counter.counterId}"),
            Text("Counter Boy: ${counter.counterBoyName}"),
            Text("Mobile: ${counter.counterBoyMob}"),
            Text("School: ${counter.schoolName}"),
            Text(
              "Created Date: ${counter.createDate != null ? DateFormat('dd MMM yyyy').format(counter.createDate!) : "N/A"}",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String todayDate =
    DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Counter List"),
            Text(
              todayDate,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _counterFuture = _service.fetchCounters();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<CounterRecoveryListModel>>(
        future: _counterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No counters found"));
          }

          final counters = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                MaterialStateProperty.all(Colors.lightBlue[100]),
                columns: const [
                  DataColumn(label: Text("Sr No")),
                  DataColumn(label: Text("Counter Name")),
                  DataColumn(label: Text("Counter ID")),
                  DataColumn(label: Text("Counter Boy")),
                  DataColumn(label: Text("Mobile")),
                  DataColumn(label: Text("School")),
                  DataColumn(label: Text("Created Date")),
                  DataColumn(label: Text("Action")),
                ],
                rows: counters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final counter = entry.value;

                  return DataRow(cells: [
                    DataCell(Text("${index + 1}")),
                    DataCell(Text(counter.counterName)),
                    DataCell(Text(counter.counterId)),
                    DataCell(Text(counter.counterBoyName)),
                    DataCell(Text(counter.counterBoyMob)),
                    DataCell(Text(counter.schoolName)),
                    DataCell(Text(
                      counter.createDate != null
                          ? DateFormat('dd-MM-yyyy')
                          .format(counter.createDate!)
                          : "N/A",
                    )),
                    DataCell(
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CounterViewDetails(
                                counterId: counter.counterId!,  // 👈 Pass ID
                              ),
                            ),
                          );
                        },
                        child: const Text("View"),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/Model/CounterDetailsAdmin_Model.dart';
import 'Controller/counter_details_controller.dart';

class CounterViewDetails extends StatefulWidget {

  final String counterId;

  const CounterViewDetails({Key? key, required this.counterId})
      : super(key: key);

  @override
  State<CounterViewDetails> createState() => _CounterViewDetailsState();
}

class _CounterViewDetailsState extends State<CounterViewDetails> {

  final CounterDetailsController _controller =
  CounterDetailsController();

  late Future<CounterDetailsAdminModel?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture =
        _controller.getDetails(widget.counterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Counter Details"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<CounterDetailsAdminModel?>(
        future: _detailsFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(
                child: Text("No details found"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildTitle("Basic Details"),
                    _buildRow("Counter Name", data.counterName),
                    _buildRow("Counter ID", data.counterId),
                    _buildRow("Counter Boy", data.counterBoyName),
                    _buildRow("Mobile", data.counterBoyMob),
                    _buildRow("Father Name", data.faterName),
                    _buildRow("Mother Name", data.motherName),
                    _buildRow("School", data.schoolName),
                    _buildRow(
                      "Created Date",
                      data.createDate != null
                          ? DateFormat('dd MMM yyyy')
                          .format(data.createDate!)
                          : null,
                    ),

                    const SizedBox(height: 20),

                    _buildTitle("Documents"),

                    _buildImage(context, "Cancel Check", data.cancelCheck),
                    _buildImage(context, "Agreement", data.agreement),
                    _buildImage(context, "MarkSheet", data.counterBoyMarkSheet),
                    _buildImage(context, "Aadhar Card", data.counterBoyAdharCard),
                    _buildImage(context, "Father Aadhar", data.fatehrAdhar),
                    _buildImage(context, "Mother Aadhar", data.motherAdhar),
                    _buildImage(context, "Victim1 Aadhar", data.victim1Adhar),
                    _buildImage(context, "Victim2 Aadhar", data.victim2Adhar),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
Widget _buildTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
Widget _buildRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(value ?? "N/A"),
        ),
      ],
    ),
  );
}
Widget _buildImage(
    BuildContext context, String title, String? imagePath) {

  if (imagePath == null || imagePath.isEmpty) {
    return _buildRow(title, "No Document");
  }

  final fullUrl = "https://g17bookworld.com$imagePath";

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [

            // Thumbnail Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fullUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),

            const SizedBox(width: 16),

            // View Button
            OutlinedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text("View Document"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FullScreenImageView(imageUrl: fullUrl),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}



class FullScreenImageView extends StatelessWidget {

  final String imageUrl;

  const FullScreenImageView({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}